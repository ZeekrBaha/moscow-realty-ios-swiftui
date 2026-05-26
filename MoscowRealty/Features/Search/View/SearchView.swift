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
                Button {
                    vm.queryText = ""
                    Task { await vm.search() }
                } label: {
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
            if let count = vm.state.value?.count {
                Text("\(count) объявл.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
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
