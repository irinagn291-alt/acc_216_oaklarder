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
        for context in connectionOptions.urlContexts {
            AppsFlyerBootstrap.handleOpen(url: context.url)
        }
        if let activity = connectionOptions.userActivities.first {
            continueActivity(activity)
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        URLContexts.forEach { AppsFlyerBootstrap.handleOpen(url: $0.url) }
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        continueActivity(userActivity)
    }

    func makePantryBoard() -> UIViewController {
        OakLarderFactory.shared.makeHome()
    }

    private func continueActivity(_ userActivity: NSUserActivity) {
        if let url = userActivity.webpageURL {
            AppsFlyerBootstrap.handleOpen(url: url)
        } else {
            AppsFlyerBootstrap.continueUserActivity(userActivity)
        }
    }
}
