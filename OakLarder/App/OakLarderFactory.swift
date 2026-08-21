import UIKit

@MainActor
final class OakLarderFactory {
    static let shared = OakLarderFactory()

    let sql: OakSQLStore
    let larder: LarderSQLiteRepository
    let catalog: CatalogCachedRepository
    let prefs: PreferenceSQLiteRepository
    private let cache: OffDiskCache
    private let client: OffCatalogClient

    weak var larderRoot: UIViewController?

    private init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dbURL = docs.appendingPathComponent("oak_larder.sqlite")
        sql = try! OakSQLStore(fileURL: dbURL)
        larder = LarderSQLiteRepository(sql: sql)
        cache = OffDiskCache(folder: docs.appendingPathComponent("OffCache", isDirectory: true))
        client = OffCatalogClient()
        catalog = CatalogCachedRepository(client: client, cache: cache)
        prefs = PreferenceSQLiteRepository(sql: sql, larder: larder)
    }

    func makeHome() -> UIViewController {
        let view = HomeViewController()
        let interactor = HomeInteractor(larder: larder, prefs: prefs)
        let router = HomeRouter(factory: self)
        let presenter = HomePresenter(view: view, interactor: interactor, router: router)
        view.presenter = presenter
        router.host = view
        larderRoot = view
        return view
    }

    func makeSearch() -> UIViewController {
        let view = SearchViewController()
        let interactor = SearchInteractor(catalog: catalog)
        let router = SearchRouter(factory: self)
        let presenter = SearchPresenter(view: view, interactor: interactor, router: router)
        view.presenter = presenter
        router.host = view
        return view
    }

    func makeScan() -> UIViewController {
        let view = ScanViewController()
        let interactor = ScanInteractor(catalog: catalog)
        let router = ScanRouter(factory: self)
        let presenter = ScanPresenter(view: view, interactor: interactor, router: router)
        view.presenter = presenter
        router.host = view
        return view
    }

    func makeDetail(goods: LarderGoodsEntity) -> UIViewController {
        let view = DetailViewController()
        let interactor = DetailInteractor(prefs: prefs)
        let router = DetailRouter(factory: self)
        let presenter = DetailPresenter(view: view, interactor: interactor, router: router, goods: goods)
        view.presenter = presenter
        router.host = view
        return view
    }

    func makeAssign(goods: LarderGoodsEntity, grams: Double) -> UIViewController {
        let view = AssignViewController()
        let interactor = AssignInteractor(larder: larder)
        let router = AssignRouter(factory: self)
        let presenter = AssignPresenter(view: view, interactor: interactor, router: router, goods: goods, grams: grams)
        view.presenter = presenter
        router.host = view
        return view
    }

    func makePlan() -> UIViewController {
        let view = PlanViewController()
        let interactor = PlanInteractor(larder: larder)
        let router = PlanRouter(factory: self)
        let presenter = PlanPresenter(view: view, interactor: interactor, router: router)
        view.presenter = presenter
        router.host = view
        return view
    }

    func makeWish() -> UIViewController {
        let view = WishViewController()
        let interactor = WishInteractor(prefs: prefs, catalog: catalog)
        let router = WishRouter(factory: self)
        let presenter = WishPresenter(view: view, interactor: interactor, router: router)
        view.presenter = presenter
        router.host = view
        return view
    }

    func makeGoals() -> UIViewController {
        let view = GoalsViewController()
        let interactor = GoalsInteractor(prefs: prefs)
        let router = GoalsRouter()
        let presenter = GoalsPresenter(view: view, interactor: interactor, router: router)
        view.presenter = presenter
        router.host = view
        return view
    }

    func makeOnboarding() -> UIViewController {
        let view = OnboardingViewController()
        let interactor = OnboardingInteractor(prefs: prefs)
        let router = OnboardingRouter()
        let presenter = OnboardingPresenter(view: view, interactor: interactor, router: router)
        view.presenter = presenter
        router.host = view
        return view
    }

    func dismissToLarder(thenPlan: Bool) {
        larderRoot?.dismiss(animated: true) { [weak self] in
            if thenPlan, let root = self?.larderRoot, let plan = self?.makePlan() {
                OakSheet.present(root, plan)
            }
        }
    }
}
