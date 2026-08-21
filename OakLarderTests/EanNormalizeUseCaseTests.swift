import XCTest
@testable import OakLarder

final class EanNormalizeUseCaseTests: XCTestCase {
    func testExtractsDigitsFromProductURL() {
        // Given
        let useCase = EanNormalizeUseCase()
        let raw = "https://world.openfoodfacts.org/product/3017620422003/hazelnut-spread"

        // When
        let code = useCase.normalize(raw)

        // Then
        XCTAssertEqual(code, "3017620422003")
    }

    func testPrefixesZeroOnUpcTwelve() {
        // Given
        let useCase = EanNormalizeUseCase()
        let raw = "012345678901"

        // When
        let code = useCase.normalize(raw)

        // Then
        XCTAssertEqual(code, "0012345678901")
    }

    func testRejectsShortStamp() {
        // Given
        let useCase = EanNormalizeUseCase()

        // When
        let code = useCase.normalize("1234567")

        // Then
        XCTAssertNil(code)
    }
}
