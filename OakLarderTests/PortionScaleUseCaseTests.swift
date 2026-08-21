import XCTest
@testable import OakLarder

final class PortionScaleUseCaseTests: XCTestCase {
    func testScalesMacrosFromHundredGrams() {
        // Given
        let useCase = PortionScaleUseCase()
        let goods = CellarShelfStock.tins[0]
        let grams = 50.0

        // When
        let serving = useCase.weigh(goods, grams: grams)

        // Then
        XCTAssertEqual(serving.grams, 50, accuracy: 0.001)
        XCTAssertEqual(serving.kcal, goods.kcalPerHundred * 0.5, accuracy: 0.001)
        XCTAssertEqual(serving.protein, goods.proteinPerHundred * 0.5, accuracy: 0.001)
        XCTAssertEqual(serving.carbs, goods.carbsPerHundred * 0.5, accuracy: 0.001)
        XCTAssertEqual(serving.fat, goods.fatPerHundred * 0.5, accuracy: 0.001)
    }

    func testConvertsKilojoulesWhenKcalMissing() {
        // Given
        let useCase = PortionScaleUseCase()
        let kilojoules = 418.4

        // When
        let kcal = useCase.kcalFromKilojoules(kilojoules)

        // Then
        XCTAssertEqual(kcal, 100, accuracy: 0.01)
    }
}
