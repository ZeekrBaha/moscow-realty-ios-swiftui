# Moscow Realty iOS — Phase 3: Buyer Features

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace stub views with full buyer-facing UI: Home, Catalog (list + map), PropertyDetail, Search + Filter sheet, Favorites.

**Prerequisite:** Phase 2 complete and app launches with 5-tab shell.

---

## File Map (this phase)

```
MoscowRealty/Features/
├── Home/
│   ├── View/
│   │   ├── HomeView.swift              (replace stub)
│   │   └── PropertyCard.swift          (new)
│   └── ViewModel/
│       └── HomeViewModel.swift         (new)
├── Catalog/
│   ├── View/
│   │   ├── CatalogView.swift           (new — called from HomeView)
│   │   └── CatalogMapView.swift        (replace stub)
│   └── ViewModel/
│       └── CatalogViewModel.swift      (new)
├── PropertyDetail/
│   ├── View/
│   │   ├── PropertyDetailView.swift    (replace stub)
│   │   ├── PhotoGalleryView.swift      (new)
│   │   └── MapSingleView.swift         (new)
│   └── ViewModel/
│       └── PropertyDetailViewModel.swift (new)
├── Search/
│   ├── View/
│   │   ├── SearchView.swift            (replace stub)
│   │   └── SearchFilterSheet.swift     (replace stub)
│   └── ViewModel/
│       └── SearchViewModel.swift       (new)
└── Favorites/
    ├── View/
    │   └── FavoritesView.swift         (new — rendered inside ProfileView)
    └── ViewModel/
        └── FavoritesViewModel.swift    (new)

MoscowRealtyTests/ViewModels/
├── CatalogViewModelTests.swift
└── SearchViewModelTests.swift
```

---

### Task 10: HomeViewModel + HomeView + PropertyCard

**Files:**
- Create: `MoscowRealty/Features/Home/ViewModel/HomeViewModel.swift`
- Modify: `MoscowRealty/Features/Home/View/HomeView.swift`
- Create: `MoscowRealty/Features/Home/View/PropertyCard.swift`
- Create: `MoscowRealtyTests/ViewModels/HomeViewModelTests.swift`

- [ ] **Step 1: Write failing test**

`MoscowRealtyTests/ViewModels/HomeViewModelTests.swift`:

```swift
import XCTest
@testable import MoscowRealty

@MainActor
final class HomeViewModelTests: XCTestCase {

    func test_load_populatesApartments() async {
        let sut = HomeViewModel(propertyService: MockPropertyService())
        await sut.load()
        guard case .loaded(let items) = sut.featuredState else {
            XCTFail("Expected .loaded, got \(sut.featuredState)")
            return
        }
        XCTAssertFalse(items.isEmpty)
        XCTAssertTrue(items.allSatisfy { $0.propertyType == .apartment })
    }

    func test_load_setsLoadingThenLoaded() async {
        let sut = HomeViewModel(propertyService: MockPropertyService())
        XCTAssertEqual(sut.featuredState.isLoading, false)
        let task = Task { await sut.load() }
        await task.value
        guard case .loaded = sut.featuredState else {
            XCTFail("Expected .loaded after task")
            return
        }
    }
}
```

- [ ] **Step 2: Run test — expect FAIL**

```bash
xcodebuild test \
  -project MoscowRealty.xcodeproj \
  -scheme MoscowRealty \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=17.5' \
  -only-testing:MoscowRealtyTests/HomeViewModelTests \
  2>&1 | grep -E "(PASSED|FAILED|error:)"
```

Expected: compile error — `HomeViewModel` not defined.

- [ ] **Step 3: Implement HomeViewModel.swift**

`MoscowRealty/Features/Home/ViewModel/HomeViewModel.swift`:

```swift
import Observation
import Foundation

@Observable
@MainActor
final class HomeViewModel {
    var featuredState: ViewState<[Property]> = .idle
    var selectedPropertyType: PropertyType = .apartment
    var selectedListingType: ListingType = .buy

    private let propertyService: any PropertyServiceProtocol

    init(propertyService: any PropertyServiceProtocol = MockPropertyService()) {
        self.propertyService = propertyService
    }

    func load() async {
        featuredState = .loading
        var filter = SearchFilter()
        filter.propertyType = selectedPropertyType
        filter.listingType  = selectedListingType
        let results = await propertyService.fetchProperties(filter: filter)
        featuredState = .loaded(results)
    }

    func selectType(_ type: PropertyType) async {
        selectedPropertyType = type
        await load()
    }

    func selectListingType(_ type: ListingType) async {
        selectedListingType = type
        await load()
    }
}
```

