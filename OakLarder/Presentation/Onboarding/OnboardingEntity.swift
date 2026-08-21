import Foundation

struct OnboardingPageEntity: Sendable, Equatable {
    let artName: String
    let title: String
    let body: String
}

struct OnboardingEntity: Sendable, Equatable {
    var pages: [OnboardingPageEntity]
    var index: Int
}
