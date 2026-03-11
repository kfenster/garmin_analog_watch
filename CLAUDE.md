# GMT Master Watch Face — Developer Notes

## Project
Garmin Connect IQ watch face for Fenix 8 (and Fenix 7 / Epix 2), inspired by the Rolex GMT-Master II "Pepsi" blue dial (ref. 126719BLRO).

## Build Setup
- SDK: Connect IQ 8.4.1 at `/Users/kurt/Library/Application Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-8.4.1-2026-02-03-e9f77eeaa`
- Java: Eclipse Temurin 25 at `/Library/Java/JavaVirtualMachines/temurin-25.jdk/Contents/Home`
- Developer key: `/Users/kurt/developer_key`
- VS Code settings in `~/Library/Application Support/Code/User/settings.json`
- **Run in simulator**: F5 (uses `.vscode/launch.json`, device `fenix847mm`)
- Do NOT use "Run Tests" — it loads a test PRG, not the watch face

## Device Targets
- `fenix847mm` covers both the 47mm and 51mm AMOLED Fenix 8 variants
- Valid Fenix 8 product IDs: `fenix843mm`, `fenix847mm`, `fenix8pro47mm`, `fenix8solar47mm`, `fenix8solar51mm`
- IDs like `fenix8`, `fenix8s`, `fenix8x` do NOT exist in the SDK

## Monkey C Gotchas

### fillPolygon and type annotations
`fillPolygon` requires `Array<Array[Numeric, Numeric]>` (fixed-size tuples). The only reliable solution:
- Remove ALL explicit type annotations from polygon point arrays
- Use `new[n]` (untyped) for result arrays in helper functions
- Remove type annotations from helper function signatures entirely
- Let the compiler infer tuple types natively

### Rotation math (Y-down screen)
Clock angle 0 = 12 o'clock, increases clockwise.
Standard CCW rotation matrix produces visual CW rotation on a Y-down display:
```
rx = cx + px*cos(a) - py*sin(a)
ry = cy + px*sin(a) + py*cos(a)
```
Marker positions: `x = cx + r*sin(angle)`, `y = cy - r*cos(angle)`

### Text background
`dc.setColor(fg, bg)` — the second argument paints a background rectangle behind text characters. For text drawn inside a white box, always use `Graphics.COLOR_TRANSPARENT` as the background; otherwise single-digit numbers produce a narrower white rectangle that creates a visible step artifact.

### AffineTransform / setTransform not available
`dc.setTransform()` and `dc.clearTransform()` are undefined in this SDK version despite being documented for API 3.3+. Do not use them. For arc text, position characters along the arc without rotation (upright characters, arc-positioned centers).

### manifest.xml
- Use `minApiLevel`, not `minSdkVersion`
- `launcherIcon` must reference a drawable: `launcherIcon="@Drawables.LauncherIcon"`
- Launcher icon must be a 65x65 PNG in `resources/images/`
- `<iq:barrels/>` must be present even if empty

## Design Constants (at mR ≈ 225px for 454px AMOLED display)
- Dial color: `0x133565` (RGB 19, 53, 101 — matched from reference photo)
- Dial radius: `mR * 0.92`
- Minute tick outer: `mR * 0.905`, 5-min inner: `mR * 0.852`, minor inner: `mR * 0.880`
- Hour markers outer edge: `mR * 0.800` (rects), `mR * 0.822` (circles), triangle touches minute marks at `mR * 0.855`
- Circle markers: center at `mR * 0.744`, radius `mR * 0.075`
- Rect markers (3, 6, 9): `outerR = mR * 0.800`, `innerR = mR * 0.616`, `halfW = mR * 0.050`
- Steel color: `0x686860`, lume fill: `0xF0EEE8`

## Hour Markers
- 12 o'clock: downward triangle, `outerR = mR * 0.855`, `innerR = mR * 0.619`, `halfW = mR * 0.100`
- 3, 6, 9 o'clock: rectangular bars (identical treatment — no date window at 3)
- All others: applied circles

