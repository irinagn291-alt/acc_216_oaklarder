import Foundation

@MainActor
protocol AssignPresenterProtocol: AnyObject {
    func viewDidLoad()
    func setKind(_ kind: EntryKindEntity)
    func setDay(_ date: Date)
    func setSlot(_ slot: PantrySlotEntity)
    func confirm()
}

@MainActor
protocol AssignViewProtocol: AnyObject {
    func render(_ entity: AssignEntity)
}

@MainActor
final class AssignPresenter: AssignPresenterProtocol {
    private weak var view: AssignViewProtocol?
    private let interactor: AssignInteractor
    private let router: AssignRouter
    private let goods: LarderGoodsEntity
    private let grams: Double
    private var kind: EntryKindEntity = .eaten
    private var dayKey = LarderDayStamp.key()
    private var slot: PantrySlotEntity = .morningLoaf

    init(
        view: AssignViewProtocol,
        interactor: AssignInteractor,
        router: AssignRouter,
        goods: LarderGoodsEntity,
        grams: Double
    ) {
        self.view = view
        self.interactor = interactor
        self.router = router
        self.goods = goods
        self.grams = grams
    }

    func viewDidLoad() {
        push()
    }

    func setKind(_ kind: EntryKindEntity) {
        self.kind = kind
        let allowed = interactor.allowed(for: kind)
        if !allowed.contains(slot), let first = allowed.first {
            slot = first
        }
        if kind == .eaten {
            dayKey = LarderDayStamp.key()
        }
        push()
    }

    func setDay(_ date: Date) {
        dayKey = LarderDayStamp.key(date)
        push()
    }

    func setSlot(_ slot: PantrySlotEntity) {
        guard interactor.allowed(for: kind).contains(slot) else { return }
        self.slot = slot
        push()
    }

    func confirm() {
        Task { [weak self] in
            guard let self else { return }
            let ok = await self.interactor.commit(
                goods: self.goods,
                grams: self.grams,
                slot: self.slot,
                dayKey: self.dayKey,
                kind: self.kind
            )
            if ok {
                self.router.finish(kind: self.kind)
            }
        }
    }

    private func push() {
        view?.render(
            AssignEntity(
                goods: goods,
                grams: grams,
                kind: kind,
                dayKey: dayKey,
                slot: slot,
                allowedSlots: interactor.allowed(for: kind),
                serving: interactor.serving(goods, grams: grams)
            )
        )
    }
}
