import Foundation

@MainActor
final class SearchInteractor {
    private let catalog: CatalogCachedRepository

    init(catalog: CatalogCachedRepository) {
        self.catalog = catalog
    }

    func lookup(_ query: String) async -> SearchEntity {
        let hit = await catalog.search(query)
        return SearchEntity(query: query, goods: hit.goods, fromCellarCache: hit.fromCellarCache)
    }
}
