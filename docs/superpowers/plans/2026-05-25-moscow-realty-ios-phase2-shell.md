# Moscow Realty iOS — Phase 2: Navigation Shell

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build all coordinators and the root tab bar so the app launches with five tabs and NavigationStack-based navigation ready.

**Prerequisite:** Phase 1 complete and all tests passing.

---

## File Map (this phase)

```
MoscowRealty/
├── App/
│   └── MoscowRealtyApp.swift              (replace stub)
├── Coordinators/
│   ├── AppCoordinator.swift
│   ├── MainCoordinator.swift
│   ├── SearchCoordinator.swift
│   ├── PostCoordinator.swift
│   ├── ChatCoordinator.swift
│   ├── AuthCoordinator.swift
│   └── ProfileCoordinator.swift
└── Features/
    └── (root tab view lives in App/)
        └── RootTabView.swift              (inside App/ folder)
```

---

### Task 8: AppCoordinator + all feature coordinators

**Files:**
- Create: `MoscowRealty/Coordinators/AppCoordinator.swift`
- Create: `MoscowRealty/Coordinators/MainCoordinator.swift`
- Create: `MoscowRealty/Coordinators/SearchCoordinator.swift`
- Create: `MoscowRealty/Coordinators/PostCoordinator.swift`
- Create: `MoscowRealty/Coordinators/ChatCoordinator.swift`
- Create: `MoscowRealty/Coordinators/AuthCoordinator.swift`
- Create: `MoscowRealty/Coordinators/ProfileCoordinator.swift`

- [ ] **Step 1: Implement AppCoordinator.swift**

`MoscowRealty/Coordinators/AppCoordinator.swift`:

```swift
import Observation
import Foundation

@Observable
final class AppCoordinator {
    let propertyService: any PropertyServiceProtocol
    let authService:     any AuthServiceProtocol
    let chatService:     any ChatServiceProtocol
    let favoritesService: any FavoritesServiceProtocol

    var currentUser: AppUser? { authService.currentUser }

    init(
        propertyService:  any PropertyServiceProtocol  = MockPropertyService(),
        authService:      any AuthServiceProtocol      = MockAuthService(),
        chatService:      any ChatServiceProtocol      = MockChatService(),
        favoritesService: any FavoritesServiceProtocol = FavoritesService()
    ) {
        self.propertyService  = propertyService
        self.authService      = authService
        self.chatService      = chatService
        self.favoritesService = favoritesService
    }
}
```

- [ ] **Step 2: Implement MainCoordinator.swift**

`MoscowRealty/Coordinators/MainCoordinator.swift`:

```swift
import Observation
import SwiftUI

// Destinations reachable from the Главная tab
enum MainDestination: Hashable {
    case propertyDetail(Property)
    case catalogMap([Property])
}

@Observable
final class MainCoordinator {
    var path = NavigationPath()

    func showDetail(_ property: Property) {
        path.append(MainDestination.propertyDetail(property))
    }

    func showMap(_ properties: [Property]) {
        path.append(MainDestination.catalogMap(properties))
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
    }
}
```

- [ ] **Step 3: Implement SearchCoordinator.swift**

`MoscowRealty/Coordinators/SearchCoordinator.swift`:

```swift
import Observation
import SwiftUI

enum SearchDestination: Hashable {
    case propertyDetail(Property)
}

@Observable
final class SearchCoordinator {
    var path = NavigationPath()
    var isFilterSheetPresented = false

    func showDetail(_ property: Property) {
        path.append(SearchDestination.propertyDetail(property))
    }

    func showFilter() {
        isFilterSheetPresented = true
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
}
```

- [ ] **Step 4: Implement PostCoordinator.swift**

`MoscowRealty/Coordinators/PostCoordinator.swift`:

```swift
import Observation
import SwiftUI

enum PostStep: Int, CaseIterable {
    case typeSelection = 0
    case location      = 1
    case details       = 2
    case photos        = 3
    case confirmation  = 4
}

@Observable
final class PostCoordinator {
    var path = NavigationPath()
    var isAuthRequired = false
    var currentStep: PostStep = .typeSelection

    func requireAuth() { isAuthRequired = true }

    func nextStep() {
        let allSteps = PostStep.allCases
        if let idx = allSteps.firstIndex(of: currentStep),
           idx + 1 < allSteps.count {
            currentStep = allSteps[idx + 1]
        }
    }

    func previousStep() {
        let allSteps = PostStep.allCases
        if let idx = allSteps.firstIndex(of: currentStep), idx > 0 {
            currentStep = allSteps[idx - 1]
        }
    }

    func resetToStart() {
        currentStep = .typeSelection
        path = NavigationPath()
    }
}
```

- [ ] **Step 5: Implement ChatCoordinator.swift**

`MoscowRealty/Coordinators/ChatCoordinator.swift`:

