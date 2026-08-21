import Foundation

@MainActor
final class GoalsInteractor {
    private let prefs: PreferenceSQLiteRepository

    init(prefs: PreferenceSQLiteRepository) {
        self.prefs = prefs
    }

    func load() async -> GoalsEntity {
        GoalsEntity(goals: await prefs.goals())
    }

    func save(_ goals: LarderGoalEntity) async {
        await prefs.saveGoals(goals)
    }
}
