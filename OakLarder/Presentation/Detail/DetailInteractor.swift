import Foundation

@MainActor
final class DetailInteractor {
    private let prefs: PreferenceSQLiteRepository
    private let scale = PortionScaleUseCase()

    init(prefs: PreferenceSQLiteRepository) {
        self.prefs = prefs
    }

    func weigh(_ goods: LarderGoodsEntity, grams: Double) -> ServingMathEntity {
        scale.weigh(goods, grams: grams)
    }

    func pin(_ goods: LarderGoodsEntity) async -> Bool {
        await prefs.pinWish(
            WishSkuEntity(
                sku: goods.sku,
                title: goods.title,
                houseMark: goods.houseMark,
                pinnedAt: Date().timeIntervalSince1970
            )
        )
    }
}
