import SwiftData
import SwiftUI

struct PropertyEditorView: View {
    var property: Property?

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var address: String
    @State private var propertyType: String
    @State private var clientName: String
    @State private var notes: String

    init(property: Property? = nil) {
        self.property = property
        _name = State(initialValue: property?.name ?? "")
        _address = State(initialValue: property?.address ?? "")
        _propertyType = State(initialValue: property?.propertyType ?? PropertyType.flat.rawValue)
        _clientName = State(initialValue: property?.clientName ?? "")
        _notes = State(initialValue: property?.notes ?? "")
    }

    var body: some View {
        Form {
            Section("Property profile") {
                TextField("Property name", text: $name)
                TextField("Address", text: $address, axis: .vertical)
                Picker("Property type", selection: $propertyType) {
                    ForEach(PropertyType.allCases) { type in
                        Text(type.displayName).tag(type.rawValue)
                    }
                }
                TextField("Owner/client name", text: $clientName)
                TextField("Notes", text: $notes, axis: .vertical)
            }
        }
        .navigationTitle(property == nil ? "New Property" : "Edit Property")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    save()
                }
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }

    private func save() {
        if let property {
            property.name = name
            property.address = address
            property.propertyType = propertyType
            property.clientName = clientName
            property.notes = notes
        } else {
            let property = Property(
                name: name,
                address: address,
                propertyType: propertyType,
                clientName: clientName,
                notes: notes
            )
            modelContext.insert(property)
        }

        try? modelContext.save()
        dismiss()
    }
}
