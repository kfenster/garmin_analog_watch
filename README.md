# Analog Blue Watch Face

A Garmin Connect IQ watch face for the Fenix 8), inspired by various dive and GMT watches.
<img width="712" height="782" alt="image" src="https://github.com/user-attachments/assets/9014490b-71ed-4c24-8392-058a32051d89" />

## Features
- Royal blue dial background
- Distinctive markers at the 5-minute marks
- Day-of-week in arced text in the upper dial (with stainless rules)
- Date window in the lower dial with distinctive bulged sides
- GMT hour hand
- **Night / lume mode** — a companion watch face (`Analog Blue Night`) with a true black AMOLED dial and glowing cyan-green hands and markers, selectable as the watch's sleep face

## Compatible Devices
- Fenix 8: `fenix843mm`, `fenix847mm`, `fenix8pro47mm`, `fenix8solar47mm`, `fenix8solar51mm`

## Installing on Your Watch
No app store needed — sideload directly via USB. There are two watch faces to install:
* Day face (Garmin's "High Power") 
* Night/sleep face (Garmin's "Always on") -- on newer Garmin watches, you select a separate watch face as your "Sleep mode" face, so the "Always on" version is avaailable as a separate Night mode face.

### What you need
- A USB data cable (the Garmin charging cable is USB-A on the computer end; you may need a USB-A → USB-C adapter to plug into a modern Mac directly — avoid hubs). Copy two separate files:
- `bin/garminanalogwatchface.prg` — the day face
- `night/bin/garminanalogwatchfacenight.prg` — the night/sleep face

### Method 1: USB Mass Storage

1. Build both PRG files (see **Building from Source** below)
2. Connect your watch to your computer via USB
3. The watch should mount as a USB drive — if it only shows a charging screen, tap through to select **USB Mass Storage** mode
4. Open the mounted drive in Finder (Mac) or Explorer (Windows)
5. Copy **both** PRG files into the `GARMIN/APPS/` folder
6. Eject the drive and disconnect — the watch will verify and install both faces
7. Select the day face: hold **UP** → **Settings** → **Watch Face** → select **Analog Blue**
8. Select the sleep face: hold **UP** → **Settings** → **Watch Face** → **Sleep Face** → select **Analog Blue Night**

To update, overwrite the relevant `.prg` file(s) — no uninstall needed.

### Method 2: MTP via OpenMTP (Mac, if mass storage doesn't work)

Newer Fenix firmware may not expose mass storage mode. If your watch doesn't mount as a drive, try this:

1. On the watch, go to **Settings → System → USB** and set it to **Garmin** (not Media Transfer Protocol)
2. Install [OpenMTP](https://openmtp.ganeshrvel.com/) on your Mac (free, Mac App Store)
3. If Garmin Express is installed, kill its background service first — it conflicts with MTP access
4. Connect the watch via USB; when the Mac asks **"Use MTP?"**, accept
5. Open OpenMTP — the watch should appear
6. Navigate to `GARMIN/Apps/` on the watch
7. Copy **both** PRG files into that folder
8. Disconnect — the watch will display **"Verifying ConnectIQ apps"** then confirm installation
9. Select the day face: hold **UP** → **Settings** → **Watch Face** → **Analog Blue**
10. Select the sleep face: hold **UP** → **Settings** → **Watch Face** → **Sleep Face** → **Analog Blue Night**

## Building from Source

Requires the [Garmin Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/) and VS Code with the Monkey C extension.

### Day face
- Open the project folder in VS Code
- Press **F5** to build and run in the simulator
- Use **Monkey C: Build Current Project** from the command palette to produce `bin/garminanalogwatchface.prg`

### Night face
- Run **Terminal → Run Task → "Build Night PRG"**
- Output: `night/bin/garminanalogwatchfacenight.prg`
- The night face is a standalone project in `night/` — always renders the black/cyan-green lume palette with no mode switching.
