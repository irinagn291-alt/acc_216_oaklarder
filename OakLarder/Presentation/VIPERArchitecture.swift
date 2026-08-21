import Foundation

// OakLarder uses VIPER so the single larder board (View) never owns persistence,
// Open Food Facts, or modal flow. Presenter orchestrates, Interactor runs Domain
// use cases against Data repositories, Router presents search/scan/detail/assign/
// plan/wish/goals/onboarding as modals. Layers: Presentation → Domain ← Data.

enum VIPERArchitecture {}
