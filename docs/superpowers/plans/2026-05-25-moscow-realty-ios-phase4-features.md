# Moscow Realty iOS — Phase 4: Chat, Auth, Agent, Profile & Integration

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build Chat, Auth (login + registration), Agent (dashboard + listing form), and Profile views. Wire all coordinators together and run the full test suite.

**Prerequisite:** Phase 3 complete and all buyer flows working.

---

## File Map (this phase)

```
MoscowRealty/Features/
├── Chat/
│   ├── View/
│   │   ├── ChatListView.swift          (replace stub)
│   │   └── ChatDetailView.swift        (replace stub)
│   └── ViewModel/
│       ├── ChatListViewModel.swift     (new)
│       └── ChatDetailViewModel.swift   (new)
├── Auth/
│   ├── View/
│   │   ├── LoginView.swift             (replace stub)
│   │   ├── RegisterBuyerView.swift     (replace stub)
│   │   └── RegisterAgentView.swift     (replace stub)
│   └── ViewModel/
│       ├── LoginViewModel.swift        (new)
│       └── RegisterViewModel.swift     (new)
├── Agent/
│   ├── View/
│   │   ├── AgentDashboardView.swift    (new)
│   │   └── AddListingView.swift        (replace stub)
│   └── ViewModel/
│       ├── AgentDashboardViewModel.swift (new)
│       └── AddListingViewModel.swift   (new)
└── Profile/
    ├── View/
    │   └── ProfileView.swift           (replace stub)
    └── ViewModel/
        └── ProfileViewModel.swift      (new)

MoscowRealtyTests/ViewModels/
├── LoginViewModelTests.swift
├── RegisterViewModelTests.swift
├── AgentDashboardViewModelTests.swift
└── AddListingViewModelTests.swift
```

---

### Task 15: Chat feature

**Files:**
- Create: `MoscowRealty/Features/Chat/ViewModel/ChatListViewModel.swift`
- Create: `MoscowRealty/Features/Chat/ViewModel/ChatDetailViewModel.swift`
- Modify: `MoscowRealty/Features/Chat/View/ChatListView.swift`
- Modify: `MoscowRealty/Features/Chat/View/ChatDetailView.swift`

- [ ] **Step 1: Implement ChatListViewModel.swift**

`MoscowRealty/Features/Chat/ViewModel/ChatListViewModel.swift`:

```swift
import Observation
import Foundation

@Observable
@MainActor
final class ChatListViewModel {
    var state: ViewState<[ChatThread]> = .idle
    private let chatService: any ChatServiceProtocol
    private let userId: UUID

    init(chatService: any ChatServiceProtocol = MockChatService(),
         userId: UUID = UUID(uuidString: "20000000-0000-0000-0000-000000000001")!) {
        self.chatService = chatService
        self.userId = userId
    }

    func load() async {
        state = .loading
        let threads = await chatService.fetchThreads(for: userId)
        state = .loaded(threads.sorted { $0.lastMessageDate > $1.lastMessageDate })
    }
}
```

- [ ] **Step 2: Implement ChatDetailViewModel.swift**

`MoscowRealty/Features/Chat/ViewModel/ChatDetailViewModel.swift`:

```swift
import Observation
import Foundation

@Observable
@MainActor
final class ChatDetailViewModel {
    var thread: ChatThread
    var draftText: String = ""
    var isSending: Bool = false

    private let chatService: any ChatServiceProtocol
    private let senderId: UUID

    init(thread: ChatThread,
         chatService: any ChatServiceProtocol = MockChatService(),
         senderId: UUID = UUID(uuidString: "20000000-0000-0000-0000-000000000001")!) {
        self.thread = thread
        self.chatService = chatService
        self.senderId = senderId
    }

    func send() async {
        let text = draftText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        isSending = true
        draftText = ""
        let message = await chatService.sendMessage(text, threadId: thread.id, senderId: senderId)
        thread.messages.append(message)
        thread.lastMessage = message.text
        thread.lastMessageDate = message.date
        isSending = false
    }

    func markRead() async {
        await chatService.markAsRead(threadId: thread.id)
        thread.unreadCount = 0
    }
}
```

- [ ] **Step 3: Implement ChatListView.swift (replace stub)**

`MoscowRealty/Features/Chat/View/ChatListView.swift`:

```swift
import SwiftUI

struct ChatListView: View {
    @Environment(ChatCoordinator.self) private var coordinator
    @Environment(\.chatService) private var chatService
    @State private var viewModel: ChatListViewModel?

    var body: some View {
        Group {
            if let vm = viewModel {
                content(vm: vm)
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Чат")
        .task {
            let vm = ChatListViewModel(chatService: chatService)
            viewModel = vm
            await vm.load()
        }
    }

    @ViewBuilder
    private func content(vm: ChatListViewModel) -> some View {
        switch vm.state {
        case .idle, .loading:
            ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loaded(let threads):
            if threads.isEmpty {
                ContentUnavailableView(
                    "Нет сообщений",
                    systemImage: "bubble.left.and.bubble.right",
                    description: Text("Напишите агенту с карточки объявления")
                )
            } else {
                List(threads) { thread in
                    Button {
                        coordinator.showThread(thread)
                    } label: {
                        threadRow(thread)
                    }
                    .buttonStyle(.plain)
                }
                .listStyle(.plain)
            }
        case .error(let msg):
            Text(msg).foregroundStyle(.red).padding()
        }
    }

    private func threadRow(_ thread: ChatThread) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "house.circle.fill")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(thread.participantName)
                        .font(.headline)
                    Spacer()
                    Text(thread.lastMessageDate, style: .relative)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(thread.propertyTitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(thread.lastMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            if thread.unreadCount > 0 {
                Text("\(thread.unreadCount)")
                    .font(.caption2).bold()
                    .foregroundStyle(.white)
                    .padding(6)
                    .background(.red, in: Circle())
            }
        }
        .padding(.vertical, 4)
    }
}
```