- [ ] **Step 4: Run test — expect PASS**

```bash
xcodebuild test \
  -project MoscowRealty.xcodeproj \
  -scheme MoscowRealty \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=17.5' \
  -only-testing:MoscowRealtyTests/HomeViewModelTests \
  2>&1 | grep -E "(PASSED|FAILED|error:)"
```

- [ ] **Step 5: Implement PropertyCard.swift**

`MoscowRealty/Features/Home/View/PropertyCard.swift`:

```swift
import SwiftUI

struct PropertyCard: View {
    let property: Property
    var isFavorite: Bool = false
    var onFavoriteTap: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            imageSection
            infoSection
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)
    }

    private var imageSection: some View {
        ZStack(alignment: .topTrailing) {
            Image(property.imageNames.first ?? "placeholder")
                .resizable()
                .aspectRatio(4/3, contentMode: .fill)
                .frame(height: 180)
                .clipped()

            if let onFavoriteTap {
                Button(action: onFavoriteTap) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(isFavorite ? .red : .white)
                        .padding(8)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .padding(8)
            }
        }
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(property.formattedPrice)
                .font(.headline)
            Text(property.title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            HStack(spacing: 4) {
                if let metro = property.metro {
                    Image(systemName: "tram.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(metro)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(property.formattedArea)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
    }
}

#Preview {
    PropertyCard(
        property: MockPropertyService.seedData()[0],
        isFavorite: false
    )
    .frame(width: 280)
    .padding()
}
```

- [ ] **Step 6: Implement HomeView.swift (replace stub)**

`MoscowRealty/Features/Home/View/HomeView.swift`:

```swift
import SwiftUI

struct HomeView: View {
    @Environment(AppCoordinator.self) private var app
    @Environment(MainCoordinator.self) private var coordinator
    @Environment(\.propertyService) private var propertyService
    @State private var viewModel: HomeViewModel?
    @State private var showCatalog = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                heroSection
                if let vm = viewModel {
                    typePickerSection(vm: vm)
                    listingTypePickerSection(vm: vm)
                    featuredSection(vm: vm)
                }
            }
        }
        .navigationTitle("МоскваРиелти")
        .navigationBarTitleDisplayMode(.large)
        .task {
            let vm = HomeViewModel(propertyService: propertyService)
            viewModel = vm
            await vm.load()
        }
    }

    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            Image("apt_arbat_1")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 200)
                .clipped()
            LinearGradient(
                colors: [.clear, .black.opacity(0.6)],
                startPoint: .top, endPoint: .bottom
            )
            .frame(height: 200)
            Text("Квартиры в новостройках\nот застройщика")
                .font(.title2).bold()
                .foregroundStyle(.white)
                .padding()
        }
        .frame(maxWidth: .infinity)
    }

    private func typePickerSection(vm: HomeViewModel) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(PropertyType.allCases, id: \.self) { type in
                    Button(type.displayName) {
                        Task { await vm.selectType(type) }
                    }
                    .buttonStyle(.bordered)
                    .tint(vm.selectedPropertyType == type ? .primary : .secondary)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 12)
    }

    private func listingTypePickerSection(vm: HomeViewModel) -> some View {
        Picker("", selection: Binding(
            get: { vm.selectedListingType },
            set: { type in Task { await vm.selectListingType(type) } }
        )) {
            ForEach(ListingType.allCases, id: \.self) { type in
                Text(type.displayName).tag(type)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.bottom, 12)
    }

    private func featuredSection(vm: HomeViewModel) -> some View {
        Group {
            switch vm.featuredState {
            case .idle, .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 200)
            case .loaded(let properties):
                LazyVStack(spacing: 16) {
                    ForEach(properties) { property in
                        PropertyCard(property: property)
                            .padding(.horizontal)
                            .onTapGesture {
                                coordinator.showDetail(property)
                            }
                    }
                }
                .padding(.bottom, 20)
            case .error(let msg):
                Text(msg)
                    .foregroundStyle(.red)
                    .padding()
            }
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .environment(AppCoordinator())
            .environment(MainCoordinator())
            .environment(\.propertyService, MockPropertyService())
    }
}
```

- [ ] **Step 7: Build and run — verify Home tab shows property list**

```bash
xcodebuild build \
  -project MoscowRealty.xcodeproj \
  -scheme MoscowRealty \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=17.5' \
  2>&1 | grep -E "(BUILD|error:)"
```

