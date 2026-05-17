import Foundation
import SwiftData

@Model
final class Inspection {
    @Attribute(.unique) var id: UUID
    var propertyId: UUID
    var inspectionType: String
    var date: Date
    var status: String
    var summary: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        propertyId: UUID,
        inspectionType: String = InspectionType.maintenance.rawValue,
        date: Date = Date(),
        status: String = InspectionStatus.draft.rawValue,
        summary: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.propertyId = propertyId
        self.inspectionType = inspectionType
        self.date = date
        self.status = status
        self.summary = summary
        self.createdAt = createdAt
    }

    var inspectionTypeLabel: String {
        InspectionType(rawValue: inspectionType)?.displayName ?? inspectionType
    }

    var statusLabel: String {
        InspectionStatus(rawValue: status)?.displayName ?? status
    }
}
