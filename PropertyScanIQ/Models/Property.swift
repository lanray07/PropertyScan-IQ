import Foundation
import SwiftData

@Model
final class Property {
    @Attribute(.unique) var id: UUID
    var name: String
    var address: String
    var propertyType: String
    var clientName: String
    var notes: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        address: String,
        propertyType: String = PropertyType.flat.rawValue,
        clientName: String = "",
        notes: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.propertyType = propertyType
        self.clientName = clientName
        self.notes = notes
        self.createdAt = createdAt
    }

    var propertyTypeLabel: String {
        PropertyType(rawValue: propertyType)?.displayName ?? propertyType
    }
}
