import Foundation
import SwiftData

@MainActor
final class InspectionBuilderViewModel: ObservableObject {
    @Published var selectedPropertyId: UUID?
    @Published var inspectionType: InspectionType = .maintenance
    @Published var selectedRoomNames: Set<String> = [
        RoomTemplate.kitchen.displayName,
        RoomTemplate.bathroom.displayName,
        RoomTemplate.bedroom.displayName
    ]
    @Published var customRoomName = ""
    @Published var errorMessage: String?
    @Published var createdRoute: AppRoute?

    var sortedRooms: [String] {
        selectedRoomNames.sorted()
    }

    func toggleRoom(_ room: String) {
        if selectedRoomNames.contains(room) {
            selectedRoomNames.remove(room)
        } else {
            selectedRoomNames.insert(room)
        }
    }

    func addCustomRoom() {
        let trimmed = customRoomName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        selectedRoomNames.insert(trimmed)
        customRoomName = ""
    }

    func createInspection(context: ModelContext) {
        errorMessage = nil

        guard let selectedPropertyId else {
            errorMessage = "Choose a property before creating an inspection."
            return
        }

        guard !selectedRoomNames.isEmpty else {
            errorMessage = "Add at least one room or area."
            return
        }

        let inspection = Inspection(
            propertyId: selectedPropertyId,
            inspectionType: inspectionType.rawValue,
            status: InspectionStatus.inProgress.rawValue
        )
        context.insert(inspection)

        var firstRoomID: UUID?
        for name in sortedRooms {
            let room = RoomArea(inspectionId: inspection.id, name: name)
            if firstRoomID == nil {
                firstRoomID = room.id
            }
            context.insert(room)
        }

        do {
            try context.save()
            if let firstRoomID {
                createdRoute = .roomScan(inspectionID: inspection.id, roomID: firstRoomID)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
