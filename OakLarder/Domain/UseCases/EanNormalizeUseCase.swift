import Foundation

struct EanNormalizeUseCase: Sendable {
    func normalize(_ raw: String) -> String? {
        let compact = raw.filter(\.isNumber)
        if let stamped = stampedCode(from: compact) {
            return stamped
        }
        let runs = digitRuns(in: raw)
        let ranked = runs
            .filter { (8...14).contains($0.count) }
            .sorted { $0.count > $1.count }
        guard let best = ranked.first else { return nil }
        return stampedCode(from: best)
    }

    private func stampedCode(from digits: String) -> String? {
        guard (8...14).contains(digits.count) else { return nil }
        if digits.count == 12 {
            return "0" + digits
        }
        return digits
    }

    private func digitRuns(in raw: String) -> [String] {
        var runs: [String] = []
        var current = ""
        for character in raw {
            if character.isNumber {
                current.append(character)
            } else if !current.isEmpty {
                runs.append(current)
                current = ""
            }
        }
        if !current.isEmpty {
            runs.append(current)
        }
        return runs
    }
}
