import SwiftData
import SwiftUI

struct InspectionBuilderView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Property.name) private var properties: [Property]
    @StateObject private var viewModel = InspectionBuilderViewModel()
    @State private var showingPropertyEditor = false

    private let columns = [GridItem(.adaptive(minimum: 140), spacing: 10)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                if properties.isEmpty {
                    EmptyStateView(systemImage: "building.badge.plus", title: "Create a property first", message: "Inspections are linked to property profiles.")
                    Button {
                        showingPropertyEditor = true
                    } label: {
                        Label("Add Property", systemImage: "building.badge.plus")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    propertyPicker
                    inspectionTypePicker
                    roomSelector

                    if let error = viewModel.errorMessage {
                        Label(error, systemImage: "exclamationmark.triangle")
                            .font(.subheadline)
                            .foregroundStyle(.red)
                    }

                    Button {
                        viewModel.createInspection(context: modelContext)
                    } label: {
                        Label("Create inspection", systemImage: "checkmark.circle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    if let route = viewModel.createdRoute {
                        NavigationLink(value: route) {
                            Label("Open first room scan", systemImage: "camera.viewfinder")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Inspection Builder")
        .sheet(isPresented: $showingPropertyEditor) {
            NavigationStack {
                PropertyEditorView()
            }
        }
        .onAppear {
            if viewModel.selectedPropertyId == nil {
                viewModel.selectedPropertyId = properties.first?.id
            }
        }
        .onChange(of: properties.count) { _, _ in
            if viewModel.selectedPropertyId == nil {
                viewModel.selectedPropertyId = properties.first?.id
            }
        }
    }

    private var propertyPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Select property")
                    .font(.headline)
                Spacer()
                Button {
                    showingPropertyEditor = true
                } label: {
                    Image(systemName: "plus")
                }
                .buttonStyle(.bordered)
            }

            Picker("Property", selection: $viewModel.selectedPropertyId) {
                ForEach(properties) { property in
                    Text(property.name).tag(Optional(property.id))
                }
            }
            .pickerStyle(.navigationLink)
        }
        .psiCard()
    }

    private var inspectionTypePicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Inspection type")
                .font(.headline)
            Picker("Inspection type", selection: $viewModel.inspectionType) {
                ForEach(InspectionType.allCases) { type in
                    Text(type.displayName).tag(type)
                }
            }
            .pickerStyle(.navigationLink)
        }
        .psiCard()
    }

    private var roomSelector: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Rooms and areas")
                .font(.headline)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(RoomTemplate.allCases) { room in
                    let selected = viewModel.selectedRoomNames.contains(room.displayName)
                    Button {
                        viewModel.toggleRoom(room.displayName)
                    } label: {
                        HStack {
                            Text(room.displayName)
                            Spacer()
                            Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                        }
                        .font(.subheadline.weight(.semibold))
                        .padding(10)
                        .background(selected ? PSITheme.accent.opacity(0.16) : PSITheme.subtlePanel, in: RoundedRectangle(cornerRadius: PSITheme.radius))
                    }
                    .buttonStyle(.plain)
                }
            }

            HStack {
                TextField("Custom room", text: $viewModel.customRoomName)
                    .textFieldStyle(.roundedBorder)
                Button {
                    viewModel.addCustomRoom()
                } label: {
                    Image(systemName: "plus")
                }
                .buttonStyle(.borderedProminent)
            }

            if !viewModel.sortedRooms.isEmpty {
                Text("Selected: \(viewModel.sortedRooms.joined(separator: ", "))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .psiCard()
    }
}
