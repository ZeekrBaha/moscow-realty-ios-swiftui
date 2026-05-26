# Moscow Realty iOS — Phase 1: Foundation

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create the Xcode project, all data models, service protocols, and mock service implementations with seed data.

**Architecture:** MVVM-C with NavigationPath coordinators. `@Observable` throughout (iOS 17). `AppCoordinator` holds all service instances.

**Tech Stack:** SwiftUI, iOS 17, @Observable, XCTest, xcodegen

**Phases:** This is Phase 1 of 4. Complete this before starting Phase 2.

---

## File Map (this phase)

```
project.yml
MoscowRealty/
├── App/
│   └── MoscowRealtyApp.swift                  (stub — wired up in Phase 2)
├── Core/
│   ├── Models/
│   │   └── Property.swift                     (Property struct + PropertyType + ListingType + Coordinates)
│   ├── ViewState.swift                        (ViewState<T> enum)
│   └── Environment/
│       └── AppEnvironment.swift               (EnvironmentKey extensions)
├── Features/
│   ├── Auth/
│   │   └── Model/
│   │       ├── AppUser.swift
│   │       └── AuthError.swift
│   ├── Chat/
│   │   └── Model/
│   │       ├── ChatThread.swift
│   │       └── ChatMessage.swift
│   └── Search/
│       └── Model/
│           └── SearchFilter.swift
└── Services/
    ├── PropertyServiceProtocol.swift
    ├── MockPropertyService.swift
    ├── AuthServiceProtocol.swift
    ├── MockAuthService.swift
    ├── ChatServiceProtocol.swift
    ├── MockChatService.swift
    ├── FavoritesServiceProtocol.swift
    └── FavoritesService.swift
MoscowRealtyTests/
└── Services/
    └── FavoritesServiceTests.swift
```

---

### Task 1: Project setup with xcodegen

**Files:**
- Create: `project.yml`
- Create: `MoscowRealty/App/MoscowRealtyApp.swift`
- Create: `MoscowRealtyTests/MoscowRealtyTests.swift`

- [ ] **Step 1: Install xcodegen if needed**

```bash
which xcodegen || brew install xcodegen
```

Expected: path printed or brew installs it.

- [ ] **Step 2: Create project.yml**

Create `project.yml` at repo root:

```yaml
name: MoscowRealty
options:
  bundleIdPrefix: com.baha
  deploymentTarget:
    iOS: "17.0"
  defaultConfig: Debug
settings:
  SWIFT_VERSION: "5.9"
  IPHONEOS_DEPLOYMENT_TARGET: "17.0"
targets:
  MoscowRealty:
    type: application
    platform: iOS
    sources:
      - path: MoscowRealty
    settings:
      PRODUCT_BUNDLE_IDENTIFIER: com.baha.moscowrealty
      INFOPLIST_FILE: MoscowRealty/Info.plist
    info:
      path: MoscowRealty/Info.plist
      properties:
        CFBundleName: МоскваРиелти
        CFBundleDisplayName: МоскваРиелти
        UILaunchScreen: {}
        NSLocationWhenInUseUsageDescription: "Для отображения квартир на карте"
  MoscowRealtyTests:
    type: bundle.unit-test
    platform: iOS
    sources:
      - path: MoscowRealtyTests
    dependencies:
      - target: MoscowRealty
    settings:
      PRODUCT_BUNDLE_IDENTIFIER: com.baha.moscowrealtyTests
```

- [ ] **Step 3: Create source directories**

```bash
mkdir -p MoscowRealty/App
mkdir -p MoscowRealty/Coordinators
mkdir -p MoscowRealty/Core/Models
mkdir -p MoscowRealty/Core/Environment
mkdir -p MoscowRealty/Features/Home/View
mkdir -p MoscowRealty/Features/Home/ViewModel
mkdir -p MoscowRealty/Features/Home/Model
mkdir -p MoscowRealty/Features/Catalog/View
mkdir -p MoscowRealty/Features/Catalog/ViewModel
mkdir -p MoscowRealty/Features/Catalog/Model
mkdir -p MoscowRealty/Features/PropertyDetail/View
mkdir -p MoscowRealty/Features/PropertyDetail/ViewModel
mkdir -p MoscowRealty/Features/PropertyDetail/Model
mkdir -p MoscowRealty/Features/Search/View
mkdir -p MoscowRealty/Features/Search/ViewModel
mkdir -p MoscowRealty/Features/Search/Model
mkdir -p MoscowRealty/Features/Favorites/View
mkdir -p MoscowRealty/Features/Favorites/ViewModel
mkdir -p MoscowRealty/Features/Favorites/Model
mkdir -p MoscowRealty/Features/Chat/View
mkdir -p MoscowRealty/Features/Chat/ViewModel
mkdir -p MoscowRealty/Features/Chat/Model
mkdir -p MoscowRealty/Features/Auth/View
mkdir -p MoscowRealty/Features/Auth/ViewModel
mkdir -p MoscowRealty/Features/Auth/Model
mkdir -p MoscowRealty/Features/Agent/View
mkdir -p MoscowRealty/Features/Agent/ViewModel
mkdir -p MoscowRealty/Features/Agent/Model
mkdir -p MoscowRealty/Features/Profile/View
mkdir -p MoscowRealty/Features/Profile/ViewModel
mkdir -p MoscowRealty/Features/Profile/Model
mkdir -p MoscowRealty/Services
mkdir -p MoscowRealty/Resources
mkdir -p MoscowRealtyTests/Services
mkdir -p MoscowRealtyTests/ViewModels
```

