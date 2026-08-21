import Foundation

struct DayTotalsUseCase: Sendable {
    func pile(from entries: [LarderEntryEntity], kind: EntryKindEntity) -> MacroPileEntity {
        entries
            .filter { $0.kind == kind }
            .reduce(MacroPileEntity.vacant) { $0 + $1.pile }
    }

    func pileBySlot(_ entries: [LarderEntryEntity], kind: EntryKindEntity) -> [PantrySlotEntity: MacroPileEntity] {
        var map: [PantrySlotEntity: MacroPileEntity] = [:]
        for entry in entries where entry.kind == kind {
            map[entry.slot, default: .vacant] = (map[entry.slot] ?? .vacant) + entry.pile
        }
        return map
    }
}
