import Foundation

@MainActor
final class OnboardingInteractor {
    private let prefs: PreferenceSQLiteRepository

    init(prefs: PreferenceSQLiteRepository) {
        self.prefs = prefs
    }

    func pages() -> [OnboardingPageEntity] {
        [
            OnboardingPageEntity(
                artName: "OnboardPantry",
                title: "The oak larder",
                body: "A single board for the day. Morning loaf, noon board, dusk roast, and a night crumb."
            ),
            OnboardingPageEntity(
                artName: "OnboardScale",
                title: "Weigh the tin",
                body: "Portions live in grams. The cellar scales kcal and macros from each hundred."
            ),
            OnboardingPageEntity(
                artName: "OnboardCrate",
                title: "Stamp a crate",
                body: "Seek a name or stamp a barcode. Distant crates cache onto disk when the pantry goes dark."
            ),
            OnboardingPageEntity(
                artName: "OnboardLedger",
                title: "A month of ledgers",
                body: "Plan three sittings ahead. Night crumb stays on the eaten board only."
            )
        ]
    }

    func finish() async {
        await prefs.markOnboardingFinished()
    }
}