- [ ] **Step 4: Create stub app entry point**

`MoscowRealty/App/MoscowRealtyApp.swift`:

```swift
import SwiftUI

@main
struct MoscowRealtyApp: App {
    var body: some Scene {
        WindowGroup {
            Text("МоскваРиелти")
        }
    }
}
```

- [ ] **Step 5: Create test stub**

`MoscowRealtyTests/MoscowRealtyTests.swift`:

```swift
import XCTest
@testable import MoscowRealty
```

- [ ] **Step 6: Generate Xcode project and build**

```bash
xcodegen generate
xcodebuild build \
  -project MoscowRealty.xcodeproj \
  -scheme MoscowRealty \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=17.5' \
  2>&1 | grep -E "(BUILD|error:)"
```

Expected: `BUILD SUCCEEDED`

- [ ] **Step 7: Commit**

```bash
git add project.yml MoscowRealty/ MoscowRealtyTests/
git commit -m "feat: scaffold Xcode project with xcodegen"
```

---

### Task 2: Core models

**Files:**
- Create: `MoscowRealty/Core/Models/Property.swift`
- Create: `MoscowRealty/Core/ViewState.swift`

- [ ] **Step 1: Write the failing test**

`MoscowRealtyTests/ViewModels/PropertyModelTests.swift`:

```swift
import XCTest
@testable import MoscowRealty

final class PropertyModelTests: XCTestCase {

    func test_property_defaultsCorrect() {
        let coords = Coordinates(latitude: 55.7558, longitude: 37.6176)
        let property = Property(
            id: UUID(),
            propertyType: .apartment,
            listingType: .buy,
            title: "3-комн. квартира",
            price: 15_000_000,
            address: "ул. Арбат, 1",
            metro: "Арбатская",
            district: "Центральный",
            area: 85.0,
            imageNames: ["apt_center_1"],
            coordinates: coords,
            agentId: UUID(),
            description: "Просторная квартира",
            rooms: 3,
            floor: 5,
            totalFloors: 12,
            isNewBuilding: true,
            isHeated: nil
        )
        XCTAssertEqual(property.propertyType, .apartment)
        XCTAssertEqual(property.listingType, .buy)
        XCTAssertEqual(property.rooms, 3)
        XCTAssertEqual(property.price, 15_000_000)
    }

    func test_propertyType_allCasesExist() {
        XCTAssertEqual(PropertyType.allCases.count, 3)
        XCTAssertTrue(PropertyType.allCases.contains(.apartment))
        XCTAssertTrue(PropertyType.allCases.contains(.parking))
        XCTAssertTrue(PropertyType.allCases.contains(.storage))
    }

    func test_viewState_loadedContainsValue() {
        let state: ViewState<[String]> = .loaded(["a", "b"])
        guard case .loaded(let items) = state else {
            XCTFail("Expected .loaded")
            return
        }
        XCTAssertEqual(items, ["a", "b"])
    }
}
```

- [ ] **Step 2: Run test — expect FAIL (types not defined)**

```bash
xcodebuild test \
  -project MoscowRealty.xcodeproj \
  -scheme MoscowRealty \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=17.5' \
  -only-testing:MoscowRealtyTests/PropertyModelTests \
  2>&1 | grep -E "(PASSED|FAILED|error:)"
```

Expected: compile error — `Property`, `Coordinates`, `PropertyType`, `ViewState` not defined.

- [ ] **Step 3: Implement Property.swift**

`MoscowRealty/Core/Models/Property.swift`:

```swift
import Foundation

enum PropertyType: String, CaseIterable, Codable {
    case apartment = "apartment"
    case parking   = "parking"
    case storage   = "storage"

    var displayName: String {
        switch self {
        case .apartment: return "Квартира"
        case .parking:   return "Машиноместо"
        case .storage:   return "Кладовая"
        }
    }
}

enum ListingType: String, CaseIterable, Codable {
    case buy  = "buy"
    case rent = "rent"

    var displayName: String {
        switch self {
        case .buy:  return "Купить"
        case .rent: return "Аренда"
        }
    }
}

struct Coordinates: Codable, Equatable {
    let latitude:  Double
    let longitude: Double
}

struct Property: Identifiable, Codable, Equatable {
    let id:           UUID
    var propertyType: PropertyType
    var listingType:  ListingType
    var title:        String
    var price:        Int
    var address:      String
    var metro:        String?
    var district:     String
    var area:         Double
    var imageNames:   [String]
    var coordinates:  Coordinates
    var agentId:      UUID
    var description:  String
    // Apartment-only
    var rooms:        Int?
    var floor:        Int?
    var totalFloors:  Int?
    var isNewBuilding: Bool
    // Parking & Storage
    var isHeated:     Bool?

    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        let formatted = formatter.string(from: NSNumber(value: price)) ?? "\(price)"
        return listingType == .rent ? "\(formatted) ₽/мес" : "\(formatted) ₽"
    }

    var formattedArea: String { "\(Int(area)) м²" }
}
```

- [ ] **Step 4: Implement ViewState.swift**

`MoscowRealty/Core/ViewState.swift`:

```swift
enum ViewState<T> {
    case idle
    case loading
    case loaded(T)
    case error(String)

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var value: T? {
        if case .loaded(let v) = self { return v }
        return nil
    }
}
```

- [ ] **Step 5: Run test — expect PASS**

```bash
xcodebuild test \
  -project MoscowRealty.xcodeproj \
  -scheme MoscowRealty \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=17.5' \
  -only-testing:MoscowRealtyTests/PropertyModelTests \
  2>&1 | grep -E "(PASSED|FAILED|error:)"
```

