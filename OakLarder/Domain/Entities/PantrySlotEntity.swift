import Foundation

enum PantrySlotEntity: String, CaseIterable, Sendable, Equatable {
    case morningLoaf
    case noonBoard
    case duskRoast
    case nightCrumb

    var plaqueTitle: String {
        switch self {
        case .morningLoaf: "Morning loaf"
        case .noonBoard: "Noon board"
        case .duskRoast: "Dusk roast"
        case .nightCrumb: "Night crumb"
        }
    }

    var artName: String {
        switch self {
        case .morningLoaf: "SlotMorningLoaf"
        case .noonBoard: "SlotNoonBoard"
        case .duskRoast: "SlotDuskRoast"
        case .nightCrumb: "SlotNightCrumb"
        }
    }

    var isCrumbOnly: Bool { self == .nightCrumb }
}
