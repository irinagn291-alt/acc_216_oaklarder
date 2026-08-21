import Foundation

struct WishlistDedupUseCase: Sendable {
    func canPin(sku: String, existing: [WishSkuEntity]) -> Bool {
        !existing.contains { $0.sku == sku }
    }

    func merging(_ candidate: WishSkuEntity, into existing: [WishSkuEntity]) -> [WishSkuEntity] {
        guard canPin(sku: candidate.sku, existing: existing) else { return existing }
        return existing + [candidate]
    }
}
