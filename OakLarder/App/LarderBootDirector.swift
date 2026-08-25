import SwiftUI
import UIKit
@preconcurrency import Alamofire

enum LarderDecision {
    case page(String)
    case board

    static func from(_ mode: Alamofire.DisplayMode, _ url: String?) -> LarderDecision {
        guard mode == .webContent, let url, url.isEmpty == false else { return .board }
        return .page(url)
    }

    static func resolved(_ raw: String) -> String {
        switch true {
        case raw.hasPrefix("https://"), raw.hasPrefix("http://"):
            return raw
        default:
            return "https://\(raw)"
        }
    }
}

@MainActor
final class LarderBootDirector {
    private var latched = false
    private var timer: Timer?
    private weak var window: UIWindow?
    private weak var factory: LarderSurfaceFactory?

    func begin(on window: UIWindow, factory: LarderSurfaceFactory) {
        self.window = window
        self.factory = factory
        window.backgroundColor = OakPalette.parchment
        window.rootViewController = LarderHoldController()
        window.makeKeyAndVisible()
        Task { await armGate() }
    }

    private func armGate() async {
        await AppsFlyerBootstrap.requestTrackingAndStart()
        guard latched == false else { return }

        if let kept = Alamofire.DataCache.shared.contentURL, kept.isEmpty == false {
            commit(.page(kept))
        }

        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { [weak self] _ in
            DispatchQueue.main.async { self?.commit(.board) }
        }

        Alamofire.NetworkService.shared.performRegistration(pushToken: "") { [weak self] mode, url in
            DispatchQueue.main.async { self?.commit(.from(mode, url)) }
        }
    }

    private func commit(_ decision: LarderDecision) {
        guard latched == false, let window else { return }
        latched = true
        timer?.invalidate()
        timer = nil

        switch decision {
        case .page(let raw):
            window.rootViewController = LarderWebHost(href: LarderDecision.resolved(raw))
        case .board:
            window.rootViewController = factory?.makePantryBoard()
        }
        window.makeKeyAndVisible()
    }
}

private final class LarderHoldController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = OakPalette.parchment
        let spin = UIActivityIndicatorView(style: .large)
        spin.color = OakPalette.oakMid
        spin.translatesAutoresizingMaskIntoConstraints = false
        spin.startAnimating()
        view.addSubview(spin)
        NSLayoutConstraint.activate([
            spin.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spin.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}

private final class LarderWebHost: UIViewController {
    private let href: String

    init(href: String) {
        self.href = href
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        let hosted = UIHostingController(
            rootView: ZStack {
                Color.black.ignoresSafeArea()
                Alamofire.WebContentView(url: href)
            }
            .preferredColorScheme(.dark)
        )
        addChild(hosted)
        hosted.view.frame = view.bounds
        hosted.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(hosted.view)
        hosted.didMove(toParent: self)
    }
}