Expected: `Test Suite 'PropertyModelTests' passed`

- [ ] **Step 6: Commit**

```bash
git add MoscowRealty/Core/ MoscowRealtyTests/ViewModels/
git commit -m "feat: add Property model, PropertyType, ListingType, Coordinates, ViewState"
```

---

### Task 3: Auth, Chat, and Search models

**Files:**
- Create: `MoscowRealty/Features/Auth/Model/AppUser.swift`
- Create: `MoscowRealty/Features/Auth/Model/AuthError.swift`
- Create: `MoscowRealty/Features/Chat/Model/ChatThread.swift`
- Create: `MoscowRealty/Features/Chat/Model/ChatMessage.swift`
- Create: `MoscowRealty/Features/Search/Model/SearchFilter.swift`

- [ ] **Step 1: Write the failing test**

`MoscowRealtyTests/ViewModels/AuthModelTests.swift`:

```swift
import XCTest
@testable import MoscowRealty

final class AuthModelTests: XCTestCase {

    func test_appUser_buyerRole() {
        let user = AppUser(
            id: UUID(),
            name: "Иван Петров",
            email: "ivan@example.com",
            phone: nil,
            role: .buyer,
            agency: nil,
            licenseNumber: nil
        )
        XCTAssertEqual(user.role, .buyer)
        XCTAssertNil(user.agency)
    }

    func test_appUser_agentRole() {
        let user = AppUser(
            id: UUID(),
            name: "Мария Агентова",
            email: "agent@realty.ru",
            phone: "+7 999 123-45-67",
            role: .agent,
            agency: "ЦИАНРиелт",
            licenseNumber: "МСК-12345"
        )
        XCTAssertEqual(user.role, .agent)
        XCTAssertEqual(user.agency, "ЦИАНРиелт")
    }

    func test_searchFilter_defaults() {
        let filter = SearchFilter()
        XCTAssertEqual(filter.propertyType, .apartment)
        XCTAssertEqual(filter.listingType, .buy)
        XCTAssertTrue(filter.rooms.isEmpty)
        XCTAssertNil(filter.priceMin)
        XCTAssertNil(filter.priceMax)
    }
}
```

- [ ] **Step 2: Run test — expect FAIL**

```bash
xcodebuild test \
  -project MoscowRealty.xcodeproj \
  -scheme MoscowRealty \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=17.5' \
  -only-testing:MoscowRealtyTests/AuthModelTests \
  2>&1 | grep -E "(PASSED|FAILED|error:)"
```

Expected: compile error — types not defined.

- [ ] **Step 3: Implement AppUser.swift**

`MoscowRealty/Features/Auth/Model/AppUser.swift`:

```swift
import Foundation

enum UserRole: String, Codable, Equatable {
    case buyer = "buyer"
    case agent = "agent"
}

struct AppUser: Identifiable, Codable, Equatable {
    let id:            UUID
    var name:          String
    var email:         String
    var phone:         String?
    var role:          UserRole
    var agency:        String?
    var licenseNumber: String?

    var isAgent: Bool { role == .agent }
    var initials: String {
        name.split(separator: " ").prefix(2)
            .compactMap { $0.first.map(String.init) }
            .joined()
    }
}
```

- [ ] **Step 4: Implement AuthError.swift**

`MoscowRealty/Features/Auth/Model/AuthError.swift`:

```swift
enum AuthError: LocalizedError {
    case invalidCredentials
    case emailAlreadyTaken
    case requiredFieldEmpty
    case networkError

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:  return "Неверный email или пароль"
        case .emailAlreadyTaken:   return "Этот email уже зарегистрирован"
        case .requiredFieldEmpty:  return "Заполните все обязательные поля"
        case .networkError:        return "Ошибка соединения, попробуйте ещё раз"
        }
    }
}
```

- [ ] **Step 5: Implement ChatMessage.swift and ChatThread.swift**

`MoscowRealty/Features/Chat/Model/ChatMessage.swift`:

```swift
import Foundation

struct ChatMessage: Identifiable, Codable, Equatable {
    let id:                UUID
    var text:              String
    var senderId:          UUID
    var date:              Date
    var isFromCurrentUser: Bool
}
```

`MoscowRealty/Features/Chat/Model/ChatThread.swift`:

```swift
import Foundation

struct ChatThread: Identifiable, Codable {
    let id:              UUID
    var propertyId:      UUID
    var propertyTitle:   String
    var participantName: String
    var lastMessage:     String
    var lastMessageDate: Date
    var unreadCount:     Int
    var messages:        [ChatMessage]
}
```

- [ ] **Step 6: Implement SearchFilter.swift**

`MoscowRealty/Features/Search/Model/SearchFilter.swift`:

```swift
struct SearchFilter: Equatable {
    var propertyType: PropertyType = .apartment
    var listingType:  ListingType  = .buy
    var rooms:        Set<Int>     = []
    var priceMin:     Int?
    var priceMax:     Int?
    var areaMin:      Double?
    var areaMax:      Double?
    var metro:        String?
    var district:     String?

    var isEmpty: Bool {
        rooms.isEmpty && priceMin == nil && priceMax == nil
        && areaMin == nil && areaMax == nil
        && metro == nil && district == nil
    }
}
```

- [ ] **Step 7: Run test — expect PASS**

```bash
xcodebuild test \
  -project MoscowRealty.xcodeproj \
  -scheme MoscowRealty \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=17.5' \
  -only-testing:MoscowRealtyTests/AuthModelTests \
  2>&1 | grep -E "(PASSED|FAILED|error:)"
```

