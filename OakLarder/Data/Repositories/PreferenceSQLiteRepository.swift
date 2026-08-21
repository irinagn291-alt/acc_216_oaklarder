import Foundation

actor PreferenceSQLiteRepository: PreferenceRepositoryProtocol {
    private let sql: OakSQLStore
    private let larder: LarderSQLiteRepository
    private let dedup = WishlistDedupUseCase()
    private let scale = PortionScaleUseCase()

    init(sql: OakSQLStore, larder: LarderSQLiteRepository) {
        self.sql = sql
        self.larder = larder
    }

    func goals() async -> LarderGoalEntity {
        let rows = try? sql.query("SELECT * FROM larder_goals WHERE id = 1;")
        guard let row = rows?.first else { return .cellarDefault }
        return LarderGoalEntity(
            kcal: row.real("kcal"),
            protein: row.real("protein"),
            carbs: row.real("carbs"),
            fat: row.real("fat")
        )
    }

    func saveGoals(_ goals: LarderGoalEntity) async {
        try? sql.write(
            """
            INSERT INTO larder_goals (id, kcal, protein, carbs, fat) VALUES (1, ?, ?, ?, ?)
            ON CONFLICT(id) DO UPDATE SET kcal = excluded.kcal, protein = excluded.protein, carbs = excluded.carbs, fat = excluded.fat;
            """,
            binds: [.real(goals.kcal), .real(goals.protein), .real(goals.carbs), .real(goals.fat)]
        )
    }

    func wishes() async -> [WishSkuEntity] {
        let rows = (try? sql.query("SELECT * FROM wish_skus ORDER BY pinned_at DESC;")) ?? []
        return rows.map {
            WishSkuEntity(
                sku: $0.text("sku"),
                title: $0.text("title"),
                houseMark: $0.text("house_mark").isEmpty ? nil : $0.text("house_mark"),
                pinnedAt: $0.real("pinned_at")
            )
        }
    }

    func pinWish(_ item: WishSkuEntity) async -> Bool {
        let existing = await wishes()
        guard dedup.canPin(sku: item.sku, existing: existing) else { return false }
        try? sql.write(
            "INSERT INTO wish_skus (sku, title, house_mark, pinned_at) VALUES (?, ?, ?, ?);",
            binds: [
                .text(item.sku),
                .text(item.title),
                item.houseMark.map { .text($0) } ?? .null,
                .real(item.pinnedAt)
            ]
        )
        return true
    }

    func unpinWish(sku: String) async {
        try? sql.write("DELETE FROM wish_skus WHERE sku = ?;", binds: [.text(sku)])
    }

    func didFinishOnboarding() async -> Bool {
        pref("oak.onboarded") == "1"
    }

    func markOnboardingFinished() async {
        setPref("oak.onboarded", "1")
    }

    func seedIfNeeded() async {
        let today = LarderDayStamp.key()
        #if targetEnvironment(simulator)
        let existing = (try? await larder.entries(dayKey: today)) ?? []
        if pref("oak.seeded") == "1" && existing.filter({ $0.kind == .eaten }).isEmpty {
            setPref("oak.seeded", "0")
        }
        #endif
        guard pref("oak.seeded") != "1" else { return }
        await saveGoals(.cellarDefault)
        let oats = CellarShelfStock.tins[0]
        let salmon = CellarShelfStock.tins[5]
        let rye = CellarShelfStock.tins[1]
        let beans = CellarShelfStock.tins[4]
        let sardines = CellarShelfStock.tins[7]
        let honey = CellarShelfStock.tins[3]
        try? await larder.insert(entry(id: UUID().uuidString, goods: oats, grams: 80, slot: .morningLoaf, dayKey: today, kind: .eaten))
        try? await larder.insert(entry(id: UUID().uuidString, goods: salmon, grams: 140, slot: .noonBoard, dayKey: today, kind: .eaten))
        try? await larder.insert(entry(id: UUID().uuidString, goods: honey, grams: 20, slot: .nightCrumb, dayKey: today, kind: .eaten))
        let tomorrow = LarderDayStamp.key(Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date())
        try? await larder.insert(entry(id: UUID().uuidString, goods: rye, grams: 70, slot: .morningLoaf, dayKey: tomorrow, kind: .planned))
        try? await larder.insert(entry(id: UUID().uuidString, goods: beans, grams: 180, slot: .duskRoast, dayKey: tomorrow, kind: .planned))
        _ = await pinWish(WishSkuEntity(sku: sardines.sku, title: sardines.title, houseMark: sardines.houseMark, pinnedAt: Date().timeIntervalSince1970))
        setPref("oak.seeded", "1")
    }

    private func entry(id: String, goods: LarderGoodsEntity, grams: Double, slot: PantrySlotEntity, dayKey: String, kind: EntryKindEntity) -> LarderEntryEntity {
        let serving = scale.weigh(goods, grams: grams)
        return LarderEntryEntity(
            id: id,
            sku: goods.sku,
            title: goods.title,
            grams: serving.grams,
            kcal: serving.kcal,
            protein: serving.protein,
            carbs: serving.carbs,
            fat: serving.fat,
            slot: slot,
            dayKey: dayKey,
            kind: kind
        )
    }

    private func pref(_ key: String) -> String? {
        let rows = try? sql.query("SELECT value FROM cellar_prefs WHERE key = ?;", binds: [.text(key)])
        let value = rows?.first?.text("value")
        return value?.isEmpty == false ? value : nil
    }

    private func setPref(_ key: String, _ value: String) {
        try? sql.write(
            """
            INSERT INTO cellar_prefs (key, value) VALUES (?, ?)
            ON CONFLICT(key) DO UPDATE SET value = excluded.value;
            """,
            binds: [.text(key), .text(value)]
        )
    }
}
