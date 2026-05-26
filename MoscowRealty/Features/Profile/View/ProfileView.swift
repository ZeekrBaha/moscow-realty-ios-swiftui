import SwiftUI

struct ProfileView: View {
    @Environment(ProfileCoordinator.self) private var coordinator
    @Environment(AppCoordinator.self) private var app
    @Environment(\.authService) private var authService
    @Environment(\.propertyService) private var propertyService
    @Environment(\.favoritesService) private var favoritesService
    @State private var viewModel: ProfileViewModel?

    var body: some View {
        Group {
            if let vm = viewModel {
                if vm.isLoggedIn {
                    loggedInContent(vm: vm)
                } else {
                    loggedOutContent
                }
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Профиль")
        .task { viewModel = ProfileViewModel(authService: authService) }
    }

    private var loggedOutContent: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.circle")
                .font(.system(size: 80))
                .foregroundStyle(.secondary)
            Text("Войдите, чтобы сохранять избранное и управлять объявлениями")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            Button("Войти / Зарегистрироваться") {
                coordinator.showLogin()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private func loggedInContent(vm: ProfileViewModel) -> some View {
        List {
            Section {
                HStack(spacing: 16) {
                    Circle()
                        .fill(Color.accentColor.opacity(0.2))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Text(vm.currentUser?.initials ?? "")
                                .font(.title2).bold()
                                .foregroundStyle(Color.accentColor)
                        )
                    VStack(alignment: .leading, spacing: 4) {
                        Text(vm.currentUser?.name ?? "").font(.headline)
                        Text(vm.currentUser?.email ?? "")
                            .font(.caption).foregroundStyle(.secondary)
                        if vm.isAgent {
                            Label("Агент", systemImage: "briefcase.fill")
                                .font(.caption)
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                }
            }

            Section("Избранное") {
                NavigationLink("Мои избранные объявления") {
                    FavoritesView()
                        .environment(coordinator)
                        .environment(\.propertyService, propertyService)
                        .environment(\.favoritesService, favoritesService)
                }
            }

            if vm.isAgent {
                Section("Агент") {
                    NavigationLink("Мои объявления") {
                        AgentDashboardView()
                            .environment(coordinator)
                            .environment(\.propertyService, propertyService)
                            .environment(app)
                    }
                }
            }

            Section {
                Button("Выйти", role: .destructive) {
                    vm.logout()
                }
            }
        }
    }
}