- [ ] **Step 8: Commit**

```bash
git add MoscowRealty/Features/Home/ MoscowRealtyTests/ViewModels/HomeViewModelTests.swift
git commit -m "feat: add HomeViewModel, HomeView, PropertyCard"
```

---

### Task 11: CatalogViewModel + CatalogView + CatalogMapView

**Files:**
- Create: `MoscowRealty/Features/Catalog/ViewModel/CatalogViewModel.swift`
- Create: `MoscowRealty/Features/Catalog/View/CatalogView.swift`
- Modify: `MoscowRealty/Features/Catalog/View/CatalogMapView.swift`
- Create: `MoscowRealtyTests/ViewModels/CatalogViewModelTests.swift`

- [ ] **Step 1: Write failing test**

`MoscowRealtyTests/ViewModels/CatalogViewModelTests.swift`:

```swift
import XCTest
@testable import MoscowRealty

@MainActor
final class CatalogViewModelTests: XCTestCase {

    func test_load_returnsPropertiesMatchingFilter() async {
        let sut = CatalogViewModel(propertyService: MockPropertyService())
        sut.filter.propertyType = .parking
        sut.filter.listingType  = .buy
        await sut.load()
        guard case .loaded(let items) = sut.state else {
            XCTFail("Expected .loaded")
            return
        }
        XCTAssertTrue(items.allSatisfy { $0.propertyType == .parking && $0.listingType == .buy })
    }

    func test_load_apartments_returnsNonEmpty() async {
        let sut = CatalogViewModel(propertyService: MockPropertyService())
        await sut.load()
        guard case .loaded(let items) = sut.state else {
            XCTFail("Expected .loaded")
            return
        }
        XCTAssertFalse(items.isEmpty)
    }

    func test_applyFilter_updatesResults() async {
        let sut = CatalogViewModel(propertyService: MockPropertyService())
        await sut.load()
        guard case .loaded(let allApartments) = sut.state else { XCTFail(); return }

        sut.filter.rooms = [1]
        await sut.load()
        guard case .loaded(let oneRoom) = sut.state else { XCTFail(); return }
        XCTAssertTrue(oneRoom.count <= allApartments.count)
        XCTAssertTrue(oneRoom.allSatisfy { $0.rooms == 1 })
    }
}
```

- [ ] **Step 2: Run test — expect FAIL**

```bash
xcodebuild test \
  -project MoscowRealty.xcodeproj \
  -scheme MoscowRealty \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=17.5' \
  -only-testing:MoscowRealtyTests/CatalogViewModelTests \
  2>&1 | grep -E "(PASSED|FAILED|error:)"
```

- [ ] **Step 3: Implement CatalogViewModel.swift**

`MoscowRealty/Features/Catalog/ViewModel/CatalogViewModel.swift`:

```swift
import Observation
import Foundation

@Observable
@MainActor
final class CatalogViewModel {
    var state: ViewState<[Property]> = .idle
    var filter: SearchFilter = SearchFilter()
    var showMap: Bool = false

    private let propertyService: any PropertyServiceProtocol

    init(propertyService: any PropertyServiceProtocol = MockPropertyService()) {
        self.propertyService = propertyService
    }

    func load() async {
        state = .loading
        let results = await propertyService.fetchProperties(filter: filter)
        state = .loaded(results)
    }

    func toggleView() { showMap.toggle() }
}
```

- [ ] **Step 4: Run test — expect PASS**

```bash
xcodebuild test \
  -project MoscowRealty.xcodeproj \
  -scheme MoscowRealty \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=17.5' \
  -only-testing:MoscowRealtyTests/CatalogViewModelTests \
  2>&1 | grep -E "(PASSED|FAILED|error:)"
```

- [ ] **Step 5: Implement CatalogView.swift**

`MoscowRealty/Features/Catalog/View/CatalogView.swift`:

