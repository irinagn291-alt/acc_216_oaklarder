import Foundation

enum OffCatalogError: Error {
    case badURL
    case transport
    case empty
}

actor OffCatalogClient {
    private let session: URLSession
    private let scale = PortionScaleUseCase()

    init() {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 12
        config.timeoutIntervalForResource = 18
        session = URLSession(configuration: config)
    }

    func search(query: String) async throws -> Data {
        var parts = URLComponents(string: "https://world.openfoodfacts.org/cgi/search.pl")
        parts?.queryItems = [
            URLQueryItem(name: "search_terms", value: query),
            URLQueryItem(name: "search_simple", value: "1"),
            URLQueryItem(name: "action", value: "process"),
            URLQueryItem(name: "json", value: "1"),
            URLQueryItem(name: "page_size", value: "24")
        ]
        guard let url = parts?.url else { throw OffCatalogError.badURL }
        return try await fetch(url)
    }

    func product(code: String) async throws -> Data {
        guard let url = URL(string: "https://world.openfoodfacts.org/api/v2/product/\(code).json") else {
            throw OffCatalogError.badURL
        }
        return try await fetch(url)
    }

    func parseSearch(_ data: Data) -> [LarderGoodsEntity] {
        guard
            let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let products = root["products"] as? [[String: Any]]
        else { return [] }
        return products.compactMap(goods(from:))
    }

    func parseProduct(_ data: Data) -> LarderGoodsEntity? {
        guard
            let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let product = root["product"] as? [String: Any]
        else { return nil }
        return goods(from: product)
    }

    private func fetch(_ url: URL) async throws -> Data {
        var request = URLRequest(url: url)
        request.setValue(
            "OakLarder/1.0 (iOS; com.oaklarder.pantry; pantry-log) — https://oaklarder.app",
            forHTTPHeaderField: "User-Agent"
        )
        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                throw OffCatalogError.transport
            }
            return data
        } catch {
            throw OffCatalogError.transport
        }
    }

    private func goods(from object: [String: Any]) -> LarderGoodsEntity? {
        let sku = (object["code"] as? String) ?? (object["_id"] as? String) ?? ""
        let title = cleaned(object["product_name"] as? String) ?? cleaned(object["product_name_en"] as? String)
        guard !sku.isEmpty, let title else { return nil }
        let nuts = object["nutriments"] as? [String: Any] ?? [:]
        let kcal: Double
        if let direct = number(nuts["energy-kcal_100g"]) {
            kcal = direct
        } else if let kilojoules = number(nuts["energy_100g"]) {
            kcal = scale.kcalFromKilojoules(kilojoules)
        } else {
            kcal = 0
        }
        return LarderGoodsEntity(
            sku: sku,
            title: title,
            houseMark: cleaned(object["brands"] as? String),
            kcalPerHundred: kcal,
            proteinPerHundred: number(nuts["proteins_100g"]) ?? 0,
            carbsPerHundred: number(nuts["carbohydrates_100g"]) ?? 0,
            fatPerHundred: number(nuts["fat_100g"]) ?? 0,
            origin: .openFoodFacts
        )
    }

    private func cleaned(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private func number(_ value: Any?) -> Double? {
        switch value {
        case let number as Double: number
        case let number as Int: Double(number)
        case let number as NSNumber: number.doubleValue
        case let text as String: Double(text)
        default: nil
        }
    }
}
