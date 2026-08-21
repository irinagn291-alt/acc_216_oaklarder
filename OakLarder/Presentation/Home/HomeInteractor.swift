import Foundation

@MainActor
final class HomeInteractor {
    private let larder: LarderSQLiteRepository
    private let prefs: PreferenceSQLiteRepository
    private let totals = DayTotalsUseCase()

    init(larder: LarderSQLiteRepository, prefs: PreferenceSQLiteRepository) {
        self.larder = larder
        self.prefs = prefs
    }

    func prepareCellar() async {
        await prefs.seedIfNeeded()
    }

    func needsOnboarding() async -> Bool {
        await prefs.didFinishOnboarding() == false
    }

    func loadToday() async -> HomeEntity {
        let dayKey = LarderDayStamp.key()
        let entries = (try? await larder.entries(dayKey: dayKey)) ?? []
        let eatenLog = entries.filter { $0.kind == .eaten }
        let pile = totals.pile(from: eatenLog, kind: .eaten)
        let bySlot = totals.pileBySlot(eatenLog, kind: .eaten)
        let slots = PantrySlotEntity.allCases.map { slot in
            HomeSlotBoardEntity(
                slot: slot,
                kcal: bySlot[slot]?.kcal ?? 0,
                titles: eatenLog.filter { $0.slot == slot }.map(\.title)
            )
        }
        return HomeEntity(
            dayKey: dayKey,
            spokenDay: LarderDayStamp.spokenDay(dayKey),
            goals: await prefs.goals(),
            eaten: pile,
            slots: slots,
            log: eatenLog
        )
    }

    func remove(id: String) async {
        try? await larder.delete(id: id)
    }
}
