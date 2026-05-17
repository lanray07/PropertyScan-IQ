import SwiftData
import SwiftUI

struct PropertyProfileView: View {
    @Bindable var property: Property
    @Query(sort: \Inspection.createdAt, order: .reverse) private var inspections: [Inspection]
    @State private var showingEditor = false

    private var propertyInspections: [Inspection] {
        inspections.filter { $0.propertyId == property.id }
    }

    var body: some View {
        List {
            Section("Property details") {
                TextField("Property name", text: $property.name)
                TextField("Address", text: $property.address, axis: .vertical)
                Picker("Property type", selection: $property.propertyType) {
                    ForEach(PropertyType.allCases) { type in
                        Text(type.displayName).tag(type.rawValue)
                    }
                }
                TextField("Owner/client name", text: $property.clientName)
                TextEditor(text: $property.notes)
                    .frame(minHeight: 100)
            }

            Section("Inspection history") {
                if propertyInspections.isEmpty {
                    EmptyStateView(systemImage: "clock", title: "No inspections", message: "Start a new inspection from the dashboard.")
                        .listRowInsets(EdgeInsets())
                } else {
                    ForEach(propertyInspections) { inspection in
                        NavigationLink(value: AppRoute.reportGenerator(inspection.id)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(inspection.inspectionTypeLabel)
                                    .font(.headline)
                                Text("\(inspection.date.shortReportDate) - \(inspection.statusLabel)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                if !inspection.summary.isEmpty {
                                    Text(inspection.summary)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(property.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(value: AppRoute.inspectionBuilder) {
                    Image(systemName: "plus.viewfinder")
                }
                .accessibilityLabel("New inspection")
            }
        }
    }
}
