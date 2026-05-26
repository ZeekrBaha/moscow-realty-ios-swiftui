import SwiftUI

struct AuthFlowView: View {
    @Environment(ProfileCoordinator.self) private var profileCoordinator
    @State private var coordinator = AuthCoordinator()

    var body: some View {
        NavigationStack(path: Bindable(coordinator).path) {
            LoginView()
                .navigationDestination(for: AuthDestination.self) { dest in
                    switch dest {
                    case .registerBuyer: RegisterBuyerView()
                    case .registerAgent: RegisterAgentView()
                    }
                }
        }
        .environment(coordinator)
        .onAppear {
            coordinator.onSuccess = { _ in
                profileCoordinator.isAuthPresented = false
            }
        }
    }
}