```swift
import SwiftUI

struct CatalogView: View {
    @Environment(MainCoordinator.self) private var coordinator
    @Environment(\.propertyService) private var propertyService
    @Environment(\.favoritesService) private var favorites
    @State private var viewModel: CatalogViewModel?
    let initialFilter: SearchFilter

    init(filter: SearchFilter = SearchFilter()) {
        self.initialFilter = filter
    }

    var body: some View {
        Group {
            if let vm = viewModel {
                content(vm: vm)
            } else {
                ProgressView()
            }
        }
        .task {
            let vm = CatalogViewModel(propertyService: propertyService)
            vm.filter = initialFilter
            viewModel = vm
            await vm.load()
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var navigationTitle: String {
        viewModel?.filter.propertyType.displayName ?? "Каталог"
    }

    @ViewBuilder
    private func content(vm: CatalogViewModel) -> some View {
        VStack(spacing: 0) {
            // List / Map toggle
            HStack {
                Spacer()
                Button {
                    vm.toggleView()
                } label: {
                    Image(systemName: vm.showMap ? "list.bullet" : "map")
                }
                .padding(.trailing)
            }
            .padding(.vertical, 8)

            if vm.showMap {
                CatalogMapView(properties: vm.state.value ?? [])
            } else {
                listContent(vm: vm)
            }
        }
    }

    private func listContent(vm: CatalogViewModel) -> some View {
        Group {
            switch vm.state {
            case .idle, .loading:
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            case .loaded(let properties):
                if properties.isEmpty {
                    ContentUnavailableView(
                        "Нет объявлений",
                        systemImage: "house.slash",
                        description: Text("Попробуйте изменить фильтры")
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(properties) { property in
                                PropertyCard(
                                    property: property,
                                    isFavorite: favorites.isFavorite(id: property.id),
                                    onFavoriteTap: { favorites.toggle(id: property.id) }
                                )
                                .padding(.horizontal)
                                .onTapGesture { coordinator.showDetail(property) }
                            }
                        }
                        .padding(.bottom, 20)
                    }
                }
            case .error(let msg):
                Text(msg).foregroundStyle(.red).padding()
            }
        }
    }
}
```

- [ ] **Step 6: Implement CatalogMapView.swift (replace stub)**

`MoscowRealty/Features/Catalog/View/CatalogMapView.swift`:

```swift
import SwiftUI
import MapKit

struct CatalogMapView: View {
    let properties: [Property]
    @Environment(MainCoordinator.self) private var coordinator
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6176),
            span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
        )
    )
    @State private var selectedProperty: Property?

    var body: some View {
        Map(position: $cameraPosition, selection: $selectedProperty) {
            ForEach(properties) { property in
                Annotation(
                    property.formattedPrice,
                    coordinate: CLLocationCoordinate2D(
                        latitude: property.coordinates.latitude,
                        longitude: property.coordinates.longitude
                    ),
                    anchor: .bottom
                ) {
                    VStack(spacing: 0) {
                        Text(property.formattedPrice)
                            .font(.caption2).bold()
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(selectedProperty?.id == property.id ? Color.primary : Color(.systemBackground))
                            .foregroundStyle(selectedProperty?.id == property.id ? Color(.systemBackground) : Color.primary)
                            .clipShape(Capsule())
                            .shadow(radius: 2)
                        Image(systemName: "arrowtriangle.down.fill")
                            .font(.system(size: 6))
                            .foregroundStyle(selectedProperty?.id == property.id ? Color.primary : Color(.systemBackground))
                    }
                    .onTapGesture { selectedProperty = property }
                }
                .tag(property)
            }
        }
        .mapStyle(.standard)
        .overlay(alignment: .bottom) {
            if let selected = selectedProperty {
                propertyPreviewCard(selected)
            }
        }
    }

    private func propertyPreviewCard(_ property: Property) -> some View {
        PropertyCard(property: property)
            .frame(maxWidth: .infinity)
            .padding()
            .background(.regularMaterial)
            .onTapGesture { coordinator.showDetail(property) }
    }
}
```

Note: `Property` must conform to `Hashable` for `Map(selection:)`. Add `Hashable` conformance to `Property` in `Core/Models/Property.swift`:

```swift
// In Property.swift — add Hashable
struct Property: Identifiable, Codable, Equatable, Hashable {
    // hash by id only
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
```

Also add `Hashable` to `Coordinates`:
```swift
struct Coordinates: Codable, Equatable, Hashable { ... }
```

- [ ] **Step 7: Build and run**

```bash
xcodebuild build \
  -project MoscowRealty.xcodeproj \
  -scheme MoscowRealty \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=17.5' \
  2>&1 | grep -E "(BUILD|error:)"
```

- [ ] **Step 8: Commit**

```bash
git add MoscowRealty/Features/Catalog/ \
        MoscowRealty/Core/Models/Property.swift \
        MoscowRealtyTests/ViewModels/CatalogViewModelTests.swift
git commit -m "feat: add CatalogViewModel, CatalogView, CatalogMapView with MapKit pins"
```

---

### Task 12: PropertyDetailView

