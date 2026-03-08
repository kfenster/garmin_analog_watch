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

### manifest.xml
- Use `minApiLevel`, not `minSdkVersion`
- `launcherIcon` must reference a drawable: `launcherIcon="@Drawables.LauncherIcon"`
- Launcher icon must be a 65x65 PNG in `resources/images/`
- `<iq:barrels/>` must be present even if empty

## Design Constants (at mR ≈ 128px for 260px diameter display)
- Dial color: `0x133565` (RGB 19, 53, 101 — matched from reference photo)
- Dial radius: `mR * 0.92`
- Minute tick outer: `mR * 0.905`, 5-min inner: `mR * 0.852`, minor inner: `mR * 0.880`
- Hour markers outer edge: `mR * 0.822` (~4px gap from minute ticks), except 12 o'clock triangle which touches the 59/1 minute marks (`mR * 0.855`)
- Circle markers: center at `mR * 0.744`, radius `mR * 0.075`
- Steel color: `0x686860`, lume fill: `0xF0EEE8`

## Date Window
- Position: `mCx + mR * 0.735` at vertical center
- Fixed size (fits "28"–"31"): `dW = mR * 0.270`, `dH = mR * 0.250`
- Corner radius: 4px
- Fill inset 1px inside border; inset shadow lines on top and left edges for recessed look
- Text: `FONT_SMALL`, `TEXT_JUSTIFY_CENTER | TEXT_JUSTIFY_VCENTER`, background `COLOR_TRANSPARENT`

## Deferred / Future Work
- Red GMT hand (second timezone)
- User's own logo (placeholder space near 12 or center)
