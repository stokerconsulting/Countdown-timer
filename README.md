# Countdown

iPhone-app (SwiftUI, iOS 17+) met tot vijf live aftel-timers. Kleurrijke kaarten met dagen/uren/minuten/seconden, voortgangsring, eigen emoji en kleurthema. Data wordt lokaal bewaard.

## Starten (op een Mac met Xcode)

```sh
brew install xcodegen
xcodegen        # genereert Countdown.xcodeproj
open Countdown.xcodeproj
```

Kies een simulator of je iPhone en druk op Run. Zonder XcodeGen: maak een nieuw iOS-App-project ("Countdown", SwiftUI) en sleep de bestanden uit `Countdown/` erin.

## Apple Watch

`CountdownWatch/` is de watchOS-app (watchOS 10+). De events komen van de iPhone via WatchConnectivity (`PhoneConnectivity.swift` → `WatchStore.swift`); de watch is alleen-lezen. Gedeelde modellen staan in `Shared/`. Bewerken doe je op de iPhone. Installeer de iPhone-app, dan verschijnt de watch-app op de gekoppelde Apple Watch.
