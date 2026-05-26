import SwiftUI

struct PhotoGalleryView: View {
    let imageNames: [String]
    @State private var currentIndex = 0

    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(imageNames.indices, id: \.self) { idx in
                Image(imageNames[idx])
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
                    .tag(idx)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .frame(height: 280)
    }
}
