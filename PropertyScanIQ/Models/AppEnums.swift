import Foundation

enum UserType: String, CaseIterable, Identifiable {
    case landlord
    case estateAgent
    case propertyManager
    case contractor
    case airbnbHost
    case homeBuyer

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .landlord: "Landlord"
        case .estateAgent: "Estate agent"
        case .propertyManager: "Property manager"
        case .contractor: "Contractor"
        case .airbnbHost: "Airbnb host"
        case .homeBuyer: "Home buyer"
        }
    }
}

enum PropertyType: String, CaseIterable, Identifiable {
    case flat
    case house
    case commercial
    case hmo
    case airbnb
    case rental

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .flat: "Flat"
        case .house: "House"
        case .commercial: "Commercial"
        case .hmo: "HMO"
        case .airbnb: "Airbnb"
        case .rental: "Rental"
        }
    }
}

enum InspectionType: String, CaseIterable, Identifiable {
    case moveIn
    case moveOut
    case maintenance
    case prePurchase
    case contractorVisit
    case airbnbTurnover

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .moveIn: "Move-in inspection"
        case .moveOut: "Move-out inspection"
        case .maintenance: "Maintenance check"
        case .prePurchase: "Pre-purchase visual check"
        case .contractorVisit: "Contractor site visit"
        case .airbnbTurnover: "Airbnb turnover check"
        }
    }
}

enum RoomTemplate: String, CaseIterable, Identifiable {
    case kitchen
    case bathroom
    case bedroom
    case livingRoom
    case exterior
    case roofline
    case garden
    case utility
    case hallway

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .kitchen: "Kitchen"
        case .bathroom: "Bathroom"
        case .bedroom: "Bedroom"
        case .livingRoom: "Living room"
        case .exterior: "Exterior"
        case .roofline: "Roofline"
        case .garden: "Garden"
        case .utility: "Utility"
        case .hallway: "Hallway"
        }
    }
}

enum RoomCondition: String, CaseIterable, Identifiable {
    case excellent
    case good
    case fair
    case poor
    case urgent

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .excellent: "Excellent"
        case .good: "Good"
        case .fair: "Fair"
        case .poor: "Poor"
        case .urgent: "Urgent"
        }
    }
}

enum IssueSeverity: String, CaseIterable, Identifiable, Comparable, Hashable {
    case low
    case medium
    case high
    case urgent

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .low: "Low"
        case .medium: "Medium"
        case .high: "High"
        case .urgent: "Urgent"
        }
    }

    var sortRank: Int {
        switch self {
        case .low: 0
        case .medium: 1
        case .high: 2
        case .urgent: 3
        }
    }

    static func < (lhs: IssueSeverity, rhs: IssueSeverity) -> Bool {
        lhs.sortRank < rhs.sortRank
    }
}

enum IssueCategory: String, CaseIterable, Identifiable {
    case dampMould
    case cracks
    case paintDecor
    case flooring
    case plumbing
    case electricalVisibleConcern
    case roofGutterVisibleConcern
    case doorsWindows
    case safetyHazard
    case generalWear

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .dampMould: "Damp/mould"
        case .cracks: "Cracks"
        case .paintDecor: "Paint/decor"
        case .flooring: "Flooring"
        case .plumbing: "Plumbing"
        case .electricalVisibleConcern: "Electrical visible concern"
        case .roofGutterVisibleConcern: "Roof/gutter visible concern"
        case .doorsWindows: "Doors/windows"
        case .safetyHazard: "Safety hazard"
        case .generalWear: "General wear"
        }
    }
}

enum InspectionStatus: String, CaseIterable, Identifiable {
    case draft
    case inProgress
    case review
    case completed

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .draft: "Draft"
        case .inProgress: "In progress"
        case .review: "Review"
        case .completed: "Completed"
        }
    }
}

enum SubscriptionPlan: String, CaseIterable, Identifiable {
    case free
    case proMonthly
    case proYearly
    case businessMonthly

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .free: "Free"
        case .proMonthly: "Pro monthly"
        case .proYearly: "Pro yearly"
        case .businessMonthly: "Business monthly"
        }
    }

    var priceText: String {
        switch self {
        case .free: "GBP 0"
        case .proMonthly: "\u{00A3}19.99/mo"
        case .proYearly: "\u{00A3}149.99/yr"
        case .businessMonthly: "\u{00A3}49.99/mo"
        }
    }

    var isPaid: Bool { self != .free }
}

enum AppRoute: Hashable, Identifiable {
    case inspectionBuilder
    case property(UUID)
    case roomScan(inspectionID: UUID, roomID: UUID)
    case reportGenerator(UUID)
    case pdfExport(UUID)
    case paywall

    var id: String {
        switch self {
        case .inspectionBuilder: "inspectionBuilder"
        case .property(let id): "property-\(id.uuidString)"
        case .roomScan(let inspectionID, let roomID): "roomScan-\(inspectionID.uuidString)-\(roomID.uuidString)"
        case .reportGenerator(let id): "reportGenerator-\(id.uuidString)"
        case .pdfExport(let id): "pdfExport-\(id.uuidString)"
        case .paywall: "paywall"
        }
    }
}
