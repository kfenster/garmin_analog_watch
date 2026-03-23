# Analog Blue Watch Face — Developer Notes

## Project
Garmin Connect IQ watch face for Fenix 8 (and Fenix 7 / Epix 2), inspired by the Rolex GMT-Master and Oyster Day-Date Perpetual designs.

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
- Dial color: `0x1F4E8C` (day), `0x0B0D10` (night — deep blue-black, not pure black)
- Dial radius: `mR * 0.92`
- Minute tick outer: `mR * 0.905`, 5-min inner: `mR * 0.852`, minor inner: `mR * 0.880`
- Steel color: `0x686860` (day), lume fill: `0xFFFFFF` (day hands), `0xDCE8D0` / `0xD6E4CC` (night)

## Hour Markers
- No outlines or borders on any marker — solid lume fill only
- 12 o'clock: downward triangle, `outerR = mR * 0.855`, `innerR = mR * 0.664`, `halfW = mR * 0.085`
- 3, 6, 9 o'clock: rectangular bars. `outerR = mR * 0.800 + 5`, `innerR = mR * 0.630 + 5`, `halfW = mR * 0.046` (15% smaller area than original, shifted 5px outward)
- All others: applied circles. `dist = mR * 0.744 + 5`, `r = mR * 0.063` (shifted 5px outward)
- `drawCircleMarker` takes a radius parameter — call with `mR * 0.063` for standard positions

## GMT Ghost Ring
- Replaces the old full 24-hour ring (which was removed as too cluttered)
- 12 ticks at 2-hour intervals (no numerals); major ticks at 0/6/12/18h
- `ringR = mR * 0.740`; tick length ±3px minor, ±5px major; pen width 1
- Day color: `0x888880`; night color: `0x1A1E1C` (very dim)
- **Must be drawn before hour markers** (draw order) — otherwise major ticks bleed into markers at 3/6/9/12

## Hands
- Hour: baton design. `shaftHW = mR * 0.055`, `tipDist = mR * 0.600`, `triH = mR * 0.153`, `triHW = mR * 0.083`. One-piece 7-point polygon. No tail.
- Minute: arrowhead shape. `tip = mR * 0.900`, `hw = mR * 0.034`, `lw = hw - 2`, `arrowH = mR * 0.155`, `arrowHW = hw + 5`. No tail.
- GMT (UTC): burnt orange day (`0xE06A2B`), dimmed orange night (`0xC46A2D`). `hw = mR * 0.014`, `tip = mR * 0.750 + 8`, `arrowH = mR * 0.138`, `arrowHW = (hw + 5) * 1.15`. Drawn above hour, below minute. UTC angle uses 12-hour formula: `(utcH24 % 12 + utcM / 60.0) * (2π / 12)`.
- Second: cool gray (`0xB8C2D0` day, `0x7E848A` night). `tipLen = mR * 0.920`, `lollDist = mR * 0.620`, `lollR = mR * 0.020` (hollow circle), `tailLen = mR * 0.171`, `tailCircR = mR * 0.027`.

## Date Window
- Position: `dCy = mCy + mR * 0.500 - 22` (lower dial, centered horizontally)
- Size: `dW = mR * 0.215`, `dH = mR * 0.200`; bulged sides (convex arc left/right)
- Day: white fill, `0xCCCCCC` border (pen width 2), black text `FONT_TINY`
- Night: `0x4A4D50` fill, `0x363840` border (pen width 2), `0xD8DDD8` text

## Day-of-Week Arc Text
- Arc: `arcR = mR * 0.680` (tighter curve than original), uniform `FONT_XTINY` for all characters
- Position pinned at runtime: `arcCy = mCy - mR * 0.664 + 12 + rOuter` — outer rule top sits 12px below triangle apex; triangle apex is the current `innerR = mR * 0.664`
- Letter spacing: 5px; all uppercase; `ruleExtra = 8px`; outer rule = 88% of inner span
- Day color: `0xE6E6E6`; night color: `0xA7ADB3`

## Dial Draw Order
1. `drawDial` — filled circle + steel ring (day only)
2. `drawMinuteTicks` — 60 ticks
3. `drawGMTGhostRing` — subtle 12-tick ring (must precede markers)
4. `drawHourMarkers` — triangle, rects, circles
5. `drawDateWindow` — lower center
6. `drawDayBox` — arc text upper dial
7. `drawHands` — hour, GMT, minute, second
8. `drawCenterDot` — polished steel cap

## Night / Sleep Face (`night/`)
- Separate standalone project — not a build variant of the day face
- Always renders night palette: no `mSleepMode` variable, no callbacks, no switching logic
- Night palette visual hierarchy: hour/minute hands → markers → GMT hand → date → day text → seconds
- Night lume: `0xDCE8D0` (hands), `0xD6E4CC` (markers); hand steel border: `0x1A3828`
- GMT: `0xC46A2D` (orange family, same as day but dimmer — do NOT shift to red or gold)
- Seconds: `0x7E848A` — visible only when sought, not at a glance
- Center dot: two-layer only (no specular highlight) — models a matte cap under low ambient light
- App ID: `c9f2e817-3b5a-4d6c-a018-72e4f9b3c501` (distinct from day face)
- Build: **Terminal → Run Task → "Build Night PRG"** → `night/bin/garminanalogwatchfacenight.prg`
- Sideload both PRGs to `GARMIN/APPS/`; select Analog Blue Night as the sleep face in watch settings
- Day face still has `mSleepMode` + `onEnterSleep`/`onExitSleep` wiring (for "Always On" display mode in simulator), but the Fenix 8 sleep face setting is the intended mechanism on device
- VS Code extension ignores `jungles` in launch.json — always builds root `monkey.jungle`; use the task for the night build
- **Any change to `night/source/` requires a manual "Build Night PRG" task run** — F5 only rebuilds the day face PRG

## Day Face Sleep Mode Wiring (source/GMTMasterView.mc)
- `mSleepMode` boolean + `setSleepMode()` public method
- `AppBase.onSleep()` / `onWake()` in GMTMasterApp delegate to `setSleepMode()`
- `onEnterSleep()` / `onExitSleep()` on WatchFace also set the flag (belt and suspenders)
- `onPartialUpdate()` delegates to `onUpdate()` so always-on display mode redraws correctly
- In simulator: "Display Mode → Always On" triggers sleep palette; "High Power" restores day palette

## Deferred / Future Work
- User's own logo (space available in center/lower dial area)