Expected: `Test Suite 'AuthModelTests' passed`

- [ ] **Step 8: Commit**

```bash
git add MoscowRealty/Features/Auth/Model/ \
        MoscowRealty/Features/Chat/Model/ \
        MoscowRealty/Features/Search/Model/ \
        MoscowRealtyTests/ViewModels/AuthModelTests.swift
git commit -m "feat: add AppUser, AuthError, ChatThread, ChatMessage, SearchFilter models"
```

---

### Task 4: Service protocols + AppEnvironment

**Files:**
- Create: `MoscowRealty/Services/PropertyServiceProtocol.swift`
- Create: `MoscowRealty/Services/AuthServiceProtocol.swift`
- Create: `MoscowRealty/Services/ChatServiceProtocol.swift`
- Create: `MoscowRealty/Services/FavoritesServiceProtocol.swift`
- Create: `MoscowRealty/Core/Environment/AppEnvironment.swift`

- [ ] **Step 1: Implement PropertyServiceProtocol.swift**

`MoscowRealty/Services/PropertyServiceProtocol.swift`:

```swift
import Foundation

protocol PropertyServiceProtocol {
    func fetchProperties(filter: SearchFilter) async -> [Property]
    func fetchProperty(id: UUID) async -> Property?
    func fetchAgentListings(agentId: UUID) async -> [Property]
    func addListing(_ property: Property) async
    func updateListing(_ property: Property) async
    func deleteListing(id: UUID) async
}
```

- [ ] **Step 2: Implement AuthServiceProtocol.swift**

`MoscowRealty/Services/AuthServiceProtocol.swift`:

```swift
protocol AuthServiceProtocol: AnyObject {
    var currentUser: AppUser? { get }
    func login(email: String, password: String) async throws -> AppUser
    func register(_ user: AppUser, password: String) async throws -> AppUser
    func logout()
}
```

- [ ] **Step 3: Implement ChatServiceProtocol.swift**

`MoscowRealty/Services/ChatServiceProtocol.swift`:

```swift
import Foundation

protocol ChatServiceProtocol {
    func fetchThreads(for userId: UUID) async -> [ChatThread]
    func fetchThread(id: UUID) async -> ChatThread?
    func sendMessage(_ text: String, threadId: UUID, senderId: UUID) async -> ChatMessage
    func markAsRead(threadId: UUID) async
}
```

- [ ] **Step 4: Implement FavoritesServiceProtocol.swift**

`MoscowRealty/Services/FavoritesServiceProtocol.swift`:

```swift
import Foundation

protocol FavoritesServiceProtocol: AnyObject {
    func isFavorite(id: UUID) -> Bool
    func toggle(id: UUID)
    func fetchAllIds() -> Set<UUID>
}
```

- [ ] **Step 5: Implement AppEnvironment.swift**

`MoscowRealty/Core/Environment/AppEnvironment.swift`:

```swift
import SwiftUI

// MARK: - Property Service
private struct PropertyServiceKey: EnvironmentKey {
    static let defaultValue: any PropertyServiceProtocol = MockPropertyService()
}

// MARK: - Auth Service
private struct AuthServiceKey: EnvironmentKey {
    static let defaultValue: any AuthServiceProtocol = MockAuthService()
}

// MARK: - Chat Service
private struct ChatServiceKey: EnvironmentKey {
    static let defaultValue: any ChatServiceProtocol = MockChatService()
}

// MARK: - Favorites Service
private struct FavoritesServiceKey: EnvironmentKey {
    static let defaultValue: any FavoritesServiceProtocol = FavoritesService()
}

extension EnvironmentValues {
    var propertyService: any PropertyServiceProtocol {
        get { self[PropertyServiceKey.self] }
        set { self[PropertyServiceKey.self] = newValue }
    }
    var authService: any AuthServiceProtocol {
        get { self[AuthServiceKey.self] }
        set { self[AuthServiceKey.self] = newValue }
    }
    var chatService: any ChatServiceProtocol {
        get { self[ChatServiceKey.self] }
        set { self[ChatServiceKey.self] = newValue }
    }
    var favoritesService: any FavoritesServiceProtocol {
        get { self[FavoritesServiceKey.self] }
        set { self[FavoritesServiceKey.self] = newValue }
    }
}
```

Note: `AppEnvironment.swift` references `MockPropertyService`, `MockAuthService`, `MockChatService`, and `FavoritesService` as default values. These are created in Tasks 5–7; the file will not compile until those tasks are done. This is expected — Task 4 and Tasks 5–7 are committed together at the end of Task 7.

- [ ] **Step 6: Commit (protocols only — AppEnvironment committed in Task 7)**

```bash
git add MoscowRealty/Services/PropertyServiceProtocol.swift \
        MoscowRealty/Services/AuthServiceProtocol.swift \
        MoscowRealty/Services/ChatServiceProtocol.swift \
        MoscowRealty/Services/FavoritesServiceProtocol.swift
git commit -m "feat: add service protocols"
```

---

### Task 5: FavoritesService (real UserDefaults persistence)

**Files:**
- Create: `MoscowRealty/Services/FavoritesService.swift`
- Test: `MoscowRealtyTests/Services/FavoritesServiceTests.swift`

- [ ] **Step 1: Write the failing test**

`MoscowRealtyTests/Services/FavoritesServiceTests.swift`:

