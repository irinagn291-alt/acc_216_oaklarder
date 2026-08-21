import Foundation

@MainActor
protocol DetailPresenterProtocol: AnyObject {
    func viewDidLoad()
    func setGrams(_ grams: Double)
    func continueAssign()
    func pinWish()
}

@MainActor
protocol DetailViewProtocol: AnyObject {
    func render(_ entity: DetailEntity)
}

@MainActor
final class DetailPresenter: DetailPresenterProtocol {
    private weak var view: DetailViewProtocol?
    private let interactor: DetailInteractor
    private let router: DetailRouter
    private var goods: LarderGoodsEntity
    private var grams: Double = 100
    private var wishPinned = false

    init(view: DetailViewProtocol, interactor: DetailInteractor, router: DetailRouter, goods: LarderGoodsEntity) {
        self.view = view
        self.interactor = interactor
        self.router = router
        self.goods = goods
    }

    func viewDidLoad() {
        push()
    }

    func setGrams(_ grams: Double) {
        self.grams = max(1, grams)
        push()
    }

    func continueAssign() {
        router.presentAssign(goods: goods, grams: grams)
    }

    func pinWish() {
        Task { [weak self] in
            guard let self else { return }
            self.wishPinned = await self.interactor.pin(self.goods)
            self.push()
        }
    }

    private func push() {
        view?.render(
            DetailEntity(
                goods: goods,
                grams: grams,
                serving: interactor.weigh(goods, grams: grams),
                wishPinned: wishPinned
            )
        )
    }
}