## Hands
- Hour: Mercedes design (shaft + circle with 3 spokes + triangular arrowhead). `shaftHW = mR * 0.048`, `circDist = mR * 0.355`, `circR = mR * 0.068`, `triTip = (mR * 0.820) - 45`, `triHW = mR * 0.032`. No tail.
- Minute: sword shape. `tip = mR * 0.775`, `hw = mR * 0.034`, `lw = hw - 3`. No tail.
- Second: white, crosses center. Tail circle (`mR * 0.027`) on short side, lollipop (`mR * 0.030`) on long side at `mR * 0.620`. Tip at `mR * 0.855`. Tail at `mR * 0.171`.

## Date Window
- Position: centered horizontally, `dCy = mCy + mR * 0.500 - 15` (lower dial)
- Fixed size: `dW = mR * 0.270`, `dH = mR * 0.250`, corner radius 4px
- Fill inset 1px inside border; inset shadow lines on top and left edges for recessed look
- Text: `FONT_SMALL`, centered, background `COLOR_TRANSPARENT`

## Day-of-Week Arc Text
- Positioned in upper dial between 12 o'clock triangle and center
- Arc: `arcR = mR * 0.780`, `arcCy = mCy + mR * 0.390 - 8` (arc center below text for gentle curve)
- First character: `FONT_TINY`, centered vertically; remaining: `FONT_XTINY`, biased toward inner rule
- Letter spacing: 3px; all uppercase
- Stainless arc rules above and below text; outer rule = 88% length of inner rule, centered
- Color: `0xE8E8DC` (matches lume on markers/hands)

## Dial Draw Order
1. `drawDial` — flat blue fill + thin steel ring
2. `drawMinuteTicks` — 60 ticks in chapter ring
3. `drawHourMarkers` — triangle, rects, circles
4. `drawDateWindow` — white inset box, lower center
5. `drawDayBox` — arc text upper dial
6. `drawHands` — hour, minute, second (drawn over everything)
7. `drawCenterDot` — polished steel cap

## Night / Sleep Face (`night/`)
- Separate standalone project — not a build variant of the day face
- Always renders sleep palette: no `mSleepMode` variable, no callbacks, no switching logic
- Sleep palette: black dial (`0x000000`), cyan-green lume (`0x00E5CC`), dark steel (`0x003830`), dim ticks (`0x0A2828`), gray date box (`0x585858` fill, `0x909090` text), muted day text (`0x505050`), dark rules (`0x303030`)
- App ID: `c9f2e817-3b5a-4d6c-a018-72e4f9b3c501` (distinct from day face)
- Build: **Terminal → Run Task → "Build Night PRG"** → `night/bin/garminanalogwatchfacenight.prg`
- Sideload both PRGs to `GARMIN/APPS/`; select GMT Master Night as the sleep face in watch settings
- Day face still has `mSleepMode` + `onEnterSleep`/`onExitSleep` wiring (for "Always On" display mode in simulator), but the Fenix 8 sleep face setting is the intended mechanism on device
- VS Code extension ignores `jungles` in launch.json — always builds root `monkey.jungle`; use the task for the night build

## Day Face Sleep Mode Wiring (source/GMTMasterView.mc)
- `mSleepMode` boolean + `setSleepMode()` public method
- `AppBase.onSleep()` / `onWake()` in GMTMasterApp delegate to `setSleepMode()`
- `onEnterSleep()` / `onExitSleep()` on WatchFace also set the flag (belt and suspenders)
- `onPartialUpdate()` delegates to `onUpdate()` so always-on display mode redraws correctly
- In simulator: "Display Mode → Always On" triggers sleep palette; "High Power" restores day palette

## Deferred / Future Work
- Red GMT hand (second timezone)
- User's own logo (space available in center/lower dial area)
