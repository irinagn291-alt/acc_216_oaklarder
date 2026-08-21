# OakLarder

Skeuomorphic oak-and-brass pantry log. One home board, every other flow as a modal. Calories and macros against cellar aims. Offline-first: SQLite larder + disk cache of Open Food Facts.

Bundle ID: `com.oaklarder.pantry`  
iOS 17+, iPhone portrait, Swift 6.2, Health & Fitness.

## Architecture

VIPER (`Presentation/` → `Domain/` ← `Data/`). Comment at `OakLarder/Presentation/VIPERArchitecture.swift`.

Suffixes: `*ViewProtocol`, `*PresenterProtocol`, `*Interactor`, `*Router`, `*Entity`.

Programmatic UIKit + SnapKit (SPM). No storyboards.

## Core flow

Onboard → Today → Search/Scan → Detail → Assign → Today (or Plan).  
Today also opens Eaten (the home log), Wish nail, Aims, Month ledger.

Slots: **Morning loaf** / **Noon board** / **Dusk roast** / **Night crumb** (crumb only on the eaten board).

Default aims: 2150 kcal / 98 P / 248 C / 71 F. Plan horizon: month.

Portion: `kcal = kcal100 * grams / 100` (same for P/C/F). kJ fallback: `energy_100g / 4.184`.  
EAN: digits 8–14 from raw/URL; UPC-12 → `0` + code.

Catalog: `world.openfoodfacts.org` search + `/api/v2/product/{code}.json`.  
User-Agent: `OakLarder/1.0 (iOS; com.oaklarder.pantry; pantry-log) — https://oaklarder.app`

## Unique features

Offline-first SQLite larder plus disk cache of Open Food Facts. One home board; every other flow is a modal. Night crumb is eaten-only. Plan horizon is a month.

## How it differs

VIPER + programmatic UIKit + SnapKit. Oak/brass skeuomorph. Not a glass tray, neon arcade, civic desk, watercolor kitchen, or pulse grid.

## Persistence

- SQLite file `Documents/oak_larder.sqlite` (entries, aims, wishes, prefs)
- Disk cache `Documents/OffCache/off-*.json` for OFF payloads

## Dependencies

CocoaPods: none. SPM: SnapKit `5.7.1`, Alamofire (gate).

Font: Libre Baskerville (OFL) in `OakLarder/Resources/Fonts/` + `LICENSE` / `OFL.txt`.

## Build

```bash
xcodegen generate
xcodebuild -project OakLarder.xcodeproj -scheme OakLarder \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  CODE_SIGNING_ALLOWED=NO build
```

Unit tests: Domain use cases, Given/When/Then.

## Asset prompts (GenerateImage, 4k photoreal octane, unique set)

| Asset | Prompt |
|---|---|
| AppIcon | Photoreal octane render, 4k, carved dark-oak pantry door, oval antique brass plaque with acorn and wheat sheaf, no text |
| Splash | Photoreal octane render, 4k, dim oak larder interior, brass oil lantern, jars and copper pots, no text |
| OnboardPantry | Photoreal octane render, 4k, open tall oak pantry cupboard with jars and copper canisters |
| OnboardScale | Photoreal octane render, 4k, antique brass kitchen scale on oak butcher block |
| OnboardCrate | Photoreal octane render, 4k, rustic wooden crate stamped with a barcode |
| OnboardLedger | Photoreal octane render, 4k, leather-bound monthly kitchen ledger on oak desk |
| EmptyPlate | Photoreal octane render, 4k, empty pewter plate on dark oak |
| EmptyWish | Photoreal octane render, 4k, empty glass wish jar with cork |
| EmptyLedger | Photoreal octane render, 4k, closed blank leather journal with brass clasp |
| SlotMorningLoaf | Photoreal octane render, 4k, rustic sourdough morning loaf on a wooden board |
| SlotNoonBoard | Photoreal octane render, 4k, noon charcuterie board on oak |
| SlotDuskRoast | Photoreal octane render, 4k, dusk roast in a cast-iron pan |
| SlotNightCrumb | Photoreal octane render, 4k, night crumb still life with cheese heel and candle |
| ShelfOats | Photoreal octane render, 4k, linen sack of oak-smoked porridge oats |
| ShelfRye | Photoreal octane render, 4k, walnut rye bread heel on a wooden board |
| ShelfBroth | Photoreal octane render, 4k, copper kettle and jar of bone broth |
| ShelfHoney | Photoreal octane render, 4k, hexagonal jar of wildflower honey |
| ShelfBeans | Photoreal octane render, 4k, cast-iron pot of baked beans |
| ShelfSalmon | Photoreal octane render, 4k, cedar plank salmon fillet |
| ShelfButter | Photoreal octane render, 4k, stoneware crock of apple butter |
| ShelfSardines | Photoreal octane render, 4k, open tin of sardines in olive oil |
| TexOakPlank | Photoreal octane render, 4k seamless antique oak table plank material texture |
| TexBrushedIron | Photoreal octane render, 4k seamless brushed wrought iron material texture |
| ChromeBrassKnob | Photoreal octane render, 4k, antique brass cabinet knob on oak mount |
| ChromeIronFrame | Photoreal octane render, 4k, square empty wrought-iron frame with rivets |
| ChromeBrassPlaque | Photoreal octane render, 4k, wide antique brass nameplate on oak, empty field |

Same prompts live in `Assets.xcassets/*/Contents.json` `info.comment`.
