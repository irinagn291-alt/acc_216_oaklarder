import Foundation

enum GoodsOriginEntity: String, Sendable, Equatable {
    case cellarShelf
    case openFoodFacts
}

struct LarderGoodsEntity: Sendable, Equatable {
    let sku: String
    let title: String
    let houseMark: String?
    let kcalPerHundred: Double
    let proteinPerHundred: Double
    let carbsPerHundred: Double
    let fatPerHundred: Double
    let origin: GoodsOriginEntity
}

struct ServingMathEntity: Sendable, Equatable {
    let grams: Double
    let kcal: Double
    let protein: Double
    let carbs: Double
    let fat: Double
}

struct MacroPileEntity: Sendable, Equatable {
    var kcal: Double
    var protein: Double
    var carbs: Double
    var fat: Double

    static let vacant = MacroPileEntity(kcal: 0, protein: 0, carbs: 0, fat: 0)

    static func + (lhs: MacroPileEntity, rhs: MacroPileEntity) -> MacroPileEntity {
        MacroPileEntity(
            kcal: lhs.kcal + rhs.kcal,
            protein: lhs.protein + rhs.protein,
            carbs: lhs.carbs + rhs.carbs,
            fat: lhs.fat + rhs.fat
        )
    }
}

enum EntryKindEntity: String, Sendable, Equatable {
    case eaten
    case planned
}

struct LarderEntryEntity: Sendable, Equatable {
    let id: String
    let sku: String
    let title: String
    let grams: Double
    let kcal: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let slot: PantrySlotEntity
    let dayKey: String
    let kind: EntryKindEntity

    var pile: MacroPileEntity {
        MacroPileEntity(kcal: kcal, protein: protein, carbs: carbs, fat: fat)
    }
}

struct LarderGoalEntity: Sendable, Equatable {
    var kcal: Double
    var protein: Double
    var carbs: Double
    var fat: Double

    static let cellarDefault = LarderGoalEntity(kcal: 2150, protein: 98, carbs: 248, fat: 71)
}

struct WishSkuEntity: Sendable, Equatable {
    let sku: String
    let title: String
    let houseMark: String?
    let pinnedAt: TimeInterval
}

enum CellarShelfStock {
    static let tins: [LarderGoodsEntity] = [
        LarderGoodsEntity(sku: "oak-oats", title: "Oak-smoked porridge oats", houseMark: "Cellar Mill", kcalPerHundred: 379, proteinPerHundred: 13.2, carbsPerHundred: 67.7, fatPerHundred: 6.5, origin: .cellarShelf),
        LarderGoodsEntity(sku: "oak-rye", title: "Walnut rye heel", houseMark: "Board Bakery", kcalPerHundred: 259, proteinPerHundred: 8.9, carbsPerHundred: 48.0, fatPerHundred: 3.3, origin: .cellarShelf),
        LarderGoodsEntity(sku: "oak-broth", title: "Copper-kettle bone broth", houseMark: "Hearth Pot", kcalPerHundred: 38, proteinPerHundred: 6.1, carbsPerHundred: 1.2, fatPerHundred: 1.4, origin: .cellarShelf),
        LarderGoodsEntity(sku: "oak-honey", title: "Larder wildflower honey", houseMark: "Comb & Tin", kcalPerHundred: 304, proteinPerHundred: 0.3, carbsPerHundred: 82.4, fatPerHundred: 0.0, origin: .cellarShelf),
        LarderGoodsEntity(sku: "oak-beans", title: "Cast-iron baked beans", houseMark: "Iron Pantry", kcalPerHundred: 155, proteinPerHundred: 7.8, carbsPerHundred: 22.1, fatPerHundred: 4.2, origin: .cellarShelf),
        LarderGoodsEntity(sku: "oak-salmon", title: "Cedar plank salmon", houseMark: "River Smoke", kcalPerHundred: 208, proteinPerHundred: 20.4, carbsPerHundred: 0.0, fatPerHundred: 13.4, origin: .cellarShelf),
        LarderGoodsEntity(sku: "oak-butter", title: "Cellar apple butter", houseMark: "Orchard Crock", kcalPerHundred: 173, proteinPerHundred: 0.4, carbsPerHundred: 42.6, fatPerHundred: 0.3, origin: .cellarShelf),
        LarderGoodsEntity(sku: "oak-sardines", title: "Tin of olive sardines", houseMark: "Harbor Press", kcalPerHundred: 208, proteinPerHundred: 24.6, carbsPerHundred: 0.0, fatPerHundred: 11.5, origin: .cellarShelf)
    ]

    static func artName(for sku: String) -> String? {
        switch sku {
        case "oak-oats": "ShelfOats"
        case "oak-rye": "ShelfRye"
        case "oak-broth": "ShelfBroth"
        case "oak-honey": "ShelfHoney"
        case "oak-beans": "ShelfBeans"
        case "oak-salmon": "ShelfSalmon"
        case "oak-butter": "ShelfButter"
        case "oak-sardines": "ShelfSardines"
        default: nil
        }
    }
}

enum LarderDayStamp {
    static func key(_ date: Date = .now) -> String {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        return String(format: "%04d-%02d-%02d", year, month, day)
    }

    static func date(from key: String) -> Date? {
        let parts = key.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3 else { return nil }
        return Calendar.current.date(from: DateComponents(year: parts[0], month: parts[1], day: parts[2]))
    }

    static func monthPrefix(_ date: Date = .now) -> String {
        String(key(date).prefix(7))
    }

    static func spokenDay(_ key: String) -> String {
        guard let date = date(from: key) else { return key }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter.string(from: date)
    }
}
