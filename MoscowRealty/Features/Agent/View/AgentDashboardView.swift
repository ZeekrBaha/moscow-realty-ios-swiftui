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