```swift
import Observation
import SwiftUI

enum ChatDestination: Hashable {
    case threadDetail(ChatThread)
}

@Observable
final class ChatCoordinator {
    var path = NavigationPath()

    func showThread(_ thread: ChatThread) {
        path.append(ChatDestination.threadDetail(thread))
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
}
```

- [ ] **Step 6: Implement AuthCoordinator.swift**

`MoscowRealty/Coordinators/AuthCoordinator.swift`:

```swift
import Observation
import SwiftUI

enum AuthDestination: Hashable {
    case registerBuyer
    case registerAgent
}

@Observable
final class AuthCoordinator {
    var path = NavigationPath()
    var onSuccess: ((AppUser) -> Void)?

    func showRegisterBuyer() {
        path.append(AuthDestination.registerBuyer)
    }

    func showRegisterAgent() {
        path.append(AuthDestination.registerAgent)
    }

    func complete(user: AppUser) {
        onSuccess?(user)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
}
```

- [ ] **Step 7: Implement ProfileCoordinator.swift**

`MoscowRealty/Coordinators/ProfileCoordinator.swift`:

```swift
import Observation
import SwiftUI

enum ProfileDestination: Hashable {
    case propertyDetail(Property)
    case editListing(Property)
}

@Observable
final class ProfileCoordinator {
    var path = NavigationPath()
    var isAuthPresented = false

    func showLogin() { isAuthPresented = true }

    func showPropertyDetail(_ property: Property) {
        path.append(ProfileDestination.propertyDetail(property))
    }

    func showEditListing(_ property: Property) {
        path.append(ProfileDestination.editListing(property))
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
}
```

- [ ] **Step 8: Build to verify**

```bash
xcodebuild build \
  -project MoscowRealty.xcodeproj \
  -scheme MoscowRealty \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=17.5' \
  2>&1 | grep -E "(BUILD|error:)"
```

Expected: `BUILD SUCCEEDED`

- [ ] **Step 9: Commit**

```bash
git add MoscowRealty/Coordinators/
git commit -m "feat: add all feature coordinators with NavigationPath"
```

---

### Task 9: RootTabView + App entry point

**Files:**
- Create: `MoscowRealty/App/RootTabView.swift`
- Modify: `MoscowRealty/App/MoscowRealtyApp.swift`

Note: Feature views (`HomeView`, `SearchView`, etc.) are implemented in Phase 3 & 4. For now, each tab shows a placeholder `Text` view. The coordinator wiring is real — just the leaf views are stubs.

- [ ] **Step 1: Implement RootTabView.swift**

`MoscowRealty/App/RootTabView.swift`:

```swift
import SwiftUI

struct RootTabView: View {
    @Environment(AppCoordinator.self) private var app
    @State private var mainCoordinator    = MainCoordinator()
    @State private var searchCoordinator  = SearchCoordinator()
    @State private var postCoordinator    = PostCoordinator()
    @State private var chatCoordinator    = ChatCoordinator()
    @State private var profileCoordinator = ProfileCoordinator()
    @State private var selectedTab        = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            mainTab
                .tabItem { Label("Главная",    systemImage: "house") }
                .tag(0)

            searchTab
                .tabItem { Label("Поиск",      systemImage: "magnifyingglass") }
                .tag(1)

            postTab
                .tabItem { Label("Разместить", systemImage: "doc.badge.plus") }
                .tag(2)

            chatTab
                .tabItem { Label("Чат",        systemImage: "message") }
                .tag(3)

            profileTab
                .tabItem { Label("Профиль",    systemImage: "person") }
                .tag(4)
        }
        .tint(.primary)
    }

    // MARK: - Tabs

    private var mainTab: some View {
        NavigationStack(path: Bindable(mainCoordinator).path) {
            HomeView()
                .navigationDestination(for: MainDestination.self) { destination in
                    switch destination {
                    case .propertyDetail(let property):
                        PropertyDetailView(property: property)
                    case .catalogMap(let properties):
                        CatalogMapView(properties: properties)
                    }
                }
        }
        .environment(mainCoordinator)
    }

    private var searchTab: some View {
        NavigationStack(path: Bindable(searchCoordinator).path) {
            SearchView()
                .navigationDestination(for: SearchDestination.self) { destination in
                    switch destination {
                    case .propertyDetail(let property):
                        PropertyDetailView(property: property)
                    }
                }
                .sheet(isPresented: Bindable(searchCoordinator).isFilterSheetPresented) {
                    SearchFilterSheet()
                        .environment(searchCoordinator)
                }
        }
        .environment(searchCoordinator)
    }

    private var postTab: some View {
        NavigationStack {
            Group {
                if app.currentUser?.isAgent == true {
                    AddListingView()
                        .environment(postCoordinator)
                } else {
                    PostAuthGateView()
                        .environment(postCoordinator)
                }
            }
        }
        .environment(postCoordinator)
    }

    private var chatTab: some View {
        NavigationStack(path: Bindable(chatCoordinator).path) {
            ChatListView()
                .navigationDestination(for: ChatDestination.self) { destination in
                    switch destination {
                    case .threadDetail(let thread):
                        ChatDetailView(thread: thread)
                    }
                }
        }
        .environment(chatCoordinator)
    }

    private var profileTab: some View {
        NavigationStack(path: Bindable(profileCoordinator).path) {
            ProfileView()
                .navigationDestination(for: ProfileDestination.self) { destination in
                    switch destination {
                    case .propertyDetail(let property):
                        PropertyDetailView(property: property)
                    case .editListing(let property):
                        AddListingView(existingProperty: property)
                    }
                }
                .sheet(isPresented: Bindable(profileCoordinator).isAuthPresented) {
                    AuthFlowView()
                        .environment(profileCoordinator)
                }
        }
        .environment(profileCoordinator)
    }
}
```

