# Moscow Realty iOS — Design Spec
**Date:** 2026-05-25  
**Status:** Approved  
**Figma:** https://www.figma.com/design/RYN53FSaqfXotKlg7aR4wB/apartment-purchase

---

## 1. Project Overview

A Russian-language real estate iOS app for Moscow covering new-build apartments (новостройки), parking spaces (машиноместа), and storage rooms (кладовки). Supports two user roles: **Buyer/Renter** and **Agent**. The Developer/Agency role is deferred to a future version.

| Key | Value |
|-----|-------|
| Repo | `moscow-realty-ios-swiftui` |
| Bundle ID | `com.baha.moscowrealty` |
| Target | iOS 17+ |
| Language | Swift 5.9, SwiftUI |
| Architecture | MVVM-C (NavigationPath Coordinator) |
| External dependencies | None (Apple frameworks only) |
| Backend | Mock services (protocol-backed, swappable) |
| Maps | Apple MapKit |
| Localization | Russian only |

---

## 2. Architecture

### MVVM-C with NavigationPath Coordinators

Each coordinator is an `ObservableObject` owning a `NavigationPath`. Views receive their coordinator via `@EnvironmentObject` and call coordinator methods for navigation. ViewModels contain no navigation logic — pure business logic and UI state only.

### Coordinator Hierarchy

```
AppCoordinator
└── TabCoordinator
    ├── MainCoordinator       ← Главная tab
    ├── SearchCoordinator     ← Поиск tab
    ├── PostCoordinator       ← Разместить tab (agent-gated)
    ├── ChatCoordinator       ← Чат tab
    └── ProfileCoordinator    ← Профиль tab
        └── AuthCoordinator   ← modal: login / register
```

### Folder Structure

```
MoscowRealty/
├── App/
│   └── MoscowRealtyApp.swift
├── Coordinators/
│   ├── AppCoordinator.swift
│   ├── TabCoordinator.swift
│   ├── MainCoordinator.swift
│   ├── SearchCoordinator.swift
│   ├── PostCoordinator.swift
│   ├── ChatCoordinator.swift
│   ├── AuthCoordinator.swift
│   └── ProfileCoordinator.swift
├── Core/
│   └── Models/
│       ├── Property.swift
│       └── Coordinates.swift
├── Features/
│   ├── Home/
│   │   ├── Model/
│   │   ├── View/
│   │   └── ViewModel/
│   ├── Catalog/
│   │   ├── Model/
│   │   ├── View/
│   │   └── ViewModel/
│   ├── PropertyDetail/
│   │   ├── Model/
│   │   ├── View/
│   │   └── ViewModel/
│   ├── Search/
│   │   ├── Model/       ← SearchFilter.swift
│   │   ├── View/
│   │   └── ViewModel/
│   ├── Favorites/
│   │   ├── Model/
│   │   ├── View/
│   │   └── ViewModel/
│   ├── Chat/
│   │   ├── Model/       ← ChatThread.swift, ChatMessage.swift
│   │   ├── View/
│   │   └── ViewModel/
│   ├── Auth/
│   │   ├── Model/       ← AppUser.swift, UserRole.swift
│   │   ├── View/
│   │   └── ViewModel/
│   └── Agent/
│       ├── Model/
│       ├── View/
│       └── ViewModel/
├── Services/
│   ├── PropertyServiceProtocol.swift
│   ├── MockPropertyService.swift
│   ├── AuthServiceProtocol.swift
│   ├── MockAuthService.swift
│   ├── ChatServiceProtocol.swift
│   ├── MockChatService.swift
│   ├── FavoritesServiceProtocol.swift
│   └── FavoritesService.swift        ← real UserDefaults persistence
└── Resources/
    ├── Assets.xcassets               ← Figma image exports as named assets
    └── ru.lproj/
        └── Localizable.strings
```

---

## 3. Tab Bar

5 tabs, Russian labels, SF Symbols icons:

| # | Label | Symbol | Access |
|---|-------|--------|--------|
| 1 | Главная | `house` | All |
| 2 | Поиск | `magnifyingglass` | All |
| 3 | Разместить | `doc.badge.plus` | Agent (auth guard on tap) |
| 4 | Чат | `message` | All |
| 5 | Профиль | `person` | All |

---

## 4. Screen Flows

### Buyer Flow (MainCoordinator)
```
HomeView
  └── CatalogView
        ├── toggle: Квартиры / Машиноместа / Кладовки
        ├── toggle: Купить / Аренда
        ├── PropertyDetailView
        │     ├── photo gallery (PageTabViewStyle)
        │     ├── specs grid
        │     ├── MapSingleView (one pin, address)
        │     └── "Написать агенту" → ChatDetailView
        └── CatalogMapView (all visible pins, tap → PropertyDetailView)
```

### Search Flow (SearchCoordinator)
```
SearchView
  ├── SearchFilterSheet (modal)
  │     fields: type, listingType, rooms, price range, area range, metro, district
  └── results inline → PropertyDetailView
```

