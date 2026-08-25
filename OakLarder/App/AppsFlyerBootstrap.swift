import AppTrackingTransparency
import AppsFlyerLib
import UIKit

@MainActor
enum AppsFlyerBootstrap {
    private static let appleAppID = "6803449552"
    private static let devKey = "97ULG8ocGhDXP7QMERZzAZ"
    private static var didStart = false

    static func configure(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        let appsFlyer = AppsFlyerLib.shared()
        appsFlyer.appsFlyerDevKey = devKey
        appsFlyer.appleAppID = appleAppID
        appsFlyer.waitForATTUserAuthorization(timeoutInterval: 60)
        if let url = launchOptions?[.url] as? URL {
            appsFlyer.handleOpen(url, options: nil)
        }
    }

    static func requestTrackingAndStart() async {
        await waitUntilActive()
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            ATTrackingManager.requestTrackingAuthorization { _ in
                continuation.resume()
            }
        }
        startOnce()
    }

    static func handleOpen(url: URL) {
        AppsFlyerLib.shared().handleOpen(url, options: nil)
    }

    static func continueUserActivity(_ userActivity: NSUserActivity) {
        AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
    }

    private static func startOnce() {
        guard didStart == false else { return }
        didStart = true
        AppsFlyerLib.shared().start()
    }

    private static func waitUntilActive() async {
        if UIApplication.shared.applicationState == .active { return }
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            let gate = ResumeOnce()
            var token: NSObjectProtocol?
            token = NotificationCenter.default.addObserver(
                forName: UIApplication.didBecomeActiveNotification,
                object: nil,
                queue: .main
            ) { _ in
                if let token {
                    NotificationCenter.default.removeObserver(token)
                }
                gate.resume(continuation)
            }
            if UIApplication.shared.applicationState == .active {
                if let token {
                    NotificationCenter.default.removeObserver(token)
                }
                gate.resume(continuation)
            }
        }
    }
}

private final class ResumeOnce: @unchecked Sendable {
    private let lock = NSLock()
    private var resumed = false

    func resume(_ continuation: CheckedContinuation<Void, Never>) {
        lock.lock()
        defer { lock.unlock() }
        guard resumed == false else { return }
        resumed = true
        continuation.resume()
    }
}