- [ ] **Step 4: Implement ChatDetailView.swift (replace stub)**

`MoscowRealty/Features/Chat/View/ChatDetailView.swift`:

```swift
import SwiftUI

struct ChatDetailView: View {
    let thread: ChatThread
    @Environment(\.chatService) private var chatService
    @State private var viewModel: ChatDetailViewModel?

    var body: some View {
        Group {
            if let vm = viewModel {
                VStack(spacing: 0) {
                    messagesList(vm: vm)
                    Divider()
                    inputBar(vm: vm)
                }
            } else {
                ProgressView()
            }
        }
        .navigationTitle(thread.participantName)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            let vm = ChatDetailViewModel(thread: thread, chatService: chatService)
            viewModel = vm
            await vm.markRead()
        }
    }

    private func messagesList(vm: ChatDetailViewModel) -> some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(vm.thread.messages) { message in
                        messageBubble(message)
                            .id(message.id)
                    }
                }
                .padding()
            }
            .onChange(of: vm.thread.messages.count) { _, _ in
                if let last = vm.thread.messages.last {
                    withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
        }
    }

    private func messageBubble(_ message: ChatMessage) -> some View {
        HStack {
            if message.isFromCurrentUser { Spacer(minLength: 60) }
            Text(message.text)
                .padding(10)
                .background(message.isFromCurrentUser ? Color.accentColor : Color(.secondarySystemBackground))
                .foregroundStyle(message.isFromCurrentUser ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            if !message.isFromCurrentUser { Spacer(minLength: 60) }
        }
    }

    private func inputBar(vm: ChatDetailViewModel) -> some View {
        HStack(spacing: 8) {
            TextField("Сообщение...", text: Binding(
                get: { vm.draftText },
                set: { vm.draftText = $0 }
            ), axis: .vertical)
            .lineLimit(1...4)
            .padding(10)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20))

            Button {
                Task { await vm.send() }
            } label: {
                Image(systemName: "paperplane.fill")
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(vm.draftText.trimmingCharacters(in: .whitespaces).isEmpty ? Color.secondary : Color.accentColor)
                    .clipShape(Circle())
            }
            .disabled(vm.draftText.trimmingCharacters(in: .whitespaces).isEmpty || vm.isSending)
        }
        .padding(12)
    }
}
```

- [ ] **Step 5: Add chatService to EnvironmentValues**

The `ChatServiceKey` default is already in `AppEnvironment.swift`. Add chatService to `RootTabView` environment injection in `MoscowRealtyApp.swift`:

```swift
// MoscowRealtyApp.swift — no change needed; AppCoordinator holds chatService
// and environment keys provide defaults. Verify app builds.
```

- [ ] **Step 6: Build**

```bash
xcodebuild build \
  -project MoscowRealty.xcodeproj \
  -scheme MoscowRealty \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=17.5' \
  2>&1 | grep -E "(BUILD|error:)"
```

- [ ] **Step 7: Commit**

```bash
git add MoscowRealty/Features/Chat/
git commit -m "feat: add Chat feature — thread list, bubble conversation, mock messages"
```

---

### Task 16: Auth feature (Login + Registration)

**Files:**
- Create: `MoscowRealty/Features/Auth/ViewModel/LoginViewModel.swift`
- Create: `MoscowRealty/Features/Auth/ViewModel/RegisterViewModel.swift`
- Modify: `MoscowRealty/Features/Auth/View/LoginView.swift`
- Modify: `MoscowRealty/Features/Auth/View/RegisterBuyerView.swift`
- Modify: `MoscowRealty/Features/Auth/View/RegisterAgentView.swift`
- Test: `MoscowRealtyTests/ViewModels/LoginViewModelTests.swift`
- Test: `MoscowRealtyTests/ViewModels/RegisterViewModelTests.swift`

- [ ] **Step 1: Write failing tests**

`MoscowRealtyTests/ViewModels/LoginViewModelTests.swift`:

```swift
import XCTest
@testable import MoscowRealty

@MainActor
final class LoginViewModelTests: XCTestCase {

    func test_login_validCredentials_succeeds() async {
        let sut = LoginViewModel(authService: MockAuthService())
        sut.email = "buyer@test.ru"
        sut.password = "password"
        await sut.login()
        XCTAssertNil(sut.errorMessage)
        XCTAssertNotNil(sut.loggedInUser)
        XCTAssertEqual(sut.loggedInUser?.email, "buyer@test.ru")
    }

    func test_login_invalidCredentials_setsError() async {
        let sut = LoginViewModel(authService: MockAuthService())
        sut.email = "wrong@test.ru"
        sut.password = "wrongpass"
        await sut.login()
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertNil(sut.loggedInUser)
    }

    func test_login_emptyEmail_setsError() async {
        let sut = LoginViewModel(authService: MockAuthService())
        sut.email = ""
        sut.password = "password"
        await sut.login()
        XCTAssertNotNil(sut.errorMessage)
    }
}
```

