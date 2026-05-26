import SwiftUI

struct PropertyCard: View {
    let property: Property
    var isFavorite: Bool = false
    var onFavoriteTap: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            imageSection
            infoSection
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)
    }

    private var imageSection: some View {
        ZStack(alignment: .topTrailing) {
            Image(property.imageNames.first ?? "placeholder")
                .resizable()
                .aspectRatio(4/3, contentMode: .fill)
                .frame(height: 180)
                .clipped()

            if let onFavoriteTap {
                Button(action: onFavoriteTap) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(isFavorite ? .red : .white)
                        .padding(8)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .padding(8)
            }
        }
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(property.formattedPrice)
                .font(.headline)
            Text(property.title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            HStack(spacing: 4) {
                if let metro = property.metro {
                    Image(systemName: "tram.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(metro)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(property.formattedArea)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
    }
}

#Preview {
    PropertyCard(
        property: MockPropertyService.seedData()[0],
        isFavorite: false
    )
    .frame(width: 280)
    .padding()
}
