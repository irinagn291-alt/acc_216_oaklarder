import Foundation

@MainActor
protocol SearchPresenterProtocol: AnyObject {
    func viewDidLoad()
    func queryChanged(_ text: String)
    func pick(_ goods: LarderGoodsEntity)
}

@MainActor
protocol SearchViewProtocol: AnyObject {
    func render(_ entity: SearchEntity)
}

@MainActor
final class SearchPresenter: SearchPresenterProtocol {
    private weak var view: SearchViewProtocol?
    private let interactor: SearchInteractor
    private let router: SearchRouter
    private var token = UUID()

    init(view: SearchViewProtocol, interactor: SearchInteractor, router: SearchRouter) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }

    func viewDidLoad() {
        queryChanged("")
    }

    func queryChanged(_ text: String) {
        let stamp = UUID()
        token = stamp
        Task { [weak self] in
            guard let self else { return }
            let entity = await self.interactor.lookup(text)
            guard self.token == stamp else { return }
            self.view?.render(entity)
        }
    }

    func pick(_ goods: LarderGoodsEntity) {
        router.presentDetail(goods)
    }
}