**Files:**
- Create: `MoscowRealty/Features/PropertyDetail/ViewModel/PropertyDetailViewModel.swift`
- Modify: `MoscowRealty/Features/PropertyDetail/View/PropertyDetailView.swift`
- Create: `MoscowRealty/Features/PropertyDetail/View/PhotoGalleryView.swift`
- Create: `MoscowRealty/Features/PropertyDetail/View/MapSingleView.swift`

- [ ] **Step 1: Implement PropertyDetailViewModel.swift**

`MoscowRealty/Features/PropertyDetail/ViewModel/PropertyDetailViewModel.swift`:

```swift
import Observation
import Foundation

@Observable
@MainActor
final class PropertyDetailViewModel {
    let property: Property
    var isFavorite: Bool

    private let favoritesService: any FavoritesServiceProtocol

    init(property: Property, favoritesService: any FavoritesServiceProtocol = FavoritesService()) {
        self.property = property
        self.favoritesService = favoritesService
        self.isFavorite = favoritesService.isFavorite(id: property.id)
    }

    func toggleFavorite() {
        favoritesService.toggle(id: property.id)
        isFavorite = favoritesService.isFavorite(id: property.id)
    }

    var specsRows: [(label: String, value: String)] {
        var rows: [(String, String)] = []
        if let rooms = property.rooms    { rows.append(("Комнат", "\(rooms)")) }
        rows.append(("Площадь", property.formattedArea))
        if let floor = property.floor,
           let total = property.totalFloors { rows.append(("Этаж", "\(floor) из \(total)")) }
        if property.isNewBuilding            { rows.append(("Тип", "Новостройка")) }
        if let heated = property.isHeated   { rows.append(("Отопление", heated ? "Есть" : "Нет")) }
        if let metro = property.metro        { rows.append(("Метро", metro)) }
        rows.append(("Район", property.district))
        return rows
    }
}
```

- [ ] **Step 2: Implement PhotoGalleryView.swift**

`MoscowRealty/Features/PropertyDetail/View/PhotoGalleryView.swift`:

```swift
import SwiftUI

struct PhotoGalleryView: View {
    let imageNames: [String]
    @State private var currentIndex = 0

    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(imageNames.indices, id: \.self) { idx in
                Image(imageNames[idx])
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
                    .tag(idx)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .frame(height: 280)
    }
}
```

- [ ] **Step 3: Implement MapSingleView.swift**

`MoscowRealty/Features/PropertyDetail/View/MapSingleView.swift`:

```swift
import SwiftUI
import MapKit

struct MapSingleView: View {
    let coordinates: Coordinates
    let title: String

    private var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
    }

    var body: some View {
        Map {
            Marker(title, coordinate: coordinate)
        }
        .mapStyle(.standard)
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .allowsHitTesting(false)
    }
}
```

- [ ] **Step 4: Implement PropertyDetailView.swift (replace stub)**

`MoscowRealty/Features/PropertyDetail/View/PropertyDetailView.swift`:

```swift
import SwiftUI

struct PropertyDetailView: View {
    let property: Property
    @Environment(\.favoritesService) private var favoritesService
    @Environment(ChatCoordinator.self) private var chatCoordinator
    @State private var viewModel: PropertyDetailViewModel?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if let vm = viewModel {
                    PhotoGalleryView(imageNames: property.imageNames)

                    VStack(alignment: .leading, spacing: 16) {
                        priceAndTitle(vm: vm)
                        Divider()
                        specsGrid(vm: vm)
                        Divider()
                        descriptionSection
                        Divider()
                        mapSection
                        contactButton
                    }
                    .padding()
                } else {
                    ProgressView().frame(maxWidth: .infinity, minHeight: 400)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if let vm = viewModel {
                    Button { vm.toggleFavorite() } label: {
                        Image(systemName: vm.isFavorite ? "heart.fill" : "heart")
                            .foregroundStyle(vm.isFavorite ? .red : .primary)
                    }
                }
            }
        }
        .task {
            viewModel = PropertyDetailViewModel(
                property: property,
                favoritesService: favoritesService
            )
        }
    }

    private func priceAndTitle(vm: PropertyDetailViewModel) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(property.formattedPrice)
                .font(.title).bold()
            Text(property.title)
                .font(.title3)
                .foregroundStyle(.secondary)
            Text(property.address)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private func specsGrid(vm: PropertyDetailViewModel) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(vm.specsRows, id: \.label) { row in
                VStack(alignment: .leading, spacing: 2) {
                    Text(row.label)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(row.value)
                        .font(.subheadline).bold()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Описание")
                .font(.headline)
            Text(property.description)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    private var mapSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("На карте")
                .font(.headline)
            MapSingleView(coordinates: property.coordinates, title: property.address)
        }
    }

    private var contactButton: some View {
        Button {
            // Chat is wired in Phase 4; for now just navigate to chat tab
        } label: {
            Label("Написать агенту", systemImage: "message.fill")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .padding(.top, 8)
    }
}

#Preview {
    NavigationStack {
        PropertyDetailView(property: MockPropertyService.seedData()[0])
            .environment(\.favoritesService, FavoritesService())
            .environment(ChatCoordinator())
    }
}
```

