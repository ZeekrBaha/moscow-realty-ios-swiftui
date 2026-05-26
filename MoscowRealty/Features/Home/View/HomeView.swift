import SwiftUI

struct HomeView: View {
    @Environment(AppCoordinator.self) private var app
    @Environment(MainCoordinator.self) private var coordinator
    @Environment(\.propertyService) private var propertyService
    @State private var viewModel: HomeViewModel?

    @State private var showListingTypeSheet = false
    @State private var showPropertyTypeSheet = false
    @State private var showRoomsSheet = false
    @State private var showPriceSheet = false
    @State private var showMetroSheet = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                filterBarSection
                if let vm = viewModel {
                    metroSearchButton(vm: vm)
                    showButton(vm: vm)
                    propertyGridSection(vm: vm)
                }
            }
        }
        .navigationTitle("МоскваРиелти")
        .navigationBarTitleDisplayMode(.large)
        .task {
            let vm = HomeViewModel(propertyService: propertyService)
            viewModel = vm
            await vm.load()
        }
        .sheet(isPresented: $showListingTypeSheet) {
            if let vm = viewModel { ListingTypeSheet(vm: vm) }
        }
        .sheet(isPresented: $showPropertyTypeSheet) {
            if let vm = viewModel { PropertyTypeSheet(vm: vm) }
        }
        .sheet(isPresented: $showRoomsSheet) {
            if let vm = viewModel { RoomsSheet(vm: vm) }
        }
        .sheet(isPresented: $showPriceSheet) {
            if let vm = viewModel { PriceSheet(vm: vm) }
        }
        .sheet(isPresented: $showMetroSheet) {
            if let vm = viewModel { MetroSearchSheet(vm: vm) }
        }
    }

    // MARK: - Filter bar

    private var filterBarSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(
                    label: viewModel?.selectedListingType.displayName ?? "Купить",
                    isActive: true,
                    action: { showListingTypeSheet = true }
                )
                filterChip(
                    label: viewModel?.selectedPropertyType.displayName ?? "Квартиру",
                    isActive: viewModel?.selectedPropertyType != .apartment,
                    action: { showPropertyTypeSheet = true }
                )
                filterChip(
                    label: viewModel?.roomsLabel ?? "Комнаты",
                    isActive: viewModel?.selectedRooms != nil,
                    action: { showRoomsSheet = true }
                )
                filterChip(
                    label: viewModel?.priceLabel ?? "Цена",
                    isActive: viewModel?.priceMin != nil || viewModel?.priceMax != nil,
                    action: { showPriceSheet = true }
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    private func filterChip(label: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(isActive ? .semibold : .regular)
                Image(systemName: "chevron.down")
                    .font(.caption2)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(isActive ? Color(.systemBackground) : Color.primary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                isActive ? Color.primary : Color(.secondarySystemBackground),
                in: Capsule()
            )
        }
    }

    // MARK: - Metro search (button → bottom sheet)

    private func metroSearchButton(vm: HomeViewModel) -> some View {
        Button { showMetroSheet = true } label: {
            HStack(spacing: 10) {
                Image(systemName: "tram.fill")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
                Text(vm.metroQuery.isEmpty ? "Метро или район" : vm.metroQuery)
                    .font(.subheadline)
                    .foregroundStyle(vm.metroQuery.isEmpty ? Color(.placeholderText) : Color.primary)
                Spacer()
                if !vm.metroQuery.isEmpty {
                    Button {
                        vm.metroQuery = ""
                        Task { await vm.applyFilters() }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
    }

    // MARK: - Show button

    private func showButton(vm: HomeViewModel) -> some View {
        Button {
            Task { await vm.applyFilters() }
        } label: {
            HStack {
                Image(systemName: "slider.horizontal.3")
                Text("Показать")
                    .fontWeight(.semibold)
                if case .loaded(let props) = vm.featuredState {
                    Text("· \(props.count)")
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.primary, in: RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 4)
    }

    // MARK: - 2-column grid

    private func propertyGridSection(vm: HomeViewModel) -> some View {
        Group {
            switch vm.featuredState {
            case .idle, .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 200)
                    .padding(.top, 40)
            case .loaded(let properties):
                let rentProps = properties.filter { $0.listingType == .rent }
                let buyProps  = properties.filter { $0.listingType == .buy }

                VStack(alignment: .leading, spacing: 0) {
                    if !rentProps.isEmpty {
                        sectionHeader("Аренда", count: rentProps.count)
                        twoColumnGrid(rentProps)
                    }
                    if !buyProps.isEmpty {
                        sectionHeader("Покупка", count: buyProps.count)
                        twoColumnGrid(buyProps)
                    }
                    if properties.isEmpty {
                        ContentUnavailableView(
                            "Ничего не найдено",
                            systemImage: "house.slash",
                            description: Text("Попробуйте изменить фильтры")
                        )
                        .padding(.top, 60)
                    }
                }
            case .error(let msg):
                Text(msg).foregroundStyle(.red).padding()
            }
        }
        .padding(.top, 16)
        .padding(.bottom, 24)
    }

    private func sectionHeader(_ title: String, count: Int) -> some View {
        HStack {
            Text(title)
                .font(.title3).bold()
            Text("·")
                .foregroundStyle(.secondary)
            Text("\(count)")
                .font(.title3)
                .foregroundStyle(.secondary)
            Spacer()
            Button("Все") {}
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func twoColumnGrid(_ properties: [Property]) -> some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
            spacing: 12
        ) {
            ForEach(properties) { property in
                GridPropertyCard(property: property)
                    .onTapGesture { coordinator.showDetail(property) }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}

// MARK: - Grid property card

struct GridPropertyCard: View {
    let property: Property

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image(property.imageNames.first ?? "placeholder")
                .resizable()
                .aspectRatio(4/3, contentMode: .fill)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 3) {
                Text(property.formattedPrice)
                    .font(.subheadline).bold()
                    .lineLimit(1)
                Text(property.title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                if let metro = property.metro {
                    HStack(spacing: 3) {
                        Image(systemName: "tram.fill")
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                        Text(metro)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.07), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Filter sheets

private struct ListingTypeSheet: View {
    @Bindable var vm: HomeViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(ListingType.allCases, id: \.self) { type in
                HStack {
                    Text(type.displayName).font(.body)
                    Spacer()
                    if vm.selectedListingType == type {
                        Image(systemName: "checkmark").foregroundStyle(.primary)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    vm.selectedListingType = type
                    Task { await vm.applyFilters() }
                    dismiss()
                }
            }
            .navigationTitle("Тип сделки")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Отмена") { dismiss() } } }
        }
        .presentationDetents([.fraction(0.3)])
    }
}

private struct PropertyTypeSheet: View {
    @Bindable var vm: HomeViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(PropertyType.allCases, id: \.self) { type in
                HStack {
                    Text(type.displayName).font(.body)
                    Spacer()
                    if vm.selectedPropertyType == type {
                        Image(systemName: "checkmark").foregroundStyle(.primary)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    vm.selectedPropertyType = type
                    Task { await vm.applyFilters() }
                    dismiss()
                }
            }
            .navigationTitle("Тип недвижимости")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Отмена") { dismiss() } } }
        }
        .presentationDetents([.fraction(0.35)])
    }
}

private struct RoomsSheet: View {
    @Bindable var vm: HomeViewModel
    @Environment(\.dismiss) private var dismiss

    private let options: [(Int?, String)] = [
        (nil, "Любое"),
        (1, "1"),
        (2, "2"),
        (3, "3"),
        (4, "4+")
    ]

    var body: some View {
        NavigationStack {
            List(options, id: \.1) { rooms, label in
                HStack {
                    Text(label == "Любое" ? label : "\(label)-комн.")
                        .font(.body)
                    Spacer()
                    if vm.selectedRooms == rooms {
                        Image(systemName: "checkmark").foregroundStyle(.primary)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    vm.selectedRooms = rooms
                    Task { await vm.applyFilters() }
                    dismiss()
                }
            }
            .navigationTitle("Количество комнат")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Отмена") { dismiss() } } }
        }
        .presentationDetents([.fraction(0.45)])
    }
}

private struct PriceSheet: View {
    @Bindable var vm: HomeViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var minText = ""
    @State private var maxText = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("От").font(.caption).foregroundStyle(.secondary)
                        TextField("0", text: $minText)
                            .keyboardType(.numberPad)
                            .padding(12)
                            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("До").font(.caption).foregroundStyle(.secondary)
                        TextField("∞", text: $maxText)
                            .keyboardType(.numberPad)
                            .padding(12)
                            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(.horizontal)

                Text("₽").font(.subheadline).foregroundStyle(.secondary)

                Button("Применить") {
                    vm.priceMin = Int(minText)
                    vm.priceMax = Int(maxText)
                    Task { await vm.applyFilters() }
                    dismiss()
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.primary, in: RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top, 20)
            .navigationTitle("Цена")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Отмена") { dismiss() } }
                ToolbarItem(placement: .destructiveAction) {
                    Button("Сбросить") {
                        vm.priceMin = nil
                        vm.priceMax = nil
                        minText = ""
                        maxText = ""
                        Task { await vm.applyFilters() }
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.fraction(0.4)])
        .onAppear {
            if let min = vm.priceMin { minText = "\(min)" }
            if let max = vm.priceMax { maxText = "\(max)" }
        }
    }
}

// MARK: - Metro search sheet

private struct MetroSearchSheet: View {
    @Bindable var vm: HomeViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""

    private let allStations = [
        "Арбатская", "Арбатская (Филёвская)", "Аэропорт",
        "Бабушкинская", "Библиотека им. Ленина", "Боровицкая",
        "ВДНХ", "Выхино",
        "Динамо", "Дмитровская", "Добрынинская",
        "Киевская", "Китай-город", "Комсомольская", "Кропоткинская", "Курская",
        "Лубянка",
        "Маяковская", "Менделеевская", "Митино",
        "Новослободская",
        "Октябрьская", "Охотный ряд",
        "Павелецкая", "Парк культуры", "Площадь Революции", "Проспект Мира", "Пушкинская",
        "Раменки",
        "Серпуховская", "Смоленская", "Сокол", "Сокольники",
        "Таганская", "Театральная", "Тверская", "Третьяковская",
        "Университет",
        "Чистые пруды", "Чкаловская",
        "Юго-Западная",
        "Якиманка"
    ]

    private var filtered: [String] {
        query.isEmpty ? allStations : allStations.filter {
            $0.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Станция или район", text: $query)
                        .autocorrectionDisabled()
                    if !query.isEmpty {
                        Button { query = "" } label: {
                            Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(12)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                List {
                    if !vm.metroQuery.isEmpty {
                        Button {
                            vm.metroQuery = ""
                            Task { await vm.applyFilters() }
                            dismiss()
                        } label: {
                            HStack {
                                Image(systemName: "xmark.circle")
                                    .foregroundStyle(.secondary)
                                Text("Сбросить фильтр")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    ForEach(filtered, id: \.self) { station in
                        HStack {
                            Image(systemName: "tram.fill")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(width: 20)
                            Text(station)
                            Spacer()
                            if vm.metroQuery == station {
                                Image(systemName: "checkmark").foregroundStyle(.primary)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            vm.metroQuery = station
                            Task { await vm.applyFilters() }
                            dismiss()
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Метро")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Отмена") { dismiss() } } }
        }
        .presentationDetents([.large])
        .onAppear { query = "" }
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .environment(AppCoordinator())
            .environment(MainCoordinator())
            .environment(\.propertyService, MockPropertyService())
    }
}
