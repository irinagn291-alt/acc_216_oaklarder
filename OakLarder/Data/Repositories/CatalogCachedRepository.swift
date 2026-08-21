import Foundation

actor CatalogCachedRepository: CatalogRepositoryProtocol {
    private let client: OffCatalogClient
    private let cache: OffDiskCache

    init(client: OffCatalogClient, cache: OffDiskCache) {
        self.client = client
        self.cache = cache
    }

    func shelfGoods() async -> [LarderGoodsEntity] {
        CellarShelfStock.tins
    }

    func search(_ query: String) async -> CatalogHitEntity {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let shelf = CellarShelfStock.tins.filter { tin in
            trimmed.isEmpty
                || tin.title.localizedCaseInsensitiveContains(trimmed)
                || (tin.houseMark?.localizedCaseInsensitiveContains(trimmed) ?? false)
        }
        guard !trimmed.isEmpty else {
            return CatalogHitEntity(goods: shelf, fromCellarCache: true)
        }
        let key = "search:\(trimmed.lowercased())"
        do {
            let data = try await client.search(query: trimmed)
            await cache.store(data, for: key)
            let remote = await client.parseSearch(data)
            return CatalogHitEntity(goods: merge(shelf, remote), fromCellarCache: false)
        } catch {
            if let data = await cache.payload(for: key) {
                let remote = await client.parseSearch(data)
                return CatalogHitEntity(goods: merge(shelf, remote), fromCellarCache: true)
            }
            return CatalogHitEntity(goods: shelf, fromCellarCache: true)
        }
    }

    func lookup(code: String) async -> CatalogHitEntity {
        if let local = CellarShelfStock.tins.first(where: { $0.sku == code }) {
            return CatalogHitEntity(goods: [local], fromCellarCache: true)
        }
        let key = "code:\(code)"
        do {
            let data = try await client.product(code: code)
            await cache.store(data, for: key)
            if let goods = await client.parseProduct(data) {
                return CatalogHitEntity(goods: [goods], fromCellarCache: false)
            }
        } catch {
            // offline path below
        }
        if let data = await cache.payload(for: key), let goods = await client.parseProduct(data) {
            return CatalogHitEntity(goods: [goods], fromCellarCache: true)
        }
        return CatalogHitEntity(goods: [], fromCellarCache: true)
    }

    private func merge(_ shelf: [LarderGoodsEntity], _ remote: [LarderGoodsEntity]) -> [LarderGoodsEntity] {
        var seen = Set(shelf.map(\.sku))
        var result = shelf
        for item in remote where !seen.contains(item.sku) {
            seen.insert(item.sku)
            result.append(item)
        }
        return result
    }
}
