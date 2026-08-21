import UIKit

@MainActor
final class SearchRouter {
    weak var host: UIViewController?
    private let factory: OakLarderFactory

    init(factory: OakLarderFactory) {
        self.factory = factory
    }

    func presentDetail(_ goods: LarderGoodsEntity) {
        guard let host else { return }
        OakSheet.present(host, factory.makeDetail(goods: goods))
    }
}