`MoscowRealtyTests/ViewModels/RegisterViewModelTests.swift`:

```swift
import XCTest
@testable import MoscowRealty

@MainActor
final class RegisterViewModelTests: XCTestCase {

    func test_registerBuyer_validData_succeeds() async {
        let sut = RegisterViewModel(authService: MockAuthService())
        sut.name = "Тест Пользователь"
        sut.email = "newbuyer@test.ru"
        sut.password = "secure123"
        sut.role = .buyer
        await sut.register()
        XCTAssertNil(sut.errorMessage)
        XCTAssertNotNil(sut.registeredUser)
    }

    func test_registerBuyer_existingEmail_setsError() async {
        let sut = RegisterViewModel(authService: MockAuthService())
        sut.name = "Иван"
        sut.email = "buyer@test.ru"  // already seeded
        sut.password = "password"
        sut.role = .buyer
        await sut.register()
        XCTAssertNotNil(sut.errorMessage)
    }

    func test_registerAgent_withAgency_succeeds() async {
        let sut = RegisterViewModel(authService: MockAuthService())
        sut.name = "Агент Новый"
        sut.email = "newagent@test.ru"
        sut.password = "agent123"
        sut.phone = "+7 999 000-00-00"
        sut.agency = "АгентствоТест"
        sut.role = .agent
        await sut.register()
        XCTAssertNil(sut.errorMessage)
        XCTAssertEqual(sut.registeredUser?.agency, "АгентствоТест")
    }
}
```

- [ ] **Step 2: Run tests — expect FAIL**

```bash
xcodebuild test \
  -project MoscowRealty.xcodeproj \
  -scheme MoscowRealty \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=17.5' \
  -only-testing:MoscowRealtyTests/LoginViewModelTests \
  -only-testing:MoscowRealtyTests/RegisterViewModelTests \
  2>&1 | grep -E "(PASSED|FAILED|error:)"
```

- [ ] **Step 3: Implement LoginViewModel.swift**

`MoscowRealty/Features/Auth/ViewModel/LoginViewModel.swift`:

```swift
import Observation
import Foundation

@Observable
@MainActor
final class LoginViewModel {
    var email: String = ""
    var password: String = ""
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var loggedInUser: AppUser? = nil

    private let authService: any AuthServiceProtocol

    init(authService: any AuthServiceProtocol = MockAuthService()) {
        self.authService = authService
    }

    func login() async {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = AuthError.requiredFieldEmpty.errorDescription
            return
        }
        guard !password.isEmpty else {
            errorMessage = AuthError.requiredFieldEmpty.errorDescription
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            let user = try await authService.login(email: email.lowercased(), password: password)
            loggedInUser = user
        } catch let error as AuthError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = AuthError.networkError.errorDescription
        }
        isLoading = false
    }
}
```

- [ ] **Step 4: Implement RegisterViewModel.swift**

`MoscowRealty/Features/Auth/ViewModel/RegisterViewModel.swift`:

```swift
import Observation
import Foundation

@Observable
@MainActor
final class RegisterViewModel {
    var name: String = ""
    var email: String = ""
    var password: String = ""
    var phone: String = ""
    var agency: String = ""
    var licenseNumber: String = ""
    var role: UserRole = .buyer
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var registeredUser: AppUser? = nil

    private let authService: any AuthServiceProtocol

    init(authService: any AuthServiceProtocol = MockAuthService()) {
        self.authService = authService
    }

    func register() async {
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = AuthError.requiredFieldEmpty.errorDescription
            return
        }
        isLoading = true
        errorMessage = nil
        let user = AppUser(
            id: UUID(),
            name: name,
            email: email.lowercased(),
            phone: phone.isEmpty ? nil : phone,
            role: role,
            agency: agency.isEmpty ? nil : agency,
            licenseNumber: licenseNumber.isEmpty ? nil : licenseNumber
        )
        do {
            let registered = try await authService.register(user, password: password)
            registeredUser = registered
        } catch let error as AuthError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = AuthError.networkError.errorDescription
        }
        isLoading = false
    }
}
```

- [ ] **Step 5: Run tests — expect PASS**

```bash
xcodebuild test \
  -project MoscowRealty.xcodeproj \
  -scheme MoscowRealty \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=17.5' \
  -only-testing:MoscowRealtyTests/LoginViewModelTests \
  -only-testing:MoscowRealtyTests/RegisterViewModelTests \
  2>&1 | grep -E "(PASSED|FAILED|error:)"
```

- [ ] **Step 6: Implement LoginView.swift (replace stub)**

`MoscowRealty/Features/Auth/View/LoginView.swift`:

