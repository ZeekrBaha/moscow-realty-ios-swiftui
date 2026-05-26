import SwiftUI

@main
struct MoscowRealtyApp: App {
    @State private var appCoordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(appCoordinator)
        }
    }
}