```swift
import XCTest
@testable import MoscowRealty

final class FavoritesServiceTests: XCTestCase {

    var sut: FavoritesService!
    let testKey = "favorites_test"

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: testKey)
        sut = FavoritesService(userDefaultsKey: testKey)
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: testKey)
        super.tearDown()
    }

    func test_isFavorite_returnsFalseByDefault() {
        let id = UUID()
        XCTAssertFalse(sut.isFavorite(id: id))
    }

    func test_toggle_addsFavorite() {
        let id = UUID()
        sut.toggle(id: id)
        XCTAssertTrue(sut.isFavorite(id: id))
    }

    func test_toggle_removesFavoriteOnSecondCall() {
        let id = UUID()
        sut.toggle(id: id)
        sut.toggle(id: id)
        XCTAssertFalse(sut.isFavorite(id: id))
    }

    func test_fetchAllIds_returnsToggled() {
        let id1 = UUID()
        let id2 = UUID()
        sut.toggle(id: id1)
        sut.toggle(id: id2)
        let all = sut.fetchAllIds()
        XCTAssertTrue(all.contains(id1))
        XCTAssertTrue(all.contains(id2))
    }

    func test_persistence_acrossInstances() {
        let id = UUID()
        sut.toggle(id: id)
        let sut2 = FavoritesService(userDefaultsKey: testKey)
        XCTAssertTrue(sut2.isFavorite(id: id))
    }
}
```

- [ ] **Step 2: Run test — expect FAIL**

```bash
xcodebuild test \
  -project MoscowRealty.xcodeproj \
  -scheme MoscowRealty \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=17.5' \
  -only-testing:MoscowRealtyTests/FavoritesServiceTests \
  2>&1 | grep -E "(PASSED|FAILED|error:)"
```

Expected: compile error.

- [ ] **Step 3: Implement FavoritesService.swift**

`MoscowRealty/Services/FavoritesService.swift`:

```swift
import Foundation

final class FavoritesService: FavoritesServiceProtocol {

    private let key: String
    private var ids: Set<UUID>

    init(userDefaultsKey: String = "com.baha.moscowrealty.favorites") {
        self.key = userDefaultsKey
        let strings = UserDefaults.standard.stringArray(forKey: userDefaultsKey) ?? []
        self.ids = Set(strings.compactMap { UUID(uuidString: $0) })
    }

    func isFavorite(id: UUID) -> Bool { ids.contains(id) }

    func toggle(id: UUID) {
        if ids.contains(id) {
            ids.remove(id)
        } else {
            ids.insert(id)
        }
        persist()
    }

    func fetchAllIds() -> Set<UUID> { ids }

    private func persist() {
        UserDefaults.standard.set(ids.map(\.uuidString), forKey: key)
    }
}
```

- [ ] **Step 4: Run test — expect PASS**

```bash
xcodebuild test \
  -project MoscowRealty.xcodeproj \
  -scheme MoscowRealty \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=17.5' \
  -only-testing:MoscowRealtyTests/FavoritesServiceTests \
  2>&1 | grep -E "(PASSED|FAILED|error:)"
```

Expected: `Test Suite 'FavoritesServiceTests' passed`

- [ ] **Step 5: Commit**

```bash
git add MoscowRealty/Services/FavoritesService.swift \
        MoscowRealtyTests/Services/FavoritesServiceTests.swift
git commit -m "feat: add FavoritesService with UserDefaults persistence"
```

---

### Task 6: MockPropertyService with seed data

**Files:**
- Create: `MoscowRealty/Services/MockPropertyService.swift`

Note: Before writing this file, export property images from Figma (node `25223:87057`) and add them to `MoscowRealty/Resources/Assets.xcassets` with names: `apt_arbat_1`, `apt_arbat_2`, `apt_south_1`, `apt_south_2`, `apt_north_1`, `parking_center_1`, `parking_south_1`, `storage_1`, `storage_2`. If images are not yet exported, use `"placeholder"` and replace later.

- [ ] **Step 1: Implement MockPropertyService.swift**

`MoscowRealty/Services/MockPropertyService.swift`:

