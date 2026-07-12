import SwiftUI

struct AddListingView: View {
    var existingProperty: Property?
    @Environment(PostCoordinator.self) private var postCoordinator
    @Environment(\.propertyService) private var propertyService
    @Environment(AppCoordinator.self) private var app
    @State private var viewModel: AddListingViewModel?

    var body: some View {
        Group {
            if let vm = viewModel {
                if vm.isSubmitted {
                    successView(vm: vm)
                } else {
                    stepContent(vm: vm)
                }
            } else {
                ProgressView()
            }
        }
        .navigationTitle(existingProperty == nil ? "Разместить" : "Изменить")
        .task {
            let agentId = app.currentUser?.id ?? UUID()
            let vm = AddListingViewModel(propertyService: propertyService, agentId: agentId)
            if let existing = existingProperty { vm.populate(from: existing) }
            viewModel = vm
        }
    }

    @ViewBuilder
    private func stepContent(vm: AddListingViewModel) -> some View {
        @Bindable var vm = vm
        switch postCoordinator.currentStep {
        case .typeSelection: step1(vm: vm)
        case .location:      step2(vm: vm)
        case .details:       step3(vm: vm)
        case .photos:        step4(vm: vm)
        case .confirmation:  step5(vm: vm)
        }
    }

    private func step1(vm: AddListingViewModel) -> some View {
        @Bindable var vm = vm
        return VStack(spacing: 24) {
            Text("Шаг 1 из 5: Тип объекта").font(.headline)
            Picker("Тип", selection: $vm.propertyType) {
                ForEach(PropertyType.allCases, id: \.self) { Text($0.displayName).tag($0) }
            }.pickerStyle(.segmented)
            Picker("Сделка", selection: $vm.listingType) {
                ForEach(ListingType.allCases, id: \.self) { Text($0.displayName).tag($0) }
            }.pickerStyle(.segmented)
            Spacer()
            Button("Далее") { postCoordinator.nextStep() }
                .buttonStyle(.borderedProminent).frame(maxWidth: .infinity)
        }.padding()
    }

    private func step2(vm: AddListingViewModel) -> some View {
        @Bindable var vm = vm
        return Form {
            Section("Шаг 2 из 5: Адрес") {
                TextField("Адрес", text: $vm.address)
                TextField("Район", text: $vm.district)
                TextField("Метро (необязательно)", text: $vm.metro)
            }
            Section {
                HStack {
                    Button("Назад") { postCoordinator.previousStep() }.buttonStyle(.bordered)
                    Spacer()
                    Button("Далее") { postCoordinator.nextStep() }.buttonStyle(.borderedProminent)
                }
            }.listRowBackground(Color.clear)
        }
    }

    private func step3(vm: AddListingViewModel) -> some View {
        @Bindable var vm = vm
        return Form {
            Section("Шаг 3 из 5: Детали") {
                TextField("Название объявления", text: $vm.title)
                HStack {
                    Text("Площадь, м²")
                    Spacer()
                    TextField("0", value: $vm.area, format: .number)
                        .keyboardType(.decimalPad).multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Цена, ₽")
                    Spacer()
                    TextField("0", value: $vm.price, format: .number)
                        .keyboardType(.numberPad).multilineTextAlignment(.trailing)
                }
                if vm.propertyType == .apartment {
                    Stepper("Комнат: \(vm.rooms)", value: $vm.rooms, in: 1...10)
                    HStack {
                        TextField("Этаж", value: $vm.floor, format: .number).keyboardType(.numberPad)
                        Text("из")
                        TextField("Всего", value: $vm.totalFloors, format: .number).keyboardType(.numberPad)
                    }
                    Toggle("Новостройка", isOn: $vm.isNewBuilding)
                } else {
                    Toggle("Отапливаемое", isOn: $vm.isHeated)
                }
                TextField("Описание", text: $vm.description, axis: .vertical)
                    .lineLimit(3...6)
            }
            if let err = vm.errorMessage {
                Section { Text(err).foregroundStyle(.red).font(.caption) }
            }
            Section {
                HStack {
                    Button("Назад") { postCoordinator.previousStep() }.buttonStyle(.bordered)
                    Spacer()
                    Button("Далее") { postCoordinator.nextStep() }.buttonStyle(.borderedProminent)
                }
            }.listRowBackground(Color.clear)
        }
    }

    private func step4(vm: AddListingViewModel) -> some View {
        @Bindable var vm = vm
        return VStack(spacing: 16) {
            Text("Шаг 4 из 5: Фотографии").font(.headline)
            Text("Выберите фотографии из каталога").foregroundStyle(.secondary)
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(vm.availableImages, id: \.self) { name in
                        let isSelected = vm.selectedImageNames.contains(name)
                        Image(name)
                            .resizable()
                            .aspectRatio(1, contentMode: .fill)
                            .clipped()
                            .overlay(isSelected ? Color.accentColor.opacity(0.4) : Color.clear)
                            .overlay(alignment: .topTrailing) {
                                if isSelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.white).padding(4)
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .onTapGesture {
                                if isSelected {
                                    vm.selectedImageNames.removeAll { $0 == name }
                                } else {
                                    vm.selectedImageNames.append(name)
                                }
                            }
                    }
                }
            }
            HStack {
                Button("Назад") { postCoordinator.previousStep() }.buttonStyle(.bordered)
                Spacer()
                Button("Далее") { postCoordinator.nextStep() }.buttonStyle(.borderedProminent)
            }
        }.padding()
    }

    private func step5(vm: AddListingViewModel) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Шаг 5 из 5: Подтверждение").font(.headline)
                Group {
                    labelRow("Тип", vm.propertyType.displayName)
                    labelRow("Сделка", vm.listingType.displayName)
                    labelRow("Название", vm.title)
                    labelRow("Адрес", vm.address)
                    labelRow("Район", vm.district)
                    labelRow("Площадь", "\(Int(vm.area)) м²")
                    labelRow("Цена", "\(vm.price) ₽")
                    labelRow("Фото", "\(vm.selectedImageNames.count) шт.")
                }
                if let err = vm.errorMessage {
                    Text(err).foregroundStyle(.red).font(.caption)
                }
                HStack {
                    Button("Назад") { postCoordinator.previousStep() }.buttonStyle(.bordered)
                    Spacer()
                    Button {
                        Task { await vm.submit() }
                    } label: {
                        if vm.isSubmitting { ProgressView().tint(.white) } else { Text("Разместить") }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(vm.isSubmitting)
                }
            }.padding()
        }
    }

    private func labelRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).foregroundStyle(.secondary)
            Spacer()
            Text(value).bold()
        }
    }

    private func successView(vm: AddListingViewModel) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 72)).foregroundStyle(.green)
            Text("Объявление размещено!").font(.title2).bold()
            Button("Готово") { postCoordinator.resetToStart() }
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
