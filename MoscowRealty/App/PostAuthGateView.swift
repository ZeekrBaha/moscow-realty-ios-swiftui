import SwiftUI
struct PostAuthGateView: View {
    @Environment(PostCoordinator.self) private var coordinator
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.circle")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            Text("Только для агентов")
                .font(.title2).bold()
            Text("Войдите как агент, чтобы размещать объявления")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button("Войти как агент") {
                coordinator.requireAuth()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
