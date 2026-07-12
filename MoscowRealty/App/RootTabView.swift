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
        // Inject AppCoordinator's service instances so all views share the same singletons
        .environment(\.authService, app.authService)
        .environment(\.propertyService, app.propertyService)
        .environment(\.chatService, app.chatService)
        .environment(\.favoritesService, app.favoritesService)
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
