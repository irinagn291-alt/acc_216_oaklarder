import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate, LarderSurfaceFactory {
    var window: UIWindow?
    private let director = LarderBootDirector()

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        director.begin(on: window, factory: self)
    }

    func makePantryBoard() -> UIViewController {
        OakLarderFactory.shared.makeHome()
    }
}
