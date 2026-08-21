import Foundation

protocol LarderRepositoryProtocol: Sendable {
    func entries(dayKey: String) async throws -> [LarderEntryEntity]
    func planned(monthPrefix: String) async throws -> [LarderEntryEntity]
    func insert(_ entry: LarderEntryEntity) async throws
    func delete(id: String) async throws
}

protocol CatalogRepositoryProtocol: Sendable {
    func shelfGoods() async -> [LarderGoodsEntity]
    func search(_ query: String) async -> CatalogHitEntity
    func lookup(code: String) async -> CatalogHitEntity
}

struct CatalogHitEntity: Sendable, Equatable {
    let goods: [LarderGoodsEntity]
    let fromCellarCache: Bool
}

protocol PreferenceRepositoryProtocol: Sendable {
    func goals() async -> LarderGoalEntity
    func saveGoals(_ goals: LarderGoalEntity) async
    func wishes() async -> [WishSkuEntity]
    func pinWish(_ item: WishSkuEntity) async -> Bool
    func unpinWish(sku: String) async
    func didFinishOnboarding() async -> Bool
    func markOnboardingFinished() async
    func seedIfNeeded() async
}
