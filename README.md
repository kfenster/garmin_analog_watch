# GMT Master Watch Face

A Garmin Connect IQ watch face for the Fenix 8 (and Fenix 7 / Epix 2), inspired by the Rolex GMT-Master II "Pepsi" blue dial (ref. 126719BLRO).

## Features

- Royal blue dial matched from reference photo (`#133565`)
- Rolex Mercedes-style hour hand with shaft, circle, and triangular arrowhead
- Sword-style minute hand with steel border and lume fill
- White second hand with lollipop circle
- Applied hour markers: downward triangle at 12, rectangular bars at 3/6/9, circles at all others
- Day-of-week arc text in the upper dial (small caps, off-white, with stainless rules)
- Date window in the lower dial with distinctive bulged sides
- No branding — space reserved for your own logo

## Compatible Devices

- Fenix 8: `fenix843mm`, `fenix847mm`, `fenix8pro47mm`, `fenix8solar47mm`, `fenix8solar51mm`
- Fenix 7: `fenix7`, `fenix7pro`, `fenix7s`, `fenix7spro`, `fenix7x`, `fenix7xpro`
- Epix 2: `epix2`, `epix2pro42mm`, `epix2pro47mm`, `epix2pro51mm`

## Sideloading to Your Watch

No app store needed — install directly via USB.

### What you need
- A USB data cable (the Garmin charging cable is USB-A on the computer end; you may need a USB-A → USB-C adapter to plug into a modern Mac directly — avoid hubs)
- The `bin/garminanalogwatchface.prg` file from this repo

### Steps
1. Download `bin/garminanalogwatchface.prg` from this repo
2. Connect your watch to your computer via USB
3. The watch should mount as a USB drive — if it only shows a charging screen, tap through to select **USB Mass Storage** mode
4. Open the mounted drive in Finder (Mac) or Explorer (Windows)
5. Copy `garminanalogwatchface.prg` into the `GARMIN/APPS/` folder
6. Eject the drive and disconnect
7. On the watch: hold **UP** (top-left button) → **Settings** → **Watch Face** → select the new face

To update, just overwrite the `.prg` file with a newer build — no uninstall needed.

## Building from Source

Requires the [Garmin Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/) and VS Code with the Monkey C extension.

- Open the project folder in VS Code
- Press **F5** to build and run in the simulator
- Use **Monkey C: Build Current Project** from the command palette to build a `.prg` for sideloading