- [ ] **Step 5: Build**

```bash
xcodebuild build \
  -project MoscowRealty.xcodeproj \
  -scheme MoscowRealty \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=17.5' \
  2>&1 | grep -E "(BUILD|error:)"
```

- [ ] **Step 6: Commit**

```bash
git add MoscowRealty/Features/PropertyDetail/
git commit -m "feat: add PropertyDetailView with photo gallery, specs grid, MapKit"
```

---

### Task 13: SearchViewModel + SearchView + SearchFilterSheet

**Files:**
- Create: `MoscowRealty/Features/Search/ViewModel/SearchViewModel.swift`
- Modify: `MoscowRealty/Features/Search/View/SearchView.swift`
- Modify: `MoscowRealty/Features/Search/View/SearchFilterSheet.swift`
- Create: `MoscowRealtyTests/ViewModels/SearchViewModelTests.swift`

- [ ] **Step 1: Write failing test**

`MoscowRealtyTests/ViewModels/SearchViewModelTests.swift`:

```swift
import XCTest
@testable import MoscowRealty

@MainActor
final class SearchViewModelTests: XCTestCase {

    func test_search_emptyQuery_returnsAll() async {
        let sut = SearchViewModel(propertyService: MockPropertyService())
        await sut.search()
        guard case .loaded(let items) = sut.state else { XCTFail(); return }
        XCTAssertFalse(items.isEmpty)
    }

    func test_search_withParkingFilter_onlyParking() async {
        let sut = SearchViewModel(propertyService: MockPropertyService())
        sut.filter.propertyType = .parking
        await sut.search()
        guard case .loaded(let items) = sut.state else { XCTFail(); return }
        XCTAssertTrue(items.allSatisfy { $0.propertyType == .parking })
    }

    func test_resetFilter_clearsFilter() {
        let sut = SearchViewModel(propertyService: MockPropertyService())
        sut.filter.priceMin = 5_000_000
        sut.filter.rooms = [2, 3]
        sut.resetFilter()
        XCTAssertNil(sut.filter.priceMin)
        XCTAssertTrue(sut.filter.rooms.isEmpty)
    }
}
```

- [ ] **Step 2: Run test — expect FAIL**

```bash
xcodebuild test \
  -project MoscowRealty.xcodeproj \
  -scheme MoscowRealty \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=17.5' \
  -only-testing:MoscowRealtyTests/SearchViewModelTests \
  2>&1 | grep -E "(PASSED|FAILED|error:)"
```

- [ ] **Step 3: Implement SearchViewModel.swift**

`MoscowRealty/Features/Search/ViewModel/SearchViewModel.swift`:

```swift
import Observation
import Foundation

@Observable
@MainActor
final class SearchViewModel {
    var state: ViewState<[Property]> = .idle
    var filter: SearchFilter = SearchFilter()
    var queryText: String = ""

    private let propertyService: any PropertyServiceProtocol

    init(propertyService: any PropertyServiceProtocol = MockPropertyService()) {
        self.propertyService = propertyService
    }

    func search() async {
        state = .loading
        var f = filter
        if !queryText.trimmingCharacters(in: .whitespaces).isEmpty {
            f.metro = queryText
        }
        let results = await propertyService.fetchProperties(filter: f)
        state = .loaded(results)
    }

    func resetFilter() {
        filter = SearchFilter()
        queryText = ""
    }
}
```

- [ ] **Step 4: Run test — expect PASS**

```bash
xcodebuild test \
  -project MoscowRealty.xcodeproj \
  -scheme MoscowRealty \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=17.5' \
  -only-testing:MoscowRealtyTests/SearchViewModelTests \
  2>&1 | grep -E "(PASSED|FAILED|error:)"
```

- [ ] **Step 5: Implement SearchView.swift (replace stub)**

`MoscowRealty/Features/Search/View/SearchView.swift`:

