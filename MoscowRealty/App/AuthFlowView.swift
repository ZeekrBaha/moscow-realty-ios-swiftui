import SwiftUI
struct AuthFlowView: View {
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
    }
}
