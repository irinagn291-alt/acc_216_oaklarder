import Foundation

actor LarderSQLiteRepository: LarderRepositoryProtocol {
    private let sql: OakSQLStore

    init(sql: OakSQLStore) {
        self.sql = sql
    }

    func entries(dayKey: String) async throws -> [LarderEntryEntity] {
        let rows = try sql.query(
            "SELECT * FROM larder_entries WHERE day_key = ? ORDER BY rowid DESC;",
            binds: [.text(dayKey)]
        )
        return rows.compactMap(entry(from:))
    }

    func planned(monthPrefix: String) async throws -> [LarderEntryEntity] {
        let rows = try sql.query(
            "SELECT * FROM larder_entries WHERE kind = 'planned' AND day_key LIKE ? ORDER BY day_key, slot;",
            binds: [.text("\(monthPrefix)%")]
        )
        return rows.compactMap(entry(from:))
    }

    func insert(_ entry: LarderEntryEntity) async throws {
        try sql.write(
            """
            INSERT INTO larder_entries (id, sku, title, grams, kcal, protein, carbs, fat, slot, day_key, kind)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
            """,
            binds: [
                .text(entry.id),
                .text(entry.sku),
                .text(entry.title),
                .real(entry.grams),
                .real(entry.kcal),
                .real(entry.protein),
                .real(entry.carbs),
                .real(entry.fat),
                .text(entry.slot.rawValue),
                .text(entry.dayKey),
                .text(entry.kind.rawValue)
            ]
        )
    }

    func delete(id: String) async throws {
        try sql.write("DELETE FROM larder_entries WHERE id = ?;", binds: [.text(id)])
    }

    private func entry(from row: OakSQLRow) -> LarderEntryEntity? {
        guard let slot = PantrySlotEntity(rawValue: row.text("slot")),
              let kind = EntryKindEntity(rawValue: row.text("kind"))
        else { return nil }
        return LarderEntryEntity(
            id: row.text("id"),
            sku: row.text("sku"),
            title: row.text("title"),
            grams: row.real("grams"),
            kcal: row.real("kcal"),
            protein: row.real("protein"),
            carbs: row.real("carbs"),
            fat: row.real("fat"),
            slot: slot,
            dayKey: row.text("day_key"),
            kind: kind
        )
    }
}