```swift
import SwiftUI

struct SearchView: View {
    @Environment(SearchCoordinator.self) private var coordinator
    @Environment(\.propertyService) private var propertyService
    @State private var viewModel: SearchViewModel?

    var body: some View {
        Group {
            if let vm = viewModel {
                content(vm: vm)
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Поиск")
        .task {
            let vm = SearchViewModel(propertyService: propertyService)
            viewModel = vm
            await vm.search()
        }
    }

    private func content(vm: SearchViewModel) -> some View {
        VStack(spacing: 0) {
            searchBar(vm: vm)
            filterChips(vm: vm)
            results(vm: vm)
        }
    }

    private func searchBar(vm: SearchViewModel) -> some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
            TextField("Метро, адрес или район", text: Binding(
                get: { vm.queryText },
                set: { vm.queryText = $0 }
            ))
            .onSubmit { Task { await vm.search() } }
            .submitLabel(.search)

            if !vm.queryText.isEmpty {
                Button { vm.queryText = ""; Task { await vm.search() } } label: {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
            }
        }
        .padding(10)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding()
    }

    private func filterChips(vm: SearchViewModel) -> some View {
        HStack {
            Button {
                coordinator.showFilter()
            } label: {
                Label("Фильтры", systemImage: "slider.horizontal.3")
                    .font(.subheadline)
            }
            .buttonStyle(.bordered)

            if !vm.filter.isEmpty {
                Button("Сбросить") {
                    vm.resetFilter()
                    Task { await vm.search() }
                }
                .font(.subheadline)
                .foregroundStyle(.red)
            }
            Spacer()
            Text(vm.state.value.map { "\($0.count) объявл." } ?? "")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private func results(vm: SearchViewModel) -> some View {
        switch vm.state {
        case .idle, .loading:
            ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loaded(let properties):
            if properties.isEmpty {
                ContentUnavailableView.search(text: vm.queryText)
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(properties) { property in
                            PropertyCard(property: property)
                                .padding(.horizontal)
                                .onTapGesture { coordinator.showDetail(property) }
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
        case .error(let msg):
            Text(msg).foregroundStyle(.red).padding()
        }
    }
}
```

- [ ] **Step 6: Implement SearchFilterSheet.swift (replace stub)**

`MoscowRealty/Features/Search/View/SearchFilterSheet.swift`:

```swift
import SwiftUI

struct SearchFilterSheet: View {
    @Environment(SearchCoordinator.self) private var coordinator
    @Environment(\.dismiss) private var dismiss
    @State private var localFilter = SearchFilter()

    var onApply: ((SearchFilter) -> Void)?

    var body: some View {
        NavigationStack {
            Form {
                Section("Тип объекта") {
                    Picker("Тип", selection: $localFilter.propertyType) {
                        ForEach(PropertyType.allCases, id: \.self) {
                            Text($0.displayName).tag($0)
                        }
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.clear)

                    Picker("Сделка", selection: $localFilter.listingType) {
                        ForEach(ListingType.allCases, id: \.self) {
                            Text($0.displayName).tag($0)
                        }
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.clear)
                }

                Section("Комнатность") {
                    HStack {
                        ForEach([1, 2, 3, 4], id: \.self) { n in
                            Toggle(isOn: Binding(
                                get: { localFilter.rooms.contains(n) },
                                set: { on in
                                    if on { localFilter.rooms.insert(n) }
                                    else  { localFilter.rooms.remove(n) }
                                }
                            )) {
                                Text(n < 4 ? "\(n)-комн." : "4+")
                                    .font(.subheadline)
                            }
                            .toggleStyle(.button)
                        }
                    }
                    .listRowBackground(Color.clear)
                }

                Section("Цена, ₽") {
                    HStack {
                        TextField("От", value: $localFilter.priceMin, format: .number)
                            .keyboardType(.numberPad)
                        Text("—")
                        TextField("До", value: $localFilter.priceMax, format: .number)
                            .keyboardType(.numberPad)
                    }
                }

                Section("Площадь, м²") {
                    HStack {
                        TextField("От", value: $localFilter.areaMin, format: .number)
                            .keyboardType(.decimalPad)
                        Text("—")
                        TextField("До", value: $localFilter.areaMax, format: .number)
                            .keyboardType(.decimalPad)
                    }
                }

                Section("Метро") {
                    TextField("Название станции", text: Binding(
                        get: { localFilter.metro ?? "" },
                        set: { localFilter.metro = $0.isEmpty ? nil : $0 }
                    ))
                }
            }
            .navigationTitle("Фильтры")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Сбросить") { localFilter = SearchFilter() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Применить") {
                        onApply?(localFilter)
                        dismiss()
                    }
                    .bold()
                }
            }
        }
    }
}
```

