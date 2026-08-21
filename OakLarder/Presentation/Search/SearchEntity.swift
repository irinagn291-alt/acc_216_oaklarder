import Foundation

struct SearchEntity: Sendable, Equatable {
    var query: String
    var goods: [LarderGoodsEntity]
    var fromCellarCache: Bool
}
