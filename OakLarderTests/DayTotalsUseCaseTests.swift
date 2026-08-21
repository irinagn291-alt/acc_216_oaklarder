import XCTest
@testable import OakLarder

final class DayTotalsUseCaseTests: XCTestCase {
    func testSumsOnlyEatenEntries() {
        // Given
        let useCase = DayTotalsUseCase()
        let eaten = LarderEntryEntity(
            id: "1", sku: "a", title: "A", grams: 100, kcal: 200, protein: 10, carbs: 20, fat: 5,
            slot: .morningLoaf, dayKey: "2026-08-19", kind: .eaten
        )
        let planned = LarderEntryEntity(
            id: "2", sku: "b", title: "B", grams: 100, kcal: 400, protein: 20, carbs: 40, fat: 10,
            slot: .noonBoard, dayKey: "2026-08-19", kind: .planned
        )

        // When
        let pile = useCase.pile(from: [eaten, planned], kind: .eaten)

        // Then
        XCTAssertEqual(pile.kcal, 200, accuracy: 0.001)
        XCTAssertEqual(pile.protein, 10, accuracy: 0.001)
    }

    func testGroupsBySlot() {
        // Given
        let useCase = DayTotalsUseCase()
        let first = LarderEntryEntity(
            id: "1", sku: "a", title: "A", grams: 80, kcal: 100, protein: 4, carbs: 16, fat: 2,
            slot: .morningLoaf, dayKey: "2026-08-19", kind: .eaten
        )
        let second = LarderEntryEntity(
            id: "2", sku: "b", title: "B", grams: 40, kcal: 50, protein: 2, carbs: 8, fat: 1,
            slot: .morningLoaf, dayKey: "2026-08-19", kind: .eaten
        )

        // When
        let map = useCase.pileBySlot([first, second], kind: .eaten)

        // Then
        XCTAssertEqual(map[.morningLoaf]!.kcal, 150, accuracy: 0.001)
    }
}
