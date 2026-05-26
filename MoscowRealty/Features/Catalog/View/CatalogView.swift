import SwiftUI

struct CatalogView: View {
    @Environment(MainCoordinator.self) private var coordinator
    @Environment(\.propertyService) private var propertyService
    @Environment(\.favoritesService) private var favorites
    @State private var viewModel: CatalogViewModel?
    let initialFilter: SearchFilter

    init(filter: SearchFilter = SearchFilter()) {
        self.initialFilter = filter
    }

    var body: some View {
        Group {
            if let vm = viewModel {
                content(vm: vm)
            } else {
                ProgressView()
            }
        }
        .task {
            let vm = CatalogViewModel(propertyService: propertyService)
            vm.filter = initialFilter
            viewModel = vm
            await vm.load()
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var navigationTitle: String {
        viewModel?.filter.propertyType.displayName ?? "Каталог"
    }

    @ViewBuilder
    private func content(vm: CatalogViewModel) -> some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button {
                    vm.toggleView()
                } label: {
                    Image(systemName: vm.showMap ? "list.bullet" : "map")
                }
                .padding(.trailing)
            }
            .padding(.vertical, 8)

            if vm.showMap {
                CatalogMapView(properties: vm.state.value ?? [])
            } else {
                listContent(vm: vm)
            }
        }
    }

    private func listContent(vm: CatalogViewModel) -> some View {
        Group {
            switch vm.state {
            case .idle, .loading:
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            case .loaded(let properties):
                if properties.isEmpty {
                    ContentUnavailableView(
                        "Нет объявлений",
                        systemImage: "house.slash",
                        description: Text("Попробуйте изменить фильтры")
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(properties) { property in
                                PropertyCard(
                                    property: property,
                                    isFavorite: favorites.isFavorite(id: property.id),
                                    onFavoriteTap: { favorites.toggle(id: property.id) }
                                )
                                .padding(.horizontal)
                                .onTapGesture { coordinator.showDetail(property) }
                            }
                        }
                        .padding(.bottom, 20)
                    }
                }
            case .error(let msg):
                Text(msg).foregroundStyle(.red).padding()
            }
        }
    }
}
