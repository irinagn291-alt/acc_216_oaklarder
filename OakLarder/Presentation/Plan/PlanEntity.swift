import Foundation

struct PlanDayMarkEntity: Sendable, Equatable {
    var dayKey: String
    var hasPlanned: Bool
}

struct PlanEntity: Sendable, Equatable {
    var monthTitle: String
    var monthPrefix: String
    var cursor: Date
    var marks: [PlanDayMarkEntity]
    var selectedKey: String
    var selectedEntries: [LarderEntryEntity]
}
