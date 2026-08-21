import Foundation

@MainActor
final class PlanInteractor {
    private let larder: LarderSQLiteRepository

    init(larder: LarderSQLiteRepository) {
        self.larder = larder
    }

    func load(cursor: Date, selectedKey: String) async -> PlanEntity {
        let prefix = LarderDayStamp.monthPrefix(cursor)
        let planned = (try? await larder.planned(monthPrefix: prefix)) ?? []
        let days = planned.reduce(into: Set<String>()) { $0.insert($1.dayKey) }
        let calendar = Calendar.current
        let start = calendar.date(from: calendar.dateComponents([.year, .month], from: cursor)) ?? cursor
        let count = calendar.range(of: .day, in: .month, for: start)?.count ?? 30
        var marks: [PlanDayMarkEntity] = []
        for day in 1...count {
            var parts = calendar.dateComponents([.year, .month], from: start)
            parts.day = day
            if let date = calendar.date(from: parts) {
                let key = LarderDayStamp.key(date)
                marks.append(PlanDayMarkEntity(dayKey: key, hasPlanned: days.contains(key)))
            }
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return PlanEntity(
            monthTitle: formatter.string(from: cursor),
            monthPrefix: prefix,
            cursor: cursor,
            marks: marks,
            selectedKey: selectedKey,
            selectedEntries: planned.filter { $0.dayKey == selectedKey }
        )
    }

    func remove(id: String) async {
        try? await larder.delete(id: id)
    }
}
