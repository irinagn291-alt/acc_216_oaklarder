import Foundation

@MainActor
protocol HomePresenterProtocol: AnyObject {
    func viewDidAppear()
    func tapSearch()
    func tapScan()
    func tapPlan()
    func tapWish()
    func tapGoals()
    func deleteEntry(id: String)
}

@MainActor
protocol HomeViewProtocol: AnyObject {
    func render(_ entity: HomeEntity)
}

@MainActor
final class HomePresenter: HomePresenterProtocol {
    private weak var view: HomeViewProtocol?
    private let interactor: HomeInteractor
    private let router: HomeRouter
    private var didOfferOnboarding = false

    init(view: HomeViewProtocol, interactor: HomeInteractor, router: HomeRouter) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }

    func viewDidAppear() {
        Task { [weak self] in
            guard let self else { return }
            await self.interactor.prepareCellar()
            if !self.didOfferOnboarding, await self.interactor.needsOnboarding() {
                self.didOfferOnboarding = true
                self.router.presentOnboarding()
            }
            let board = await self.interactor.loadToday()
            self.view?.render(board)
        }
    }

    func tapSearch() { router.presentSearch() }
    func tapScan() { router.presentScan() }
    func tapPlan() { router.presentPlan() }
    func tapWish() { router.presentWish() }
    func tapGoals() { router.presentGoals() }

    func deleteEntry(id: String) {
        Task { [weak self] in
            await self?.interactor.remove(id: id)
            if let board = await self?.interactor.loadToday() {
                self?.view?.render(board)
            }
        }
    }
}
