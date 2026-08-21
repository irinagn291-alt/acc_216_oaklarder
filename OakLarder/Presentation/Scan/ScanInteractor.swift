import Foundation

@MainActor
final class ScanInteractor {
    private let catalog: CatalogCachedRepository
    private let ean = EanNormalizeUseCase()

    init(catalog: CatalogCachedRepository) {
        self.catalog = catalog
    }

    func normalize(_ raw: String) -> String? {
        ean.normalize(raw)
    }

    func lookup(code: String) async -> CatalogHitEntity {
        await catalog.lookup(code: code)
    }
}
