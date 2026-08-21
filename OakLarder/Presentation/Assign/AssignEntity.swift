import Foundation

struct AssignEntity: Sendable, Equatable {
    var goods: LarderGoodsEntity
    var grams: Double
    var kind: EntryKindEntity
    var dayKey: String
    var slot: PantrySlotEntity
    var allowedSlots: [PantrySlotEntity]
    var serving: ServingMathEntity
}
