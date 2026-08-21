import Foundation

@MainActor
final class AssignRouter {
    weak var host: AnyObject?
    private let factory: OakLarderFactory

    init(factory: OakLarderFactory) {
        self.factory = factory
    }

    func finish(kind: EntryKindEntity) {
        factory.dismissToLarder(thenPlan: kind == .planned)
    }
}
