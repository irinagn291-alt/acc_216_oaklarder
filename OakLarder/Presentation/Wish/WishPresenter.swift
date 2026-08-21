import Foundation

@MainActor
protocol WishPresenterProtocol: AnyObject {
    func viewDidAppear()
    func open(_ item: WishSkuEntity)
    func unpin(sku: String)
}

@MainActor
protocol WishViewProtocol: AnyObject {
    func render(_ entity: WishEntity)
}

@MainActor
final class WishPresenter: WishPresenterProtocol {
    private weak var view: WishViewProtocol?
    private let interactor: WishInteractor
    private let router: WishRouter

    init(view: WishViewProtocol, interactor: WishInteractor, router: WishRouter) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }

    func viewDidAppear() {
        Task { [weak self] in
            guard let self else { return }
            self.view?.render(await self.interactor.load())
        }
    }

    func open(_ item: WishSkuEntity) {
        Task { [weak self] in
            guard let self else { return }
            let goods = await self.interactor.goods(for: item)
            self.router.presentDetail(goods)
        }
    }

    func unpin(sku: String) {
        Task { [weak self] in
            await self?.interactor.unpin(sku: sku)
            if let entity = await self?.interactor.load() {
                self?.view?.render(entity)
            }
        }
    }
}
