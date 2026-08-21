import Foundation

@MainActor
final class AssignInteractor {
    private let larder: LarderSQLiteRepository
    private let scale = PortionScaleUseCase()
    private let slots = SlotRulesUseCase()

    init(larder: LarderSQLiteRepository) {
        self.larder = larder
    }

    func allowed(for kind: EntryKindEntity) -> [PantrySlotEntity] {
        slots.allowedSlots(for: kind)
    }

    func serving(_ goods: LarderGoodsEntity, grams: Double) -> ServingMathEntity {
        scale.weigh(goods, grams: grams)
    }

    func commit(goods: LarderGoodsEntity, grams: Double, slot: PantrySlotEntity, dayKey: String, kind: EntryKindEntity) async -> Bool {
        guard slots.accepts(slot, kind: kind) else { return false }
        let serving = scale.weigh(goods, grams: grams)
        let entry = LarderEntryEntity(
            id: UUID().uuidString,
            sku: goods.sku,
            title: goods.title,
            grams: serving.grams,
            kcal: serving.kcal,
            protein: serving.protein,
            carbs: serving.carbs,
            fat: serving.fat,
            slot: slot,
            dayKey: dayKey,
            kind: kind
        )
        do {
            try await larder.insert(entry)
            return true
        } catch {
            return false
        }
    }
}
