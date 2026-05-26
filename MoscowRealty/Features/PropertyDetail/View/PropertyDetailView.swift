import SwiftUI

struct PropertyDetailView: View {
    let property: Property
    @Environment(\.favoritesService) private var favoritesService
    @State private var viewModel: PropertyDetailViewModel?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if let vm = viewModel {
                    PhotoGalleryView(imageNames: property.imageNames)

                    VStack(alignment: .leading, spacing: 16) {
                        priceAndTitle
                        Divider()
                        specsGrid(vm: vm)
                        Divider()
                        descriptionSection
                        Divider()
                        mapSection
                        contactButton
                    }
                    .padding()
                } else {
                    ProgressView().frame(maxWidth: .infinity, minHeight: 400)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if let vm = viewModel {
                    Button { vm.toggleFavorite() } label: {
                        Image(systemName: vm.isFavorite ? "heart.fill" : "heart")
                            .foregroundStyle(vm.isFavorite ? .red : .primary)
                    }
                }
            }
        }
        .task {
            viewModel = PropertyDetailViewModel(
                property: property,
                favoritesService: favoritesService
            )
        }
    }

    private var priceAndTitle: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(property.formattedPrice)
                .font(.title).bold()
            Text(property.title)
                .font(.title3)
                .foregroundStyle(.secondary)
            Text(property.address)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private func specsGrid(vm: PropertyDetailViewModel) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(vm.specsRows, id: \.label) { row in
                VStack(alignment: .leading, spacing: 2) {
                    Text(row.label)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(row.value)
                        .font(.subheadline).bold()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Описание")
                .font(.headline)
            Text(property.description)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    private var mapSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("На карте")
                .font(.headline)
            MapSingleView(coordinates: property.coordinates, title: property.address)
        }
    }

    private var contactButton: some View {
        Button {
            // Chat navigation wired in Phase 4
        } label: {
            Label("Написать агенту", systemImage: "message.fill")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .padding(.top, 8)
    }
}

#Preview {
    NavigationStack {
        PropertyDetailView(property: MockPropertyService.seedData()[0])
            .environment(\.favoritesService, FavoritesService())
    }
}
