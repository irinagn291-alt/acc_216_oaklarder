import Foundation

@MainActor
protocol ScanPresenterProtocol: AnyObject {
    func didReadStamp(_ raw: String)
    func lookupManual(_ raw: String)
}

@MainActor
protocol ScanViewProtocol: AnyObject {
    func render(_ entity: ScanEntity)
}

@MainActor
final class ScanPresenter: ScanPresenterProtocol {
    private weak var view: ScanViewProtocol?
    private let interactor: ScanInteractor
    private let router: ScanRouter
    private var lastCode: String?

    init(view: ScanViewProtocol, interactor: ScanInteractor, router: ScanRouter) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }

    func didReadStamp(_ raw: String) {
        lookupManual(raw)
    }

    func lookupManual(_ raw: String) {
        guard let code = interactor.normalize(raw) else {
            view?.render(ScanEntity(rawStamp: raw, normalized: nil, message: "Need 8–14 digits on the crate"))
            return
        }
        guard code != lastCode else { return }
        lastCode = code
        view?.render(ScanEntity(rawStamp: raw, normalized: code, message: "Looking up \(code)…"))
        Task { [weak self] in
            guard let self else { return }
            let hit = await self.interactor.lookup(code: code)
            if let goods = hit.goods.first {
                self.router.presentDetail(goods)
            } else {
                self.lastCode = nil
                self.view?.render(ScanEntity(rawStamp: raw, normalized: code, message: "No tin in the cellar for \(code)"))
            }
        }
    }
}
