# A Rolex GMT Master-inspired Watch Face

A Garmin Connect IQ watch face for the Fenix 8 (and Fenix 7 / Epix 2), inspired by the Rolex GMT-Master II "Pepsi" blue dial (ref. 126719BLRO) and the Oyster Perpetual Day Date.

## Features

- Royal blue dial background
- Mercedes-style hour hand with shaft, circle, and triangular arrowhead
- Sword-style minute hand with steel border and lume fill
- White second hand with lollipop circle
- Distinctive markers at the 5-minute marks
- Day-of-week in arced text in the upper dial (small caps, off-white, with stainless rules)
- Date window in the lower dial with distinctive bulged sides

## Compatible Devices

- Fenix 8: `fenix843mm`, `fenix847mm`, `fenix8pro47mm`, `fenix8solar47mm`, `fenix8solar51mm`
- Fenix 7: `fenix7`, `fenix7pro`, `fenix7s`, `fenix7spro`, `fenix7x`, `fenix7xpro`
- Epix 2: `epix2`, `epix2pro42mm`, `epix2pro47mm`, `epix2pro51mm`

## Installing on Your Watch

No app store needed — install directly via USB.

### What you need
- A USB data cable (the Garmin charging cable is USB-A on the computer end; you may need a USB-A → USB-C adapter to plug into a modern Mac directly — avoid hubs)
- The `bin/garminanalogwatchface.prg` file from this repo

### Method 1: USB Mass Storage

1. Download `bin/garminanalogwatchface.prg` from this repo
2. Connect your watch to your computer via USB
3. The watch should mount as a USB drive — if it only shows a charging screen, tap through to select **USB Mass Storage** mode
4. Open the mounted drive in Finder (Mac) or Explorer (Windows)
5. Copy `garminanalogwatchface.prg` into the `GARMIN/APPS/` folder
6. Eject the drive and disconnect
7. On the watch: hold **UP** (top-left button) → **Settings** → **Watch Face** → select the new face

To update, just overwrite the `.prg` file with a newer build — no uninstall needed.

### Method 2: MTP via OpenMTP (Mac, if mass storage doesn't work)

Newer Fenix firmware may not expose mass storage mode. If your watch doesn't mount as a drive, try this:

1. On the watch, go to **Settings → System → USB** and set it to **Garmin** (not Media Transfer Protocol)
2. Install [OpenMTP](https://openmtp.ganeshrvel.com/) on your Mac (free, Mac App Store)
3. If Garmin Express is installed, kill its background service first — it conflicts with MTP access
4. Connect the watch via USB; when the Mac asks **"Use MTP?"**, accept
5. Open OpenMTP — the watch should appear
6. Navigate to `GARMIN/Apps/` on the watch
7. Copy `garminanalogwatchface.prg` into that folder
8. Disconnect — the watch will display **"Verifying ConnectIQ apps"** then confirm installation
9. Select the watch face: hold **UP** → **Settings** → **Watch Face**

## Future Work

- **Night / lume mode** — when ambient light is low, switch to a black dial with glowing cyan-green hands and markers (matching the real lume glow in the dark), and a light gray date box background. AMOLED's true black would make the lume colors pop dramatically.
- **GMT / UTC hand** — a red arrow hand showing a second time zone, as on the original GMT-Master II. The hand would complete one revolution every 24 hours and be configurable via Garmin Connect settings.

## Building from Source

Requires the [Garmin Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/) and VS Code with the Monkey C extension.

- Open the project folder in VS Code
- Press **F5** to build and run in the simulator
- Use **Monkey C: Build Current Project** from the command palette to build a `.prg` for sideloading
