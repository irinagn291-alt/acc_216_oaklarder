import UIKit

@MainActor
final class DetailRouter {
    weak var host: UIViewController?
    private let factory: OakLarderFactory

    init(factory: OakLarderFactory) {
        self.factory = factory
    }

    func presentAssign(goods: LarderGoodsEntity, grams: Double) {
        guard let host else { return }
        OakSheet.present(host, factory.makeAssign(goods: goods, grams: grams))
    }
}
