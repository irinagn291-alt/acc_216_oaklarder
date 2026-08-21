import Foundation

@MainActor
protocol GoalsPresenterProtocol: AnyObject {
    func viewDidLoad()
    func save(kcal: Double, protein: Double, carbs: Double, fat: Double)
    func tapContact()
}

@MainActor
protocol GoalsViewProtocol: AnyObject {
    func render(_ entity: GoalsEntity)
}

@MainActor
final class GoalsPresenter: GoalsPresenterProtocol {
    private weak var view: GoalsViewProtocol?
    private let interactor: GoalsInteractor
    private let router: GoalsRouter

    init(view: GoalsViewProtocol, interactor: GoalsInteractor, router: GoalsRouter) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }

    func viewDidLoad() {
        Task { [weak self] in
            guard let self else { return }
            self.view?.render(await self.interactor.load())
        }
    }

    func save(kcal: Double, protein: Double, carbs: Double, fat: Double) {
        Task { [weak self] in
            await self?.interactor.save(LarderGoalEntity(kcal: kcal, protein: protein, carbs: carbs, fat: fat))
            self?.router.close()
        }
    }

    func tapContact() {
        router.openContact()
    }
}