### Post Flow (PostCoordinator — agent only)
```
[tap Разместить]
  ├── not logged in → AuthCoordinator (modal) → returns to PostCoordinator
  └── logged in as agent →
        AddListingView (multi-step)
          Step 1: property type + listing type
          Step 2: address, district, metro
          Step 3: details (rooms, area, floor, price, description)
          Step 4: photos (picker over pre-seeded Figma asset names, no PHPicker)
          Step 5: confirmation summary → submit
```

### Chat Flow (ChatCoordinator)
```
ChatListView (threads list)
  └── ChatDetailView (bubble list + text input)
```

### Profile Flow (ProfileCoordinator)
```
[not logged in] → LoginView ←→ RegisterView (buyer | agent)
[logged in as buyer] → BuyerProfileView
  └── Избранное section → PropertyDetailView
[logged in as agent] → AgentDashboardView
  ├── my listings list → PropertyDetailView
  ├── EditListingView (pre-filled AddListingView)
  └── delete listing (confirm alert)
```

---

## 5. Data Models

### Core

```swift
enum PropertyType: String, CaseIterable { case apartment, parking, storage }
enum ListingType: String               { case buy, rent }
enum UserRole                           { case buyer, agent }

struct Coordinates { let latitude: Double; let longitude: Double }

struct Property: Identifiable {
    let id: UUID
    var propertyType:  PropertyType
    var listingType:   ListingType
    var title:         String
    var price:         Int          // RUB; monthly if .rent
    var address:       String
    var metro:         String?
    var district:      String
    var area:          Double       // m²
    var imageNames:    [String]     // Asset catalog keys
    var coordinates:   Coordinates
    var agentId:       UUID
    var description:   String
    // Apartment-only (nil for parking/storage)
    var rooms:         Int?
    var floor:         Int?
    var totalFloors:   Int?
    var isNewBuilding: Bool
    // Parking & Storage
    var isHeated:      Bool?
}
```

### Auth

```swift
struct AppUser: Identifiable {
    let id: UUID
    var name:          String
    var email:         String
    var phone:         String?
    var role:          UserRole
    var agency:        String?        // agent-only
    var licenseNumber: String?        // agent-only
}
```

### Search

```swift
struct SearchFilter {
    var propertyType: PropertyType = .apartment
    var listingType:  ListingType  = .buy
    var rooms:        Set<Int>     = []
    var priceMin:     Int?;  var priceMax: Int?
    var areaMin:      Double?; var areaMax: Double?
    var metro:        String?;  var district: String?
}
```

### Chat

```swift
struct ChatThread: Identifiable {
    let id: UUID
    var propertyId:      UUID
    var propertyTitle:   String
    var participantName: String
    var lastMessage:     String
    var lastMessageDate: Date
    var unreadCount:     Int
    var messages:        [ChatMessage]
}

struct ChatMessage: Identifiable {
    let id: UUID
    var text:              String
    var senderId:          UUID
    var date:              Date
    var isFromCurrentUser: Bool
}
```

---

## 6. Services Layer

All services injected via SwiftUI `EnvironmentKey`. ViewModels depend on protocols only.

| Protocol | Mock | Real (future) |
|----------|------|---------------|
| `PropertyServiceProtocol` | `MockPropertyService` | REST API client |
| `AuthServiceProtocol` | `MockAuthService` | JWT auth endpoint |
| `ChatServiceProtocol` | `MockChatService` | WebSocket / REST |
| `FavoritesServiceProtocol` | `FavoritesService` | UserDefaults (ships as-is) |

**Mock seed data:**
- 15–20 `Property` records across Moscow districts (Центр, Юго-Запад, Север, Восток…)
- Images: exported from Figma and added to `Assets.xcassets`
- 2 hardcoded users: one buyer, one agent
- 3–4 chat threads with 5–8 messages each

---

## 7. ViewModel State Pattern

```swift
enum ViewState<T> {
    case idle
    case loading
    case loaded(T)
    case error(String)   // user-facing Russian message
}
```

Every ViewModel exposes `@Published var state: ViewState<T>`. Views switch on state to render skeleton, content, or error banner.

---

## 8. Error Handling

| Scenario | Handling |
|----------|----------|
| Service call failure | Caught in ViewModel → `.error(localizedMessage)` state |
| Auth: wrong credentials | Inline error below email/password field |
| Auth: email taken | Inline error below email field on register |
| Listing form invalid | Fields highlighted red, submit button disabled |
| MapKit no location permission | Fallback to list-only view; no crash |

---

## 9. Testing Strategy

- **Unit tests** (`MoscowRealtyTests/`) — one `*ViewModelTests.swift` per ViewModel. Mock services injected via protocol. Cover: filter logic, auth transitions, form validation, favorites toggle.
- **SwiftUI Previews** — every View has a `#Preview` with mock service. Visual spec during development.
- **No XCUITest for MVP** — added post-launch.
- Test folder mirrors `Features/` structure.

---

## 10. Out of Scope (v1)

- Developer/Agency role and bulk listing management
- Push notifications
- Payment / mortgage calculator
- Real backend integration
- In-app map drawing / custom overlays
- App Store submission config
