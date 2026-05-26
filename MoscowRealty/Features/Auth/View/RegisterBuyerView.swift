import SwiftUI

struct RegisterBuyerView: View {
    @Environment(AuthCoordinator.self) private var coordinator
    @Environment(\.authService) private var authService
    @State private var viewModel: RegisterViewModel?

    var body: some View {
        Group {
            if let vm = viewModel {
                form(vm: vm)
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Регистрация")
        .task {
            let vm = RegisterViewModel(authService: authService)
            vm.role = .buyer
            viewModel = vm
        }
        .onChange(of: viewModel?.registeredUser) { _, user in
            if let user { coordinator.complete(user: user) }
        }
    }

    private func form(vm: RegisterViewModel) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                @Bindable var vm = vm
                TextField("Имя и фамилия", text: $vm.name)
                    .textFieldStyle(.roundedBorder)

                TextField("Email", text: $vm.email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textFieldStyle(.roundedBorder)

                SecureField("Пароль (минимум 6 символов)", text: $vm.password)
                    .textFieldStyle(.roundedBorder)

                if let error = vm.errorMessage {
                    Text(error).font(.caption).foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button {
                    Task { await vm.register() }
                } label: {
                    Group {
                        if vm.isLoading { ProgressView().tint(.white) }
                        else { Text("Создать аккаунт") }
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(vm.isLoading)
            }
            .padding()
        }
    }
}
