import XCTest
@testable import OakLarder

final class WishlistDedupUseCaseTests: XCTestCase {
    func testRejectsDuplicateSku() {
        // Given
        let useCase = WishlistDedupUseCase()
        let existing = [WishSkuEntity(sku: "oak-honey", title: "Honey", houseMark: nil, pinnedAt: 1)]
        let candidate = WishSkuEntity(sku: "oak-honey", title: "Honey again", houseMark: nil, pinnedAt: 2)

        // When
        let canPin = useCase.canPin(sku: candidate.sku, existing: existing)
        let merged = useCase.merging(candidate, into: existing)

        // Then
        XCTAssertFalse(canPin)
        XCTAssertEqual(merged.count, 1)
    }

    func testAcceptsFreshSku() {
        // Given
        let useCase = WishlistDedupUseCase()
        let existing = [WishSkuEntity(sku: "oak-honey", title: "Honey", houseMark: nil, pinnedAt: 1)]
        let candidate = WishSkuEntity(sku: "oak-rye", title: "Rye", houseMark: nil, pinnedAt: 2)

        // When
        let merged = useCase.merging(candidate, into: existing)

        // Then
        XCTAssertEqual(merged.map(\.sku), ["oak-honey", "oak-rye"])
    }
}
