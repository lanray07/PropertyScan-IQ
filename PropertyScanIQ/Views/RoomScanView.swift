import PhotosUI
import SwiftData
import SwiftUI
import UIKit

struct RoomScanView: View {
    var inspection: Inspection
    @Bindable var roomArea: RoomArea

    @Environment(\.modelContext) private var modelContext
    @Environment(\.aiService) private var aiService
    @Query private var properties: [Property]
    @Query(sort: \RoomArea.name) private var allRooms: [RoomArea]
    @Query(sort: \InspectionPhoto.createdAt, order: .reverse) private var allPhotos: [InspectionPhoto]
    @Query(sort: \DetectedIssue.createdAt, order: .reverse) private var allIssues: [DetectedIssue]

    @StateObject private var viewModel = RoomScanViewModel()
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var showingCamera = false
    @State private var cameraError: String?

    private var property: Property? {
        properties.first { $0.id == inspection.propertyId }
    }

    private var inspectionRooms: [RoomArea] {
        allRooms.filter { $0.inspectionId == inspection.id }
    }

    private var roomPhotos: [InspectionPhoto] {
        allPhotos.filter { $0.roomAreaId == roomArea.id }
    }

    private var roomIssues: [DetectedIssue] {
        allIssues.filter { $0.roomAreaId == roomArea.id }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                roomHeader

                PhotoUploadCard(
                    photos: roomPhotos,
                    selectedItems: $selectedItems,
                    cameraAvailable: UIImagePickerController.isSourceTypeAvailable(.camera),
                    onCamera: requestCamera
                )

                notesAndCondition

                Button {
                    Task {
                        await viewModel.scan(
                            property: property,
                            inspection: inspection,
                            roomArea: roomArea,
                            photos: roomPhotos,
                            context: modelContext,
                            aiService: aiService
                        )
                    }
                } label: {
                    if viewModel.isScanning {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Label("AI scan room photos", systemImage: "sparkles")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(viewModel.isScanning)

                if let error = viewModel.errorMessage ?? cameraError {
                    Label(error, systemImage: "exclamationmark.triangle")
                        .font(.subheadline)
                        .foregroundStyle(.red)
                }

                if let summary = viewModel.lastSummary {
                    Text(summary)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .psiCard()
                }

                issueSection
            }
            .padding()
        }
        .navigationTitle(roomArea.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(value: AppRoute.reportGenerator(inspection.id)) {
                    Image(systemName: "doc.richtext")
                }
                .accessibilityLabel("Generate report")
            }
        }
        .sheet(isPresented: $showingCamera) {
            CameraPicker { image in
                viewModel.addPhoto(image: image, roomArea: roomArea, context: modelContext)
            }
            .ignoresSafeArea()
        }
        .onChange(of: selectedItems) { _, newItems in
            loadPhotos(from: newItems)
        }
    }

    private var roomHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(property?.name ?? "Property")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(PSITheme.accent)
                    Text(roomArea.name)
                        .font(.title2.bold())
                    Text(inspection.inspectionTypeLabel)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                ConditionBadge(condition: RoomCondition(rawValue: roomArea.condition) ?? .good)
            }

            if inspectionRooms.count > 1 {
                Menu {
                    ForEach(inspectionRooms) { room in
                        NavigationLink(value: AppRoute.roomScan(inspectionID: inspection.id, roomID: room.id)) {
                            Text(room.name)
                        }
                    }
                } label: {
                    Label("Switch room", systemImage: "rectangle.3.group")
                }
                .buttonStyle(.bordered)
            }
        }
        .psiCard()
    }

    private var notesAndCondition: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Room notes and condition")
                .font(.headline)
            Picker("Condition", selection: $roomArea.condition) {
                ForEach(RoomCondition.allCases) { condition in
                    Text(condition.displayName).tag(condition.rawValue)
                }
            }
            .pickerStyle(.segmented)

            TextField("Add observations, locations, odours, tenant comments, or repair notes", text: $roomArea.notes, axis: .vertical)
                .textFieldStyle(.roundedBorder)
        }
        .psiCard()
    }

    private var issueSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Detected issue cards")
                    .font(.headline)
                Spacer()
                Text("\(roomIssues.count)")
                    .font(.caption.weight(.bold))
                    .padding(8)
                    .background(PSITheme.subtlePanel, in: Circle())
            }

            if roomIssues.isEmpty {
                EmptyStateView(systemImage: "sparkle.magnifyingglass", title: "No AI findings yet", message: "Run a scan after adding photos, then edit and approve suggested findings.")
            } else {
                ForEach(roomIssues) { issue in
                    IssueCard(issue: issue)
                }
            }
        }
    }

    private func requestCamera() {
        Task {
            let granted = await PermissionService.requestCameraAccess()
            await MainActor.run {
                if granted {
                    cameraError = nil
                    showingCamera = true
                } else {
                    cameraError = "Camera access is required to take inspection photos. You can still upload from Photos."
                }
            }
        }
    }

    private func loadPhotos(from items: [PhotosPickerItem]) {
        Task {
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        viewModel.addPhoto(data: data, roomArea: roomArea, context: modelContext)
                    }
                }
            }
            await MainActor.run {
                selectedItems = []
            }
        }
    }
}
