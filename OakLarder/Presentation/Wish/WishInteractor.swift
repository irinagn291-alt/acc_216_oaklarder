import Foundation

@MainActor
final class WishInteractor {
    private let prefs: PreferenceSQLiteRepository
    private let catalog: CatalogCachedRepository

    init(prefs: PreferenceSQLiteRepository, catalog: CatalogCachedRepository) {
        self.prefs = prefs
        self.catalog = catalog
    }

    func load() async -> WishEntity {
        WishEntity(items: await prefs.wishes())
    }

    func unpin(sku: String) async {
        await prefs.unpinWish(sku: sku)
    }

    func goods(for item: WishSkuEntity) async -> LarderGoodsEntity {
        let hit = await catalog.lookup(code: item.sku)
        if let found = hit.goods.first { return found }
        if let shelf = CellarShelfStock.tins.first(where: { $0.sku == item.sku }) { return shelf }
        return LarderGoodsEntity(
            sku: item.sku,
            title: item.title,
            houseMark: item.houseMark,
            kcalPerHundred: 0,
            proteinPerHundred: 0,
            carbsPerHundred: 0,
            fatPerHundred: 0,
            origin: .cellarShelf
        )
    }
}