```swift
import Foundation

final class MockPropertyService: PropertyServiceProtocol {

    private var listings: [Property] = MockPropertyService.seedData()

    func fetchProperties(filter: SearchFilter) async -> [Property] {
        listings.filter { matches(filter, property: $0) }
    }

    func fetchProperty(id: UUID) async -> Property? {
        listings.first { $0.id == id }
    }

    func fetchAgentListings(agentId: UUID) async -> [Property] {
        listings.filter { $0.agentId == agentId }
    }

    func addListing(_ property: Property) async {
        listings.append(property)
    }

    func updateListing(_ property: Property) async {
        if let idx = listings.firstIndex(where: { $0.id == property.id }) {
            listings[idx] = property
        }
    }

    func deleteListing(id: UUID) async {
        listings.removeAll { $0.id == id }
    }

    // MARK: - Filter logic
    private func matches(_ filter: SearchFilter, property: Property) -> Bool {
        guard property.propertyType == filter.propertyType else { return false }
        guard property.listingType == filter.listingType else { return false }
        if !filter.rooms.isEmpty, let rooms = property.rooms {
            guard filter.rooms.contains(rooms) else { return false }
        }
        if let min = filter.priceMin { guard property.price >= min else { return false } }
        if let max = filter.priceMax { guard property.price <= max else { return false } }
        if let min = filter.areaMin  { guard property.area  >= min else { return false } }
        if let max = filter.areaMax  { guard property.area  <= max else { return false } }
        if let metro = filter.metro, !metro.isEmpty {
            guard property.metro?.localizedCaseInsensitiveContains(metro) == true else { return false }
        }
        if let district = filter.district, !district.isEmpty {
            guard property.district.localizedCaseInsensitiveContains(district) else { return false }
        }
        return true
    }

    // MARK: - Seed data
    static let agentAlexId = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    static let agentMaria   = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!

    static func seedData() -> [Property] {
        [
            Property(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000001")!,
                propertyType: .apartment, listingType: .buy,
                title: "3-комн. квартира, Арбат",
                price: 28_500_000,
                address: "ул. Арбат, 15, кв. 42",
                metro: "Арбатская",
                district: "Центральный",
                area: 87.5,
                imageNames: ["apt_arbat_1", "apt_arbat_2"],
                coordinates: Coordinates(latitude: 55.7517, longitude: 37.5960),
                agentId: agentAlexId,
                description: "Просторная квартира в историческом центре. Высокие потолки, паркет, свежий ремонт. Вид на Арбат.",
                rooms: 3, floor: 4, totalFloors: 9, isNewBuilding: false, isHeated: nil
            ),
            Property(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000002")!,
                propertyType: .apartment, listingType: .buy,
                title: "2-комн. новостройка, Юго-Запад",
                price: 14_200_000,
                address: "Ленинский пр-т, 120",
                metro: "Юго-Западная",
                district: "Юго-Западный",
                area: 58.0,
                imageNames: ["apt_south_1", "apt_south_2"],
                coordinates: Coordinates(latitude: 55.6610, longitude: 37.4845),
                agentId: agentMaria,
                description: "Современная новостройка с отделкой под ключ. Закрытая территория, подземный паркинг.",
                rooms: 2, floor: 12, totalFloors: 25, isNewBuilding: true, isHeated: nil
            ),
            Property(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000003")!,
                propertyType: .apartment, listingType: .buy,
                title: "1-комн. квартира, Север",
                price: 9_800_000,
                address: "Дмитровское ш., 45",
                metro: "Дмитровская",
                district: "Северный",
                area: 38.0,
                imageNames: ["apt_north_1"],
                coordinates: Coordinates(latitude: 55.8097, longitude: 37.5711),
                agentId: agentAlexId,
                description: "Уютная квартира-студия. Рядом парк Дружбы, metro в 5 минутах ходьбы.",
                rooms: 1, floor: 7, totalFloors: 17, isNewBuilding: false, isHeated: nil
            ),
            Property(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000004")!,
                propertyType: .apartment, listingType: .rent,
                title: "2-комн. аренда, Сокол",
                price: 85_000,
                address: "ул. Балтийская, 3",
                metro: "Сокол",
                district: "Северный",
                area: 54.0,
                imageNames: ["apt_north_1", "apt_arbat_2"],
                coordinates: Coordinates(latitude: 55.8077, longitude: 37.5146),
                agentId: agentMaria,
                description: "Светлая двушка с евроремонтом. Вся необходимая мебель и техника.",
                rooms: 2, floor: 3, totalFloors: 5, isNewBuilding: false, isHeated: nil
            ),
            Property(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000005")!,
                propertyType: .apartment, listingType: .buy,
                title: "4-комн. квартира, Раменки",
                price: 32_000_000,
                address: "Мичуринский пр-т, 7",
                metro: "Раменки",
                district: "Западный",
                area: 120.0,
                imageNames: ["apt_south_1", "apt_arbat_1"],
                coordinates: Coordinates(latitude: 55.7188, longitude: 37.4460),
                agentId: agentAlexId,
                description: "Элитная квартира с панорамными окнами. Три санузла, гардеробная, два балкона.",
                rooms: 4, floor: 18, totalFloors: 22, isNewBuilding: true, isHeated: nil
            ),
            Property(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000006")!,
                propertyType: .parking, listingType: .buy,
                title: "Машиноместо, Центр",
                price: 2_800_000,
                address: "ул. Тверская, 10",
                metro: "Тверская",
                district: "Центральный",
                area: 18.0,
                imageNames: ["parking_center_1"],
                coordinates: Coordinates(latitude: 55.7648, longitude: 37.6024),
                agentId: agentMaria,
                description: "Охраняемый подземный паркинг. Видеонаблюдение 24/7. Высота 2.2 м.",
                rooms: nil, floor: -1, totalFloors: nil, isNewBuilding: false, isHeated: true
            ),
            Property(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000007")!,
                propertyType: .parking, listingType: .buy,
                title: "Машиноместо, Юго-Запад",
                price: 1_500_000,
                address: "Ленинский пр-т, 120",
                metro: "Юго-Западная",
                district: "Юго-Западный",
                area: 15.5,
                imageNames: ["parking_south_1"],
                coordinates: Coordinates(latitude: 55.6612, longitude: 37.4847),
                agentId: agentAlexId,
                description: "Паркинг в новом ЖК. Отапливаемый. Рядом с лифтом.",
                rooms: nil, floor: -2, totalFloors: nil, isNewBuilding: true, isHeated: true
            ),
            Property(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000008")!,
                propertyType: .parking, listingType: .rent,
                title: "Аренда машиноместа, Сокол",
                price: 8_000,
                address: "ул. Балтийская, 3",
                metro: "Сокол",
                district: "Северный",
                area: 16.0,
                imageNames: ["parking_center_1"],
                coordinates: Coordinates(latitude: 55.8079, longitude: 37.5148),
                agentId: agentMaria,
                description: "Охраняемое машиноместо. Шлагбаум, видеокамеры.",
                rooms: nil, floor: 1, totalFloors: nil, isNewBuilding: false, isHeated: false
            ),
            Property(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000009")!,
                propertyType: .storage, listingType: .buy,
                title: "Кладовая, Юго-Запад",
                price: 450_000,
                address: "Ленинский пр-т, 120",
                metro: "Юго-Западная",
                district: "Юго-Западный",
                area: 5.2,
                imageNames: ["storage_1"],
                coordinates: Coordinates(latitude: 55.6613, longitude: 37.4846),
                agentId: agentAlexId,
                description: "Кладовая на -1 этаже ЖК. Сухая, тёплая, видеонаблюдение.",
                rooms: nil, floor: -1, totalFloors: nil, isNewBuilding: true, isHeated: true
            ),
            Property(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000010")!,
                propertyType: .storage, listingType: .rent,
                title: "Аренда кладовой, Центр",
                price: 3_500,
                address: "ул. Тверская, 10",
                metro: "Тверская",
                district: "Центральный",
                area: 4.0,
                imageNames: ["storage_2"],
                coordinates: Coordinates(latitude: 55.7649, longitude: 37.6025),
                agentId: agentMaria,
                description: "Кладовое помещение в цокольном этаже. Доступ круглосуточно.",
                rooms: nil, floor: 0, totalFloors: nil, isNewBuilding: false, isHeated: false
            )
        ]
    }
}
```

