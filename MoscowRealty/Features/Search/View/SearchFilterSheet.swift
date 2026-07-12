import SwiftUI

struct SearchFilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var localFilter: SearchFilter

    var onApply: ((SearchFilter) -> Void)?

    init(initialFilter: SearchFilter = SearchFilter(), onApply: ((SearchFilter) -> Void)? = nil) {
        self._localFilter = State(initialValue: initialFilter)
        self.onApply = onApply
    }

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
