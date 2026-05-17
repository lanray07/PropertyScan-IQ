import Foundation
import SwiftData

@Model
final class InspectionPhoto {
    @Attribute(.unique) var id: UUID
    var roomAreaId: UUID
    @Attribute(.externalStorage) var imageData: Data?
    var caption: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        roomAreaId: UUID,
        imageData: Data? = nil,
        caption: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.roomAreaId = roomAreaId
        self.imageData = imageData
        self.caption = caption
        self.createdAt = createdAt
    }
}
