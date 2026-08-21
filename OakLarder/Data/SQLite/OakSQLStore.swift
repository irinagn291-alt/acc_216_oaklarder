import Foundation
import SQLite3

enum OakSQLValue: Sendable, Equatable {
    case null
    case text(String)
    case real(Double)
    case integer(Int64)
}

struct OakSQLRow: Sendable {
    let cells: [String: OakSQLValue]

    func text(_ key: String) -> String {
        switch cells[key] {
        case .text(let value): value
        default: ""
        }
    }

    func real(_ key: String) -> Double {
        switch cells[key] {
        case .real(let value): value
        case .integer(let value): Double(value)
        case .text(let value): Double(value) ?? 0
        default: 0
        }
    }

    func integer(_ key: String) -> Int64 {
        switch cells[key] {
        case .integer(let value): value
        case .real(let value): Int64(value)
        case .text(let value): Int64(value) ?? 0
        default: 0
        }
    }
}

enum OakSQLError: Error {
    case openFailed
    case prepareFailed(String)
    case stepFailed(String)
}

final class OakSQLStore: @unchecked Sendable {
    private var db: OpaquePointer?
    private let lock = NSLock()
    private let transient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

    init(fileURL: URL) throws {
        let flags = SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX
        if sqlite3_open_v2(fileURL.path, &db, flags, nil) != SQLITE_OK {
            throw OakSQLError.openFailed
        }
        try exec("PRAGMA journal_mode=WAL;")
        try migrate()
    }

    deinit {
        sqlite3_close(db)
    }

    func exec(_ sql: String) throws {
        try write(sql, binds: [])
    }

    func write(_ sql: String, binds: [OakSQLValue] = []) throws {
        lock.lock()
        defer { lock.unlock() }
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            throw OakSQLError.prepareFailed(errmsg())
        }
        defer { sqlite3_finalize(stmt) }
        bind(stmt, binds)
        let code = sqlite3_step(stmt)
        guard code == SQLITE_DONE || code == SQLITE_ROW else {
            throw OakSQLError.stepFailed(errmsg())
        }
    }

    func query(_ sql: String, binds: [OakSQLValue] = []) throws -> [OakSQLRow] {
        lock.lock()
        defer { lock.unlock() }
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            throw OakSQLError.prepareFailed(errmsg())
        }
        defer { sqlite3_finalize(stmt) }
        bind(stmt, binds)
        var rows: [OakSQLRow] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            rows.append(readRow(stmt))
        }
        return rows
    }

    private func migrate() throws {
        try exec("""
        CREATE TABLE IF NOT EXISTS larder_entries (
            id TEXT PRIMARY KEY,
            sku TEXT NOT NULL,
            title TEXT NOT NULL,
            grams REAL NOT NULL,
            kcal REAL NOT NULL,
            protein REAL NOT NULL,
            carbs REAL NOT NULL,
            fat REAL NOT NULL,
            slot TEXT NOT NULL,
            day_key TEXT NOT NULL,
            kind TEXT NOT NULL
        );
        """)
        try exec("""
        CREATE TABLE IF NOT EXISTS larder_goals (
            id INTEGER PRIMARY KEY,
            kcal REAL NOT NULL,
            protein REAL NOT NULL,
            carbs REAL NOT NULL,
            fat REAL NOT NULL
        );
        """)
        try exec("""
        CREATE TABLE IF NOT EXISTS wish_skus (
            sku TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            house_mark TEXT,
            pinned_at REAL NOT NULL
        );
        """)
        try exec("""
        CREATE TABLE IF NOT EXISTS cellar_prefs (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
        );
        """)
    }

    private func bind(_ stmt: OpaquePointer?, _ values: [OakSQLValue]) {
        for (index, value) in values.enumerated() {
            let slot = Int32(index + 1)
            switch value {
            case .null:
                sqlite3_bind_null(stmt, slot)
            case .text(let string):
                sqlite3_bind_text(stmt, slot, string, -1, transient)
            case .real(let number):
                sqlite3_bind_double(stmt, slot, number)
            case .integer(let number):
                sqlite3_bind_int64(stmt, slot, number)
            }
        }
    }

    private func readRow(_ stmt: OpaquePointer?) -> OakSQLRow {
        let count = sqlite3_column_count(stmt)
        var cells: [String: OakSQLValue] = [:]
        for index in 0..<count {
            let name = String(cString: sqlite3_column_name(stmt, index))
            switch sqlite3_column_type(stmt, index) {
            case SQLITE_INTEGER:
                cells[name] = .integer(sqlite3_column_int64(stmt, index))
            case SQLITE_FLOAT:
                cells[name] = .real(sqlite3_column_double(stmt, index))
            case SQLITE_TEXT:
                if let pointer = sqlite3_column_text(stmt, index) {
                    cells[name] = .text(String(cString: pointer))
                } else {
                    cells[name] = .null
                }
            default:
                cells[name] = .null
            }
        }
        return OakSQLRow(cells: cells)
    }

    private func errmsg() -> String {
        if let pointer = sqlite3_errmsg(db) {
            return String(cString: pointer)
        }
        return "oak-sql"
    }
}