```swift
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
                    TextField("Email", text: Binding(get: { vm.email }, set: { vm.email = $0 }))
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .textFieldStyle(.roundedBorder)

                    SecureField("Пароль", text: Binding(get: { vm.password }, set: { vm.password = $0 }))
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
```

- [ ] **Step 7: Implement RegisterBuyerView.swift (replace stub)**

`MoscowRealty/Features/Auth/View/RegisterBuyerView.swift`:

```swift
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
                TextField("Имя и фамилия", text: Binding(get: { vm.name }, set: { vm.name = $0 }))
                    .textFieldStyle(.roundedBorder)

                TextField("Email", text: Binding(get: { vm.email }, set: { vm.email = $0 }))
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textFieldStyle(.roundedBorder)

                SecureField("Пароль (минимум 6 символов)", text: Binding(get: { vm.password }, set: { vm.password = $0 }))
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
```

- [ ] **Step 8: Implement RegisterAgentView.swift (replace stub)**

`MoscowRealty/Features/Auth/View/RegisterAgentView.swift`:

```swift
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
                Group {
                    TextField("Имя и фамилия", text: Binding(get: { vm.name }, set: { vm.name = $0 }))
                    TextField("Email", text: Binding(get: { vm.email }, set: { vm.email = $0 }))
                        .keyboardType(.emailAddress).autocapitalization(.none)
                    SecureField("Пароль", text: Binding(get: { vm.password }, set: { vm.password = $0 }))
                    TextField("Телефон", text: Binding(get: { vm.phone }, set: { vm.phone = $0 }))
                        .keyboardType(.phonePad)
                    TextField("Агентство (необязательно)", text: Binding(get: { vm.agency }, set: { vm.agency = $0 }))
                    TextField("Номер лицензии (необязательно)", text: Binding(get: { vm.licenseNumber }, set: { vm.licenseNumber = $0 }))
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
```

- [ ] **Step 9: Build**

```bash
xcodebuild build \
  -project MoscowRealty.xcodeproj \
  -scheme MoscowRealty \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=17.5' \
  2>&1 | grep -E "(BUILD|error:)"
```

- [ ] **Step 10: Commit**

```bash
git add MoscowRealty/Features/Auth/ \
        MoscowRealtyTests/ViewModels/LoginViewModelTests.swift \
        MoscowRealtyTests/ViewModels/RegisterViewModelTests.swift
git commit -m "feat: add Auth feature — login, buyer + agent registration with validation"
```

---

### Task 17: Agent feature (Dashboard + AddListingView)

**Files:**
- Create: `MoscowRealty/Features/Agent/ViewModel/AgentDashboardViewModel.swift`
- Create: `MoscowRealty/Features/Agent/ViewModel/AddListingViewModel.swift`
- Create: `MoscowRealty/Features/Agent/View/AgentDashboardView.swift`
- Modify: `MoscowRealty/Features/Agent/View/AddListingView.swift`
- Test: `MoscowRealtyTests/ViewModels/AgentDashboardViewModelTests.swift`
- Test: `MoscowRealtyTests/ViewModels/AddListingViewModelTests.swift`

- [ ] **Step 1: Write failing tests**

`MoscowRealtyTests/ViewModels/AgentDashboardViewModelTests.swift`:

```swift
import XCTest
@testable import MoscowRealty

@MainActor
final class AgentDashboardViewModelTests: XCTestCase {

    func test_load_returnsAgentListings() async {
        let sut = AgentDashboardViewModel(
            propertyService: MockPropertyService(),
            agentId: MockPropertyService.agentAlexId
        )
        await sut.load()
        guard case .loaded(let items) = sut.state else { XCTFail(); return }
        XCTAssertFalse(items.isEmpty)
        XCTAssertTrue(items.allSatisfy { $0.agentId == MockPropertyService.agentAlexId })
    }

    func test_delete_removesListing() async {
        let service = MockPropertyService()
        let sut = AgentDashboardViewModel(propertyService: service, agentId: MockPropertyService.agentAlexId)
        await sut.load()
        guard case .loaded(let items) = sut.state, let first = items.first else { XCTFail(); return }
        await sut.delete(id: first.id)
        guard case .loaded(let updated) = sut.state else { XCTFail(); return }
        XCTAssertFalse(updated.contains { $0.id == first.id })
    }
}
```

`MoscowRealtyTests/ViewModels/AddListingViewModelTests.swift`:

```swift
import XCTest
@testable import MoscowRealty

@MainActor
final class AddListingViewModelTests: XCTestCase {

    func test_submit_validData_succeeds() async {
        let service = MockPropertyService()
        let sut = AddListingViewModel(propertyService: service, agentId: MockPropertyService.agentAlexId)
        sut.title = "Тест квартира"
        sut.address = "ул. Тестовая, 1"
        sut.district = "Центральный"
        sut.area = 60
        sut.price = 10_000_000
        sut.rooms = 2
        await sut.submit()
        XCTAssertTrue(sut.isSubmitted)
        XCTAssertNil(sut.errorMessage)
    }

    func test_submit_missingTitle_setsError() async {
        let sut = AddListingViewModel(propertyService: MockPropertyService(), agentId: MockPropertyService.agentAlexId)
        sut.title = ""
        await sut.submit()
        XCTAssertFalse(sut.isSubmitted)
        XCTAssertNotNil(sut.errorMessage)
    }
}
```