- [ ] **Step 7: Build**

```bash
xcodebuild build \
  -project MoscowRealty.xcodeproj \
  -scheme MoscowRealty \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=17.5' \
  2>&1 | grep -E "(BUILD|error:)"
```

- [ ] **Step 8: Commit**

```bash
git add MoscowRealty/Features/Search/ \
        MoscowRealtyTests/ViewModels/SearchViewModelTests.swift
git commit -m "feat: add SearchViewModel, SearchView, SearchFilterSheet"
```

---

### Task 14: FavoritesViewModel + FavoritesView

**Files:**
- Create: `MoscowRealty/Features/Favorites/ViewModel/FavoritesViewModel.swift`
- Create: `MoscowRealty/Features/Favorites/View/FavoritesView.swift`

- [ ] **Step 1: Implement FavoritesViewModel.swift**

`MoscowRealty/Features/Favorites/ViewModel/FavoritesViewModel.swift`:

```swift
import Observation
import Foundation

@Observable
@MainActor
final class FavoritesViewModel {
    var state: ViewState<[Property]> = .idle

    private let propertyService:  any PropertyServiceProtocol
    private let favoritesService: any FavoritesServiceProtocol

    init(
        propertyService:  any PropertyServiceProtocol  = MockPropertyService(),
        favoritesService: any FavoritesServiceProtocol = FavoritesService()
    ) {
        self.propertyService  = propertyService
        self.favoritesService = favoritesService
    }

    func load() async {
        state = .loading
        let ids = favoritesService.fetchAllIds()
        if ids.isEmpty {
            state = .loaded([])
            return
        }
        // Fetch all and filter by saved ids
        let filter = SearchFilter()
        // We fetch all property types; filter locally by id
        var all: [Property] = []
        for type in PropertyType.allCases {
            var f = filter
            f.propertyType = type
            f.listingType  = .buy
            all += await propertyService.fetchProperties(filter: f)
            f.listingType  = .rent
            all += await propertyService.fetchProperties(filter: f)
        }
        let favorites = all.filter { ids.contains($0.id) }
        state = .loaded(favorites)
    }

    func removeFavorite(id: UUID) async {
        favoritesService.toggle(id: id)
        await load()
    }
}
```

- [ ] **Step 2: Implement FavoritesView.swift**

`MoscowRealty/Features/Favorites/View/FavoritesView.swift`:

```swift
import SwiftUI

struct FavoritesView: View {
    @Environment(ProfileCoordinator.self) private var coordinator
    @Environment(\.propertyService)  private var propertyService
    @Environment(\.favoritesService) private var favoritesService
    @State private var viewModel: FavoritesViewModel?

    var body: some View {
        Group {
            if let vm = viewModel {
                content(vm: vm)
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Избранное")
        .task {
            let vm = FavoritesViewModel(
                propertyService: propertyService,
                favoritesService: favoritesService
            )
            viewModel = vm
            await vm.load()
        }
    }

    @ViewBuilder
    private func content(vm: FavoritesViewModel) -> some View {
        switch vm.state {
        case .idle, .loading:
            ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loaded(let properties):
            if properties.isEmpty {
                ContentUnavailableView(
                    "Нет избранных",
                    systemImage: "heart.slash",
                    description: Text("Добавьте объявления в избранное")
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(properties) { property in
                            PropertyCard(
                                property: property,
                                isFavorite: true,
                                onFavoriteTap: {
                                    Task { await vm.removeFavorite(id: property.id) }
                                }
                            )
                            .padding(.horizontal)
                            .onTapGesture { coordinator.showPropertyDetail(property) }
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
        case .error(let msg):
            Text(msg).foregroundStyle(.red).padding()
        }
    }
}
```

- [ ] **Step 3: Build and run all tests**

```bash
xcodebuild test \
  -project MoscowRealty.xcodeproj \
  -scheme MoscowRealty \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=17.5' \
  -only-testing:MoscowRealtyTests \
  2>&1 | grep -E "(PASSED|FAILED|Test Suite.*passed|error:)"
```

Expected: all test suites pass.

- [ ] **Step 4: Commit**

```bash
git add MoscowRealty/Features/Favorites/
git commit -m "feat: add FavoritesViewModel, FavoritesView"
```

---

**Phase 3 complete.** Proceed to `2026-05-25-moscow-realty-ios-phase4-features.md`.
