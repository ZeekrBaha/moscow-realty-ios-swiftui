import SwiftUI
import MapKit

struct MapSingleView: View {
    let coordinates: Coordinates
    let title: String

    private var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
    }

    var body: some View {
        Map {
            Marker(title, coordinate: coordinate)
        }
        .mapStyle(.standard)
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .allowsHitTesting(false)
    }
}
