import UIKit

@MainActor
final class PlanRouter {
    weak var host: UIViewController?
    private let factory: OakLarderFactory

    init(factory: OakLarderFactory) {
        self.factory = factory
    }

    func presentSearch() {
        guard let host else { return }
        OakSheet.present(host, factory.makeSearch())
    }
}
