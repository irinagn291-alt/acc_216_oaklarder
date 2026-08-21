import Foundation

struct ScanEntity: Sendable, Equatable {
    var rawStamp: String
    var normalized: String?
    var message: String
}