- [ ] **Step 2: Run tests — expect FAIL**

```bash
xcodebuild test \
  -project MoscowRealty.xcodeproj \
  -scheme MoscowRealty \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=17.5' \
  -only-testing:MoscowRealtyTests/AgentDashboardViewModelTests \
  -only-testing:MoscowRealtyTests/AddListingViewModelTests \
  2>&1 | grep -E "(PASSED|FAILED|error:)"
```

- [ ] **Step 3: Implement AgentDashboardViewModel.swift**

`MoscowRealty/Features/Agent/ViewModel/AgentDashboardViewModel.swift`:

```swift
import Observation
import Foundation

@Observable
@MainActor
final class AgentDashboardViewModel {
    var state: ViewState<[Property]> = .idle
    private let propertyService: any PropertyServiceProtocol
    private let agentId: UUID

    init(propertyService: any PropertyServiceProtocol = MockPropertyService(),
         agentId: UUID = UUID()) {
        self.propertyService = propertyService
        self.agentId = agentId
    }

    func load() async {
        state = .loading
        let listings = await propertyService.fetchAgentListings(agentId: agentId)
        state = .loaded(listings)
    }

    func delete(id: UUID) async {
        await propertyService.deleteListing(id: id)
        await load()
    }
}
```

- [ ] **Step 4: Implement AddListingViewModel.swift**

`MoscowRealty/Features/Agent/ViewModel/AddListingViewModel.swift`:

```swift
import Observation
import Foundation

@Observable
@MainActor
final class AddListingViewModel {
    // Step 1 — type
    var propertyType: PropertyType = .apartment
    var listingType:  ListingType  = .buy
    // Step 2 — location
    var address: String = ""
    var district: String = ""
    var metro: String = ""
    // Step 3 — details
    var title: String = ""
    var area: Double = 0
    var price: Int = 0
    var rooms: Int = 1
    var floor: Int = 1
    var totalFloors: Int = 1
    var isNewBuilding: Bool = false
    var isHeated: Bool = false
    var description: String = ""
    // Step 4 — photos
    var selectedImageNames: [String] = []
    // Status
    var isSubmitting: Bool = false
    var isSubmitted: Bool = false
    var errorMessage: String? = nil

    let availableImages = ["apt_arbat_1","apt_arbat_2","apt_south_1","apt_south_2",
                           "apt_north_1","parking_center_1","parking_south_1","storage_1","storage_2"]

    private let propertyService: any PropertyServiceProtocol
    private let agentId: UUID

    init(propertyService: any PropertyServiceProtocol = MockPropertyService(),
         agentId: UUID = UUID()) {
        self.propertyService = propertyService
        self.agentId = agentId
    }

    func submit() async {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Укажите название объявления"
            return
        }
        guard !address.isEmpty else {
            errorMessage = "Укажите адрес"
            return
        }
        guard area > 0 else {
            errorMessage = "Укажите площадь"
            return
        }
        guard price > 0 else {
            errorMessage = "Укажите цену"
            return
        }
        isSubmitting = true
        errorMessage = nil
        let property = Property(
            id: UUID(),
            propertyType: propertyType,
            listingType: listingType,
            title: title,
            price: price,
            address: address,
            metro: metro.isEmpty ? nil : metro,
            district: district,
            area: area,
            imageNames: selectedImageNames.isEmpty ? ["placeholder"] : selectedImageNames,
            coordinates: Coordinates(latitude: 55.7558, longitude: 37.6176),
            agentId: agentId,
            description: description,
            rooms: propertyType == .apartment ? rooms : nil,
            floor: floor,
            totalFloors: propertyType == .apartment ? totalFloors : nil,
            isNewBuilding: isNewBuilding,
            isHeated: propertyType != .apartment ? isHeated : nil
        )
        await propertyService.addListing(property)
        isSubmitting = false
        isSubmitted = true
    }

    func populate(from existing: Property) {
        propertyType    = existing.propertyType
        listingType     = existing.listingType
        title           = existing.title
        address         = existing.address
        district        = existing.district
        metro           = existing.metro ?? ""
        area            = existing.area
        price           = existing.price
        rooms           = existing.rooms ?? 1
        floor           = existing.floor ?? 1
        totalFloors     = existing.totalFloors ?? 1
        isNewBuilding   = existing.isNewBuilding
        isHeated        = existing.isHeated ?? false
        description     = existing.description
        selectedImageNames = existing.imageNames
    }
}
```

- [ ] **Step 5: Run tests — expect PASS**

```bash
xcodebuild test \
  -project MoscowRealty.xcodeproj \
  -scheme MoscowRealty \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=17.5' \
  -only-testing:MoscowRealtyTests/AgentDashboardViewModelTests \
  -only-testing:MoscowRealtyTests/AddListingViewModelTests \
  2>&1 | grep -E "(PASSED|FAILED|error:)"
```

- [ ] **Step 6: Implement AgentDashboardView.swift**

`MoscowRealty/Features/Agent/View/AgentDashboardView.swift`:

```swift
import SwiftUI

struct AgentDashboardView: View {
    @Environment(ProfileCoordinator.self) private var coordinator
    @Environment(\.propertyService) private var propertyService
    @Environment(AppCoordinator.self) private var app
    @State private var viewModel: AgentDashboardViewModel?
    @State private var deleteTarget: Property?

    var body: some View {
        Group {
            if let vm = viewModel {
                content(vm: vm)
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Мои объявления")
        .task {
            guard let agentId = app.currentUser?.id else { return }
            let vm = AgentDashboardViewModel(propertyService: propertyService, agentId: agentId)
            viewModel = vm
            await vm.load()
        }
    }

    @ViewBuilder
    private func content(vm: AgentDashboardViewModel) -> some View {
        switch vm.state {
        case .idle, .loading:
            ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loaded(let listings):
            if listings.isEmpty {
                ContentUnavailableView(
                    "Нет объявлений",
                    systemImage: "doc.badge.plus",
                    description: Text("Разместите первое объявление через вкладку «Разместить»")
                )
            } else {
                List {
                    ForEach(listings) { property in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(property.title).font(.headline)
                            Text(property.formattedPrice).foregroundStyle(.secondary)
                            Text(property.address).font(.caption).foregroundStyle(.secondary)
                        }
                        .swipeActions(edge: .trailing) {
                            Button("Удалить", role: .destructive) {
                                deleteTarget = property
                            }
                            Button("Изменить") {
                                coordinator.showEditListing(property)
                            }
                            .tint(.blue)
                        }
                        .onTapGesture { coordinator.showPropertyDetail(property) }
                    }
                }
                .alert("Удалить объявление?", isPresented: Binding(
                    get: { deleteTarget != nil },
                    set: { if !$0 { deleteTarget = nil } }
                )) {
                    Button("Удалить", role: .destructive) {
                        if let id = deleteTarget?.id {
                            Task { await vm.delete(id: id) }
                        }
                        deleteTarget = nil
                    }
                    Button("Отмена", role: .cancel) { deleteTarget = nil }
                }
            }
        case .error(let msg):
            Text(msg).foregroundStyle(.red).padding()
        }
    }
}
```

- [ ] **Step 7: Implement AddListingView.swift (replace stub)**

`MoscowRealty/Features/Agent/View/AddListingView.swift`:

