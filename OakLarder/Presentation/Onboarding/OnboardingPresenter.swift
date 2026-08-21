import Foundation

@MainActor
protocol OnboardingPresenterProtocol: AnyObject {
    func viewDidLoad()
    func advance()
}

@MainActor
protocol OnboardingViewProtocol: AnyObject {
    func render(_ entity: OnboardingEntity)
}

@MainActor
final class OnboardingPresenter: OnboardingPresenterProtocol {
    private weak var view: OnboardingViewProtocol?
    private let interactor: OnboardingInteractor
    private let router: OnboardingRouter
    private var index = 0

    init(view: OnboardingViewProtocol, interactor: OnboardingInteractor, router: OnboardingRouter) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }

    func viewDidLoad() {
        push()
    }

    func advance() {
        let pages = interactor.pages()
        if index + 1 >= pages.count {
            Task { [weak self] in
                await self?.interactor.finish()
                self?.router.close()
            }
        } else {
            index += 1
            push()
        }
    }

    private func push() {
        view?.render(OnboardingEntity(pages: interactor.pages(), index: index))
    }
}
