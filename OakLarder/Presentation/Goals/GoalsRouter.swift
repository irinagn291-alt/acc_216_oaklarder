import SwiftUI
import UIKit

@MainActor
final class GoalsRouter {
    weak var host: UIViewController?

    func close() {
        host?.dismiss(animated: true)
    }

    func openContact() {
        host?.present(UIHostingController(rootView: CellarContactPane()), animated: true)
    }
}
