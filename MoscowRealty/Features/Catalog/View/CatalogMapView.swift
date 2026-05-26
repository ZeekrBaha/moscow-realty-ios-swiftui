import SwiftUI
import MapKit

struct CatalogMapView: View {
    let properties: [Property]
    @Environment(MainCoordinator.self) private var coordinator
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6176),
            span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
        )
    )
    @State private var selectedProperty: Property?

    var body: some View {
        Map(position: $cameraPosition, selection: $selectedProperty) {
            ForEach(properties) { property in
                Annotation(
                    property.formattedPrice,
                    coordinate: CLLocationCoordinate2D(
                        latitude: property.coordinates.latitude,
                        longitude: property.coordinates.longitude
                    ),
                    anchor: .bottom
                ) {
                    VStack(spacing: 0) {
                        Text(property.formattedPrice)
                            .font(.caption2).bold()
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(selectedProperty?.id == property.id ? Color.primary : Color(.systemBackground))
                            .foregroundStyle(selectedProperty?.id == property.id ? Color(.systemBackground) : Color.primary)
                            .clipShape(Capsule())
                            .shadow(radius: 2)
                        Image(systemName: "arrowtriangle.down.fill")
                            .font(.system(size: 6))
                            .foregroundStyle(selectedProperty?.id == property.id ? Color.primary : Color(.systemBackground))
                    }
                    .onTapGesture { selectedProperty = property }
                }
                .tag(property)
            }
        }
        .mapStyle(.standard)
        .overlay(alignment: .bottom) {
            if let selected = selectedProperty {
                PropertyCard(property: selected)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.regularMaterial)
                    .onTapGesture { coordinator.showDetail(selected) }
            }
        }
    }
}
