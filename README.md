# Slurp & Burp

You play a hungry hole in the ground. It has eyes, a mouth, and a wobble. Steer it around a timed round and anything smaller than the hole tips over the rim and falls in. The hole grows as it eats, so bigger things become snacks in tiers. Every level lasts two minutes. When the clock runs out, or the map is clear, the hole burps. A nibble is a tiny hic. Clearing the map is a long, low, screen-shaking burp. Then you get the percent eaten, a star rating, and your best score.

The name, shapes, and sounds are original. Props are built from boxes, spheres, cylinders, and cones. Slurps and burps are synthesized when they play. There are no ads, accounts, network calls, or purchases. Best scores stay on the device.

## Levels

All four levels are open from the start.

| Level | What's on the ground |
| --- | --- |
| Picnic Blanket | Grapes, cookies, napkins, plates, cupcakes, sandwiches, thermoses, a cooler, and the basket |
| Kitchen Rush | Spoons, spatulas, mugs, kettles, toasters, pots, chairs, the table, and the fridge |
| Backyard Bash | Balls, frisbees, gnomes, watering cans, planters, grills, bikes, and the doghouse |
| City Block | Cones, hydrants, trash cans, benches, cars, trees, kiosks, and small buildings |

Picnic is the gentle one: grapes fall in immediately, and the basket is the boss. Each world's largest prop stays inedible until you have eaten a good share of the smaller stuff. Eating everything in a level is a three-star clear and a legendary burp.

Stars: under 20% is zero, 20% is one, 45% is two, 75% is three. The end-of-round score adds a small bonus for time left and 750 points for clearing the map.

## Controls

The camera sits above and behind the hole and pulls back as the hole grows.

**iPhone.** Drag anywhere on the playfield. The hole rolls in that direction, faster as the drag gets longer. Portrait and landscape both work. Swallows and the burp trigger haptics. Pause with the button in the corner. Leaving the app pauses the clock.

**Mac.** WASD or the arrow keys, and click-drag or trackpad-drag. The window is resizable. Enter full screen from the green window button or View > Enter Full Screen. Escape pauses. A trackpad gives a light haptic tick on swallows and the burp.

## Project layout

- `Sources/SlurpAndBurpCore` is the game, with no UI and no RealityKit: growth, what can be eaten, level layouts, the round, scoring, stars, and burp size.
- `Tests/SlurpAndBurpCoreTests` is XCTest for those rules.
- `App/SlurpAndBurp.xcodeproj` is one SwiftUI app with an iOS target and a macOS target. They share `App/Shared`. The 3D view is RealityKit with a virtual camera, not the device camera, so the game does not ask for camera permission.

The signing team is not set. Signing style is Automatic, so you pick your own team in Xcode.

## Run it on a Mac

1. Install Xcode 26 (the project targets iOS 18 and macOS 15, and CI builds with the Xcode that ships on the macOS 26 runner).
2. Open `App/SlurpAndBurp.xcodeproj`.
3. Wait for the local `SlurpAndBurpCore` package to resolve. It has no third-party dependencies.
4. Select the **SlurpAndBurp-macOS** scheme and **My Mac**.
5. In Signing & Capabilities, choose your Team. For a quick local run you can instead set Signing Certificate to **Sign to Run Locally**.
6. Press Run.

## Install it on an iPhone

### Free personal team

A free Apple ID can install the app on your own phone for about 7 days. After that, build and run again from Xcode.

1. On the iPhone, open Settings > Privacy & Security > Developer Mode, turn it on if the phone asks, and reboot.
2. Connect the phone and tap Trust.
3. Open the project, select the **SlurpAndBurp-iOS** scheme, and choose your iPhone as the run destination.
4. Select the SlurpAndBurp-iOS target, open Signing & Capabilities, check Automatically manage signing, and set Team to your Personal Team.
5. If Xcode says the bundle id is unavailable, change `com.cloudguyus.SlurpAndBurp` to something unique, such as `com.yourname.SlurpAndBurp`.
6. Press Run.
7. If the phone says the developer is untrusted, open Settings > General > VPN & Device Management, trust your certificate, and launch Slurp & Burp from the home screen.

### TestFlight

TestFlight needs a paid Apple Developer Program membership.

1. Select the iOS scheme and the destination **Any iOS Device (arm64)**.
2. Product > Archive.
3. In the Organizer, Distribute App > App Store Connect > Upload.
4. In App Store Connect, open the app, wait for processing, and add yourself or testers under TestFlight.
5. Testers install the TestFlight app and accept the build.

The Mac target is for running locally from Xcode. It is not set up as a Mac App Store product.

## Tests and CI

```bash
swift test
```

That runs the core XCTest suite: growth, edibility, star and burp thresholds, level contents, the guarantee that every level can be cleared from small to large, steering, pause, and saved scores.

GitHub Actions (`.github/workflows/ci.yml`) runs those tests on a macOS 26 runner, builds the iOS simulator app, builds the Mac app, and saves simulator screenshots of Picnic, a burp, and the results card. Both app builds pass `CODE_SIGNING_ALLOWED=NO`, so CI does not need a signing team.
