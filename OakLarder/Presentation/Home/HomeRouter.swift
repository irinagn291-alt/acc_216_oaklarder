import UIKit

@MainActor
final class HomeRouter {
    weak var host: UIViewController?
    private let factory: OakLarderFactory

    init(factory: OakLarderFactory) {
        self.factory = factory
    }

    func presentSearch() {
        guard let host else { return }
        OakSheet.present(host, factory.makeSearch())
    }

    func presentScan() {
        guard let host else { return }
        OakSheet.present(host, factory.makeScan())
    }

    func presentPlan() {
        guard let host else { return }
        OakSheet.present(host, factory.makePlan())
    }

    func presentWish() {
        guard let host else { return }
        OakSheet.present(host, factory.makeWish())
    }

    func presentGoals() {
        guard let host else { return }
        OakSheet.present(host, factory.makeGoals())
    }

    func presentOnboarding() {
        guard let host else { return }
        let onboard = factory.makeOnboarding()
        onboard.modalPresentationStyle = .fullScreen
        host.present(onboard, animated: true)
    }
}
