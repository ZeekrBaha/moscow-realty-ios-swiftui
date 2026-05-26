import SwiftUI

struct HomeView: View {
    @Environment(AppCoordinator.self) private var app
    @Environment(MainCoordinator.self) private var coordinator
    @Environment(\.propertyService) private var propertyService
    @State private var viewModel: HomeViewModel?
    @State private var showCatalog = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                heroSection
                if let vm = viewModel {
                    typePickerSection(vm: vm)
                    listingTypePickerSection(vm: vm)
                    featuredSection(vm: vm)
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
    }

    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            Image("apt_arbat_1")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 200)
                .clipped()
            LinearGradient(
                colors: [.clear, .black.opacity(0.6)],
                startPoint: .top, endPoint: .bottom
            )
            .frame(height: 200)
            Text("Квартиры в новостройках\nот застройщика")
                .font(.title2).bold()
                .foregroundStyle(.white)
                .padding()
        }
        .frame(maxWidth: .infinity)
    }

    private func typePickerSection(vm: HomeViewModel) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(PropertyType.allCases, id: \.self) { type in
                    Button(type.displayName) {
                        Task { await vm.selectType(type) }
                    }
                    .buttonStyle(.bordered)
                    .tint(vm.selectedPropertyType == type ? .primary : .secondary)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 12)
    }

    private func listingTypePickerSection(vm: HomeViewModel) -> some View {
        Picker("", selection: Binding(
            get: { vm.selectedListingType },
            set: { type in Task { await vm.selectListingType(type) } }
        )) {
            ForEach(ListingType.allCases, id: \.self) { type in
                Text(type.displayName).tag(type)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.bottom, 12)
    }

    private func featuredSection(vm: HomeViewModel) -> some View {
        Group {
            switch vm.featuredState {
            case .idle, .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 200)
            case .loaded(let properties):
                LazyVStack(spacing: 16) {
                    ForEach(properties) { property in
                        PropertyCard(property: property)
                            .padding(.horizontal)
                            .onTapGesture {
                                coordinator.showDetail(property)
                            }
                    }
                }
                .padding(.bottom, 20)
            case .error(let msg):
                Text(msg)
                    .foregroundStyle(.red)
                    .padding()
            }
        }
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