- [ ] **Step 2: Add placeholder image asset**

In `MoscowRealty/Resources/Assets.xcassets`, create an image set named `placeholder` with a 1×1 gray PNG. The real Figma exports replace this in the next step.

```bash
mkdir -p MoscowRealty/Resources/Assets.xcassets/placeholder.imageset
cat > MoscowRealty/Resources/Assets.xcassets/placeholder.imageset/Contents.json << 'EOF'
{
  "images": [{"idiom": "universal", "filename": "placeholder.png", "scale": "1x"}],
  "info": {"version": 1, "author": "xcode"}
}
EOF
```

Then create a 1×1 gray PNG named `placeholder.png` in that folder. (Any valid 1-pixel PNG suffices — use Preview or ImageMagick: `convert -size 1x1 xc:gray placeholder.png`.)

- [ ] **Step 3: Export Figma images**

In Figma (file `RYN53FSaqfXotKlg7aR4wB`), export the property photo frames as PNG at 2x. Name them: `apt_arbat_1`, `apt_arbat_2`, `apt_south_1`, `apt_south_2`, `apt_north_1`, `parking_center_1`, `parking_south_1`, `storage_1`, `storage_2`. Add each to `Assets.xcassets` as an image set.

- [ ] **Step 4: Build to verify no compile errors**

```bash
xcodebuild build \
  -project MoscowRealty.xcodeproj \
  -scheme MoscowRealty \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=17.5' \
  2>&1 | grep -E "(BUILD|error:)"
```

Expected: `BUILD SUCCEEDED`

- [ ] **Step 5: Commit**

```bash
git add MoscowRealty/Services/MockPropertyService.swift \
        MoscowRealty/Resources/Assets.xcassets/
git commit -m "feat: add MockPropertyService with 10 seed properties"
```

---

### Task 7: MockAuthService + MockChatService + wire AppEnvironment

**Files:**
- Create: `MoscowRealty/Services/MockAuthService.swift`
- Create: `MoscowRealty/Services/MockChatService.swift`
- Create: `MoscowRealty/Core/Environment/AppEnvironment.swift` (from Task 4 — now compilable)

- [ ] **Step 1: Implement MockAuthService.swift**

`MoscowRealty/Services/MockAuthService.swift`:

```swift
import Foundation

final class MockAuthService: AuthServiceProtocol {

    private(set) var currentUser: AppUser?

    private let seedBuyer = AppUser(
        id: UUID(uuidString: "20000000-0000-0000-0000-000000000001")!,
        name: "Иван Петров",
        email: "buyer@test.ru",
        phone: nil,
        role: .buyer,
        agency: nil,
        licenseNumber: nil
    )

    private let seedAgent = AppUser(
        id: MockPropertyService.agentAlexId,
        name: "Алекс Агентов",
        email: "agent@test.ru",
        phone: "+7 916 111-22-33",
        role: .agent,
        agency: "МоскваРиелт",
        licenseNumber: "МСК-00001"
    )

    private var registeredUsers: [String: (AppUser, String)] = [:]  // email → (user, password)

    init() {
        registeredUsers["buyer@test.ru"] = (seedBuyer, "password")
        registeredUsers["agent@test.ru"] = (seedAgent, "password")
    }

    func login(email: String, password: String) async throws -> AppUser {
        try await Task.sleep(nanoseconds: 400_000_000)
        guard let (user, storedPassword) = registeredUsers[email.lowercased()],
              storedPassword == password else {
            throw AuthError.invalidCredentials
        }
        currentUser = user
        return user
    }

    func register(_ user: AppUser, password: String) async throws -> AppUser {
        try await Task.sleep(nanoseconds: 400_000_000)
        guard !user.email.isEmpty, !password.isEmpty else {
            throw AuthError.requiredFieldEmpty
        }
        guard registeredUsers[user.email.lowercased()] == nil else {
            throw AuthError.emailAlreadyTaken
        }
        registeredUsers[user.email.lowercased()] = (user, password)
        currentUser = user
        return user
    }

    func logout() { currentUser = nil }
}
```

- [ ] **Step 2: Implement MockChatService.swift**

`MoscowRealty/Services/MockChatService.swift`:

