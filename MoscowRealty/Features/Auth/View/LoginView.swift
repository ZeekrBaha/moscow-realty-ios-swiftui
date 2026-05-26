import SwiftUI

struct LoginView: View {
    @Environment(AuthCoordinator.self) private var coordinator
    @Environment(\.authService) private var authService
    @State private var viewModel: LoginViewModel?

    var body: some View {
        Group {
            if let vm = viewModel {
                form(vm: vm)
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Вход")
        .task { viewModel = LoginViewModel(authService: authService) }
        .onChange(of: viewModel?.loggedInUser) { _, user in
            if let user { coordinator.complete(user: user) }
        }
    }

    private func form(vm: LoginViewModel) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "building.2.crop.circle.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(.secondary)
                    .padding(.top, 32)

                VStack(spacing: 12) {
                    @Bindable var vm = vm
                    TextField("Email", text: $vm.email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .textFieldStyle(.roundedBorder)

                    SecureField("Пароль", text: $vm.password)
                        .textFieldStyle(.roundedBorder)

                    if let error = vm.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                Button {
                    Task { await vm.login() }
                } label: {
                    Group {
                        if vm.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Войти")
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(vm.isLoading)

                Divider()

                VStack(spacing: 8) {
                    Text("Нет аккаунта?")
                        .foregroundStyle(.secondary)
                    HStack(spacing: 16) {
                        Button("Покупатель") { coordinator.showRegisterBuyer() }
                            .buttonStyle(.bordered)
                        Button("Агент") { coordinator.showRegisterAgent() }
                            .buttonStyle(.bordered)
                    }
                }
            }
            .padding()
        }
    }
}
