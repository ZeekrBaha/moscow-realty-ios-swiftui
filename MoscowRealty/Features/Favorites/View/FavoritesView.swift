import SwiftUI

struct FavoritesView: View {
    @Environment(ProfileCoordinator.self) private var coordinator
    @Environment(\.propertyService)  private var propertyService
    @Environment(\.favoritesService) private var favoritesService
    @State private var viewModel: FavoritesViewModel?

    var body: some View {
        Group {
            if let vm = viewModel {
                content(vm: vm)
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Избранное")
        .task {
            let vm = FavoritesViewModel(
                propertyService: propertyService,
                favoritesService: favoritesService
            )
            viewModel = vm
            await vm.load()
        }
    }

    @ViewBuilder
    private func content(vm: FavoritesViewModel) -> some View {
        switch vm.state {
        case .idle, .loading:
            ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loaded(let properties):
            if properties.isEmpty {
                ContentUnavailableView(
                    "Нет избранных",
                    systemImage: "heart.slash",
                    description: Text("Добавьте объявления в избранное")
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(properties) { property in
                            PropertyCard(
                                property: property,
                                isFavorite: true,
                                onFavoriteTap: {
                                    Task { await vm.removeFavorite(id: property.id) }
                                }
                            )
                            .padding(.horizontal)
                            .onTapGesture { coordinator.showPropertyDetail(property) }
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