```swift
import Foundation

final class MockChatService: ChatServiceProtocol {

    private var threads: [ChatThread] = MockChatService.seedThreads()

    func fetchThreads(for userId: UUID) async -> [ChatThread] {
        threads
    }

    func fetchThread(id: UUID) async -> ChatThread? {
        threads.first { $0.id == id }
    }

    func sendMessage(_ text: String, threadId: UUID, senderId: UUID) async -> ChatMessage {
        let message = ChatMessage(
            id: UUID(),
            text: text,
            senderId: senderId,
            date: Date(),
            isFromCurrentUser: true
        )
        if let idx = threads.firstIndex(where: { $0.id == threadId }) {
            threads[idx].messages.append(message)
            threads[idx].lastMessage = text
            threads[idx].lastMessageDate = Date()
            threads[idx].unreadCount = 0
        }
        return message
    }

    func markAsRead(threadId: UUID) async {
        if let idx = threads.firstIndex(where: { $0.id == threadId }) {
            threads[idx].unreadCount = 0
        }
    }

    static func seedThreads() -> [ChatThread] {
        let agentId = MockPropertyService.agentAlexId
        let buyerId = UUID(uuidString: "20000000-0000-0000-0000-000000000001")!

        return [
            ChatThread(
                id: UUID(uuidString: "30000000-0000-0000-0000-000000000001")!,
                propertyId: UUID(uuidString: "10000000-0000-0000-0000-000000000001")!,
                propertyTitle: "3-комн. квартира, Арбат",
                participantName: "Алекс Агентов",
                lastMessage: "Да, можем организовать показ в субботу",
                lastMessageDate: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!,
                unreadCount: 1,
                messages: [
                    ChatMessage(id: UUID(), text: "Здравствуйте! Меня интересует квартира на Арбате. Когда можно посмотреть?",
                                senderId: buyerId, date: Calendar.current.date(byAdding: .hour, value: -3, to: Date())!, isFromCurrentUser: true),
                    ChatMessage(id: UUID(), text: "Добрый день! Квартира свободна для просмотра. Когда вам удобно?",
                                senderId: agentId, date: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!, isFromCurrentUser: false),
                    ChatMessage(id: UUID(), text: "Можно в субботу утром?",
                                senderId: buyerId, date: Calendar.current.date(byAdding: .minute, value: -90, to: Date())!, isFromCurrentUser: true),
                    ChatMessage(id: UUID(), text: "Да, можем организовать показ в субботу",
                                senderId: agentId, date: Calendar.current.date(byAdding: .minute, value: -120, to: Date())!, isFromCurrentUser: false)
                ]
            ),
            ChatThread(
                id: UUID(uuidString: "30000000-0000-0000-0000-000000000002")!,
                propertyId: UUID(uuidString: "10000000-0000-0000-0000-000000000002")!,
                propertyTitle: "2-комн. новостройка, Юго-Запад",
                participantName: "Мария Агентова",
                lastMessage: "Цена окончательная, торга нет",
                lastMessageDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
                unreadCount: 0,
                messages: [
                    ChatMessage(id: UUID(), text: "Возможен ли торг по цене?",
                                senderId: buyerId, date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, isFromCurrentUser: true),
                    ChatMessage(id: UUID(), text: "Цена окончательная, торга нет",
                                senderId: MockPropertyService.agentMaria, date: Calendar.current.date(byAdding: .hour, value: -20, to: Date())!, isFromCurrentUser: false)
                ]
            ),
            ChatThread(
                id: UUID(uuidString: "30000000-0000-0000-0000-000000000003")!,
                propertyId: UUID(uuidString: "10000000-0000-0000-0000-000000000006")!,
                propertyTitle: "Машиноместо, Центр",
                participantName: "Мария Агентова",
                lastMessage: "Высота въезда 2 метра 10 сантиметров",
                lastMessageDate: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
                unreadCount: 0,
                messages: [
                    ChatMessage(id: UUID(), text: "Какая высота въезда в паркинг?",
                                senderId: buyerId, date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, isFromCurrentUser: true),
                    ChatMessage(id: UUID(), text: "Высота въезда 2 метра 10 сантиметров",
                                senderId: MockPropertyService.agentMaria, date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, isFromCurrentUser: false)
                ]
            )
        ]
    }
}
```

- [ ] **Step 3: Add AppEnvironment.swift (from Task 4)**

Create `MoscowRealty/Core/Environment/AppEnvironment.swift` with the content from Task 4, Step 5. The file now compiles because `MockPropertyService`, `MockAuthService`, `MockChatService`, and `FavoritesService` are all defined.

- [ ] **Step 4: Build to verify everything compiles**

```bash
xcodebuild build \
  -project MoscowRealty.xcodeproj \
  -scheme MoscowRealty \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=17.5' \
  2>&1 | grep -E "(BUILD|error:)"
```

Expected: `BUILD SUCCEEDED`

- [ ] **Step 5: Run all tests so far**

```bash
xcodebuild test \
  -project MoscowRealty.xcodeproj \
  -scheme MoscowRealty \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=17.5' \
  -only-testing:MoscowRealtyTests \
  2>&1 | grep -E "(PASSED|FAILED|Test Suite.*passed|error:)"
```

Expected: all tests pass (`PropertyModelTests`, `AuthModelTests`, `FavoritesServiceTests`).

- [ ] **Step 6: Commit**

```bash
git add MoscowRealty/Services/MockAuthService.swift \
        MoscowRealty/Services/MockChatService.swift \
        MoscowRealty/Core/Environment/AppEnvironment.swift
git commit -m "feat: add MockAuthService, MockChatService, AppEnvironment DI"
```

---

**Phase 1 complete.** Proceed to `2026-05-25-moscow-realty-ios-phase2-shell.md`.
