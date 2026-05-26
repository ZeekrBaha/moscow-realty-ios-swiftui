import SwiftUI

@main
struct MoscowRealtyApp: App {
    @State private var appCoordinator = AppCoordinator()
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                RootTabView()
                    .environment(appCoordinator)
            } else {
                OnboardingView {
                    hasSeenOnboarding = true
                }
            }
        }
    }
}
