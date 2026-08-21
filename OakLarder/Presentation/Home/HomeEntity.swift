import Foundation

struct HomeSlotBoardEntity: Sendable, Equatable {
    var slot: PantrySlotEntity
    var kcal: Double
    var titles: [String]
}

struct HomeEntity: Sendable, Equatable {
    var dayKey: String
    var spokenDay: String
    var goals: LarderGoalEntity
    var eaten: MacroPileEntity
    var slots: [HomeSlotBoardEntity]
    var log: [LarderEntryEntity]
}
