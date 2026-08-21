import Foundation

@MainActor
protocol PlanPresenterProtocol: AnyObject {
    func viewDidAppear()
    func shiftMonth(_ delta: Int)
    func select(dayKey: String)
    func addTin()
    func deleteEntry(id: String)
}

@MainActor
protocol PlanViewProtocol: AnyObject {
    func render(_ entity: PlanEntity)
}

@MainActor
final class PlanPresenter: PlanPresenterProtocol {
    private weak var view: PlanViewProtocol?
    private let interactor: PlanInteractor
    private let router: PlanRouter
    private var cursor = Date()
    private var selectedKey = LarderDayStamp.key()

    init(view: PlanViewProtocol, interactor: PlanInteractor, router: PlanRouter) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }

    func viewDidAppear() {
        refresh()
    }

    func shiftMonth(_ delta: Int) {
        if let next = Calendar.current.date(byAdding: .month, value: delta, to: cursor) {
            cursor = next
            selectedKey = LarderDayStamp.key(Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: next)) ?? next)
            refresh()
        }
    }

    func select(dayKey: String) {
        selectedKey = dayKey
        refresh()
    }

    func addTin() {
        router.presentSearch()
    }

    func deleteEntry(id: String) {
        Task { [weak self] in
            await self?.interactor.remove(id: id)
            self?.refresh()
        }
    }

    private func refresh() {
        Task { [weak self] in
            guard let self else { return }
            let entity = await self.interactor.load(cursor: self.cursor, selectedKey: self.selectedKey)
            self.view?.render(entity)
        }
    }
}
