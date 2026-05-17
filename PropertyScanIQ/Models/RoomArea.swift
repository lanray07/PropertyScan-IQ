import Foundation
import SwiftData

@Model
final class RoomArea {
    @Attribute(.unique) var id: UUID
    var inspectionId: UUID
    var name: String
    var condition: String
    var notes: String

    init(
        id: UUID = UUID(),
        inspectionId: UUID,
        name: String,
        condition: String = RoomCondition.good.rawValue,
        notes: String = ""
    ) {
        self.id = id
        self.inspectionId = inspectionId
        self.name = name
        self.condition = condition
        self.notes = notes
    }

    var conditionLabel: String {
        RoomCondition(rawValue: condition)?.displayName ?? condition
    }
}
