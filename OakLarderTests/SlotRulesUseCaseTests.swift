import XCTest
@testable import OakLarder

final class SlotRulesUseCaseTests: XCTestCase {
    func testNightCrumbStaysOffTheLedger() {
        // Given
        let useCase = SlotRulesUseCase()

        // When
        let planned = useCase.allowedSlots(for: .planned)
        let eaten = useCase.allowedSlots(for: .eaten)

        // Then
        XCTAssertFalse(planned.contains(.nightCrumb))
        XCTAssertEqual(planned.count, 3)
        XCTAssertTrue(eaten.contains(.nightCrumb))
        XCTAssertEqual(eaten.count, 4)
        XCTAssertFalse(useCase.accepts(.nightCrumb, kind: .planned))
        XCTAssertTrue(useCase.accepts(.nightCrumb, kind: .eaten))
    }
}