```swift
import SwiftUI

struct AddListingView: View {
    var existingProperty: Property? = nil
    @Environment(PostCoordinator.self) private var postCoordinator
    @Environment(\.propertyService) private var propertyService
    @Environment(AppCoordinator.self) private var app
    @State private var viewModel: AddListingViewModel?

    var body: some View {
        Group {
            if let vm = viewModel {
                if vm.isSubmitted {
                    successView(vm: vm)
                } else {
                    stepContent(vm: vm)
                }
            } else {
                ProgressView()
            }
        }
        .navigationTitle(existingProperty == nil ? "Разместить" : "Изменить")
        .task {
            let agentId = app.currentUser?.id ?? UUID()
            let vm = AddListingViewModel(propertyService: propertyService, agentId: agentId)
            if let existing = existingProperty { vm.populate(from: existing) }
            viewModel = vm
        }
    }

    @ViewBuilder
    private func stepContent(vm: AddListingViewModel) -> some View {
        switch postCoordinator.currentStep {
        case .typeSelection:  step1(vm: vm)
        case .location:       step2(vm: vm)
        case .details:        step3(vm: vm)
        case .photos:         step4(vm: vm)
        case .confirmation:   step5(vm: vm)
        }
    }

    // Step 1: type selection
    private func step1(vm: AddListingViewModel) -> some View {
        VStack(spacing: 24) {
            Text("Шаг 1 из 5: Тип объекта").font(.headline)
            Picker("Тип", selection: Binding(get: { vm.propertyType }, set: { vm.propertyType = $0 })) {
                ForEach(PropertyType.allCases, id: \.self) { Text($0.displayName).tag($0) }
            }.pickerStyle(.segmented)
            Picker("Сделка", selection: Binding(get: { vm.listingType }, set: { vm.listingType = $0 })) {
                ForEach(ListingType.allCases, id: \.self) { Text($0.displayName).tag($0) }
            }.pickerStyle(.segmented)
            Spacer()
            Button("Далее") { postCoordinator.nextStep() }
                .buttonStyle(.borderedProminent).frame(maxWidth: .infinity)
        }.padding()
    }

    // Step 2: location
    private func step2(vm: AddListingViewModel) -> some View {
        Form {
            Section("Шаг 2 из 5: Адрес") {
                TextField("Адрес", text: Binding(get: { vm.address }, set: { vm.address = $0 }))
                TextField("Район", text: Binding(get: { vm.district }, set: { vm.district = $0 }))
                TextField("Метро (необязательно)", text: Binding(get: { vm.metro }, set: { vm.metro = $0 }))
            }
            Section {
                HStack {
                    Button("Назад") { postCoordinator.previousStep() }.buttonStyle(.bordered)
                    Spacer()
                    Button("Далее") { postCoordinator.nextStep() }.buttonStyle(.borderedProminent)
                }
            }.listRowBackground(Color.clear)
        }
    }

    // Step 3: details
    private func step3(vm: AddListingViewModel) -> some View {
        Form {
            Section("Шаг 3 из 5: Детали") {
                TextField("Название объявления", text: Binding(get: { vm.title }, set: { vm.title = $0 }))
                HStack {
                    Text("Площадь, м²")
                    Spacer()
                    TextField("0", value: Binding(get: { vm.area }, set: { vm.area = $0 }), format: .number)
                        .keyboardType(.decimalPad).multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Цена, ₽")
                    Spacer()
                    TextField("0", value: Binding(get: { vm.price }, set: { vm.price = $0 }), format: .number)
                        .keyboardType(.numberPad).multilineTextAlignment(.trailing)
                }
                if vm.propertyType == .apartment {
                    Stepper("Комнат: \(vm.rooms)", value: Binding(get: { vm.rooms }, set: { vm.rooms = $0 }), in: 1...10)
                    HStack {
                        TextField("Этаж", value: Binding(get: { vm.floor }, set: { vm.floor = $0 }), format: .number).keyboardType(.numberPad)
                        Text("из")
                        TextField("Всего", value: Binding(get: { vm.totalFloors }, set: { vm.totalFloors = $0 }), format: .number).keyboardType(.numberPad)
                    }
                    Toggle("Новостройка", isOn: Binding(get: { vm.isNewBuilding }, set: { vm.isNewBuilding = $0 }))
                } else {
                    Toggle("Отапливаемое", isOn: Binding(get: { vm.isHeated }, set: { vm.isHeated = $0 }))
                }
                TextField("Описание", text: Binding(get: { vm.description }, set: { vm.description = $0 }), axis: .vertical)
                    .lineLimit(3...6)
            }
            if let err = vm.errorMessage {
                Section { Text(err).foregroundStyle(.red).font(.caption) }
            }
            Section {
                HStack {
                    Button("Назад") { postCoordinator.previousStep() }.buttonStyle(.bordered)
                    Spacer()
                    Button("Далее") { postCoordinator.nextStep() }.buttonStyle(.borderedProminent)
                }
            }.listRowBackground(Color.clear)
        }
    }

    // Step 4: photos (select from seeded Figma assets)
    private func step4(vm: AddListingViewModel) -> some View {
        VStack(spacing: 16) {
            Text("Шаг 4 из 5: Фотографии").font(.headline)
            Text("Выберите фотографии из каталога").foregroundStyle(.secondary)
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(vm.availableImages, id: \.self) { name in
                        let isSelected = vm.selectedImageNames.contains(name)
                        Image(name)
                            .resizable()
                            .aspectRatio(1, contentMode: .fill)
                            .clipped()
                            .overlay(isSelected ? Color.accentColor.opacity(0.4) : Color.clear)
                            .overlay(alignment: .topTrailing) {
                                if isSelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.white)
                                        .padding(4)
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .onTapGesture {
                                if isSelected {
                                    vm.selectedImageNames.removeAll { $0 == name }
                                } else {
                                    vm.selectedImageNames.append(name)
                                }
                            }
                    }
                }
            }
            HStack {
                Button("Назад") { postCoordinator.previousStep() }.buttonStyle(.bordered)
                Spacer()
                Button("Далее") { postCoordinator.nextStep() }.buttonStyle(.borderedProminent)
            }
        }.padding()
    }

    // Step 5: confirmation
    private func step5(vm: AddListingViewModel) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Шаг 5 из 5: Подтверждение").font(.headline)
                Group {
                    labelRow("Тип", vm.propertyType.displayName)
                    labelRow("Сделка", vm.listingType.displayName)
                    labelRow("Название", vm.title)
                    labelRow("Адрес", vm.address)
                    labelRow("Район", vm.district)
                    labelRow("Площадь", "\(Int(vm.area)) м²")
                    labelRow("Цена", "\(vm.price) ₽")
                    labelRow("Фото", "\(vm.selectedImageNames.count) шт.")
                }
                if let err = vm.errorMessage {
                    Text(err).foregroundStyle(.red).font(.caption)
                }
                HStack {
                    Button("Назад") { postCoordinator.previousStep() }.buttonStyle(.bordered)
                    Spacer()
                    Button {
                        Task { await vm.submit() }
                    } label: {
                        if vm.isSubmitting { ProgressView().tint(.white) }
                        else { Text("Разместить") }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(vm.isSubmitting)
                }
            }.padding()
        }
    }

    private func labelRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).foregroundStyle(.secondary)
            Spacer()
            Text(value).bold()
        }
    }

    private func successView(vm: AddListingViewModel) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(.green)
            Text("Объявление размещено!").font(.title2).bold()
            Button("Готово") { postCoordinator.resetToStart() }
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
```

- [ ] **Step 8: Build**

```bash
xcodebuild build \
  -project MoscowRealty.xcodeproj \
  -scheme MoscowRealty \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=17.5' \
  2>&1 | grep -E "(BUILD|error:)"
```

- [ ] **Step 9: Commit**

```bash
git add MoscowRealty/Features/Agent/ \
        MoscowRealtyTests/ViewModels/AgentDashboardViewModelTests.swift \
        MoscowRealtyTests/ViewModels/AddListingViewModelTests.swift
git commit -m "feat: add Agent dashboard, multi-step AddListingView, delete/edit listings"
```

