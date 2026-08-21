import UIKit

@MainActor
final class OnboardingRouter {
    weak var host: UIViewController?

    func close() {
        host?.dismiss(animated: true)
    }
}
