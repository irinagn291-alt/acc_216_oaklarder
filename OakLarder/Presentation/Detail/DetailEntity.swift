import Foundation

struct DetailEntity: Sendable, Equatable {
    var goods: LarderGoodsEntity
    var grams: Double
    var serving: ServingMathEntity
    var wishPinned: Bool
}