---

### Task 18: ProfileView + ProfileViewModel + final integration

**Files:**
- Create: `MoscowRealty/Features/Profile/ViewModel/ProfileViewModel.swift`
- Modify: `MoscowRealty/Features/Profile/View/ProfileView.swift`

- [ ] **Step 1: Implement ProfileViewModel.swift**

`MoscowRealty/Features/Profile/ViewModel/ProfileViewModel.swift`:

```swift
import Observation
import Foundation

@Observable
@MainActor
final class ProfileViewModel {
    private let authService: any AuthServiceProtocol

    init(authService: any AuthServiceProtocol = MockAuthService()) {
        self.authService = authService
    }

    var currentUser: AppUser? { authService.currentUser }
    var isLoggedIn: Bool { authService.currentUser != nil }
    var isAgent: Bool { authService.currentUser?.isAgent == true }

    func logout() { authService.logout() }
}
```

- [ ] **Step 2: Implement ProfileView.swift (replace stub)**

`MoscowRealty/Features/Profile/View/ProfileView.swift`:

```swift
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
            Button("Войти / Зарегистрироваться") {
                coordinator.showLogin()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private func loggedInContent(vm: ProfileViewModel) -> some View {
        List {
            // User header
            Section {
                HStack(spacing: 16) {
                    Circle()
                        .fill(Color.accentColor.opacity(0.2))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Text(vm.currentUser?.initials ?? "")
                                .font(.title2).bold()
                                .foregroundStyle(.accentColor)
                        )
                    VStack(alignment: .leading, spacing: 4) {
                        Text(vm.currentUser?.name ?? "").font(.headline)
                        Text(vm.currentUser?.email ?? "").font(.caption).foregroundStyle(.secondary)
                        if vm.isAgent {
                            Label("Агент", systemImage: "briefcase.fill")
                                .font(.caption)
                                .foregroundStyle(.accentColor)
                        }
                    }
                }
            }

            // Favorites section (buyer)
            Section("Избранное") {
                NavigationLink("Мои избранные объявления") {
                    FavoritesView()
                        .environment(coordinator)
                        .environment(\.propertyService, propertyService)
                        .environment(\.favoritesService, favoritesService)
                }
            }

            // Agent section
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

            // Logout
            Section {
                Button("Выйти", role: .destructive) {
                    vm.logout()
                }
            }
        }
    }
}
```

- [ ] **Step 3: Wire AuthCoordinator completion in AuthFlowView**

Update `MoscowRealty/App/AuthFlowView.swift` to call `ProfileCoordinator.isAuthPresented = false` on auth success:

```swift
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
```

- [ ] **Step 4: Add authService to EnvironmentValues (verify)**

Confirm `authService` environment key is in `AppEnvironment.swift` (added in Task 4). No change needed if already present.

- [ ] **Step 5: Run full test suite**

```bash
xcodebuild test \
  -project MoscowRealty.xcodeproj \
  -scheme MoscowRealty \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=17.5' \
  -only-testing:MoscowRealtyTests \
  2>&1 | grep -E "(PASSED|FAILED|Test Suite.*passed|Test Suite.*failed|error:)"
```

Expected output:
```
Test Suite 'PropertyModelTests' passed
Test Suite 'AuthModelTests' passed
Test Suite 'FavoritesServiceTests' passed
Test Suite 'HomeViewModelTests' passed
Test Suite 'CatalogViewModelTests' passed
Test Suite 'SearchViewModelTests' passed
Test Suite 'LoginViewModelTests' passed
Test Suite 'RegisterViewModelTests' passed
Test Suite 'AgentDashboardViewModelTests' passed
Test Suite 'AddListingViewModelTests' passed
```

- [ ] **Step 6: Build and run on simulator — smoke test all tabs**

```bash
xcodebuild build \
  -project MoscowRealty.xcodeproj \
  -scheme MoscowRealty \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=17.5' \
  2>&1 | grep -E "(BUILD|error:)"
```

Launch in simulator. Verify:
- Главная: property cards load, tap navigates to detail
- Поиск: search bar works, filter sheet opens
- Разместить: shows auth gate (not logged in), multi-step form (after login as agent)
- Чат: thread list with seed messages
- Профиль: login button when logged out; favorites + agent dashboard after login

- [ ] **Step 7: Final commit**

```bash
git add MoscowRealty/Features/Profile/ \
        MoscowRealty/App/AuthFlowView.swift
git commit -m "feat: add ProfileView, ProfileViewModel, AuthFlowView wiring — full app complete"
```

---

**All 4 phases complete.**

## Summary

| Phase | Tasks | Deliverable |
|-------|-------|-------------|
| Phase 1 | 1–7  | Project, models, services, mock data |
| Phase 2 | 8–9  | All coordinators, 5-tab shell |
| Phase 3 | 10–14 | Home, Catalog, Detail, Search, Favorites |
| Phase 4 | 15–18 | Chat, Auth, Agent, Profile, full integration |

**Tests:** 10 test suites covering all ViewModels and FavoritesService.  
**Mock data:** 10 seed properties across 3 types, 3 districts, 2 listing types.  
**Zero external dependencies** — Apple frameworks only.
