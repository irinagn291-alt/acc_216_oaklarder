import Foundation

struct SlotRulesUseCase: Sendable {
    func allowedSlots(for kind: EntryKindEntity) -> [PantrySlotEntity] {
        switch kind {
        case .eaten:
            return PantrySlotEntity.allCases
        case .planned:
            return PantrySlotEntity.allCases.filter { !$0.isCrumbOnly }
        }
    }

    func accepts(_ slot: PantrySlotEntity, kind: EntryKindEntity) -> Bool {
        allowedSlots(for: kind).contains(slot)
    }
}
