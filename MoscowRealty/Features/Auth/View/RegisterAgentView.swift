import SwiftUI

struct RegisterAgentView: View {
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
        .navigationTitle("Регистрация агента")
        .task {
            let vm = RegisterViewModel(authService: authService)
            vm.role = .agent
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
                Group {
                    TextField("Имя и фамилия", text: $vm.name)
                    TextField("Email", text: $vm.email)
                        .keyboardType(.emailAddress).autocapitalization(.none)
                    SecureField("Пароль", text: $vm.password)
                    TextField("Телефон", text: $vm.phone)
                        .keyboardType(.phonePad)
                    TextField("Агентство (необязательно)", text: $vm.agency)
                    TextField("Номер лицензии (необязательно)", text: $vm.licenseNumber)
                }
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
                        else { Text("Зарегистрироваться как агент") }
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