- [ ] **Step 2: Create stub views for unbuilt features**

These stubs let the project compile while Phase 3 & 4 build out the real views. Create each file if it doesn't exist yet:

`MoscowRealty/Features/Home/View/HomeView.swift`:
```swift
import SwiftUI
struct HomeView: View {
    var body: some View { Text("Главная") }
}
```

`MoscowRealty/Features/Catalog/View/CatalogMapView.swift`:
```swift
import SwiftUI
struct CatalogMapView: View {
    let properties: [Property]
    var body: some View { Text("Карта") }
}
```

`MoscowRealty/Features/PropertyDetail/View/PropertyDetailView.swift`:
```swift
import SwiftUI
struct PropertyDetailView: View {
    let property: Property
    var body: some View { Text(property.title) }
}
```

`MoscowRealty/Features/Search/View/SearchView.swift`:
```swift
import SwiftUI
struct SearchView: View {
    var body: some View { Text("Поиск") }
}
```

`MoscowRealty/Features/Search/View/SearchFilterSheet.swift`:
```swift
import SwiftUI
struct SearchFilterSheet: View {
    var body: some View { Text("Фильтры") }
}
```

`MoscowRealty/Features/Agent/View/AddListingView.swift`:
```swift
import SwiftUI
struct AddListingView: View {
    var existingProperty: Property? = nil
    var body: some View { Text("Разместить объявление") }
}
```

`MoscowRealty/Features/Chat/View/ChatListView.swift`:
```swift
import SwiftUI
struct ChatListView: View {
    var body: some View { Text("Чат") }
}
```

`MoscowRealty/Features/Chat/View/ChatDetailView.swift`:
```swift
import SwiftUI
struct ChatDetailView: View {
    let thread: ChatThread
    var body: some View { Text(thread.propertyTitle) }
}
```

`MoscowRealty/Features/Profile/View/ProfileView.swift`:
```swift
import SwiftUI
struct ProfileView: View {
    var body: some View { Text("Профиль") }
}
```

`MoscowRealty/App/PostAuthGateView.swift`:
```swift
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
```

`MoscowRealty/App/AuthFlowView.swift`:
```swift
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
```

`MoscowRealty/Features/Auth/View/LoginView.swift`:
```swift
import SwiftUI
struct LoginView: View {
    var body: some View { Text("Вход") }
}
```

`MoscowRealty/Features/Auth/View/RegisterBuyerView.swift`:
```swift
import SwiftUI
struct RegisterBuyerView: View {
    var body: some View { Text("Регистрация покупателя") }
}
```

`MoscowRealty/Features/Auth/View/RegisterAgentView.swift`:
```swift
import SwiftUI
struct RegisterAgentView: View {
    var body: some View { Text("Регистрация агента") }
}
```

- [ ] **Step 3: Update MoscowRealtyApp.swift**

`MoscowRealty/App/MoscowRealtyApp.swift`:

```swift
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
```

- [ ] **Step 4: Build and run on simulator**

```bash
xcodebuild build \
  -project MoscowRealty.xcodeproj \
  -scheme MoscowRealty \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=17.5' \
  2>&1 | grep -E "(BUILD|error:)"
```

Expected: `BUILD SUCCEEDED`. Launch in simulator and verify the 5-tab bar appears with Russian labels.

- [ ] **Step 5: Run all tests**

```bash
xcodebuild test \
  -project MoscowRealty.xcodeproj \
  -scheme MoscowRealty \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=17.5' \
  -only-testing:MoscowRealtyTests \
  2>&1 | grep -E "(PASSED|FAILED|Test Suite.*passed|error:)"
```

Expected: all 3 test suites pass.

- [ ] **Step 6: Commit**

```bash
git add MoscowRealty/App/ MoscowRealty/Coordinators/ MoscowRealty/Features/
git commit -m "feat: add RootTabView, all coordinators, stub views — app launches with 5 tabs"
```

---

**Phase 2 complete.** Proceed to `2026-05-25-moscow-realty-ios-phase3-buyer.md`.
