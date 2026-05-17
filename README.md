# 🌿 Lawn Mower Robot Controller — Flutter App

Complete Bluetooth controller for an autonomous lawn mower robot using
**Arduino Mega** + **HC-05/HC-06** Bluetooth module.

---

## 📁 Project Structure

```
lawn_mower_app/
├── lib/
│   ├── main.dart                          # App entry point + splash screen
│   ├── theme.dart                         # Colors, fonts, theme
│   ├── screens/
│   │   ├── home_screen.dart               # Main controller screen
│   │   └── settings_screen.dart           # Settings & command mapping
│   ├── widgets/
│   │   ├── grass_background.dart          # Animated lawn background
│   │   ├── glass_card.dart                # Semi-transparent glass cards
│   │   ├── direction_button.dart          # Press/release direction buttons
│   │   ├── distance_gauge.dart            # Color-coded distance gauge
│   │   └── connection_overlay.dart        # BT disconnected overlay
│   └── services/
│       ├── bluetooth_service.dart         # BT connection & data stream
│       └── settings_service.dart          # SharedPreferences persistence
├── android/
│   └── app/src/main/AndroidManifest.xml  # All Bluetooth permissions
├── assets/
│   └── images/
│       ├── logo_faculty.png               # ← PLACE YOUR LOGO HERE
│       └── logo_university.png            # ← PLACE YOUR LOGO HERE
└── arduino/
    └── lawn_mower_mega.ino               # Complete Arduino firmware
```

---

## 🖼️ LOGOS: How to Extract and Use

The uploaded PDF contains two logos (Faculty logo on left, University logo
on right). Follow these steps to extract and use them:

### Step 1 — Extract logos from the PDF

**Option A — Adobe Acrobat (best quality)**
1. Open `logo.pdf` in Adobe Acrobat
2. Tools → Export PDF → Image → PNG → Export
3. Or: Right-click each logo → Save Image

**Option B — PDF to PNG online tool**
1. Go to https://smallpdf.com/pdf-to-jpg or https://ilovepdf.com
2. Upload `logo.pdf` → convert → download PNG
3. Crop each logo individually in Paint/Preview

**Option C — Screenshot method (quick)**
1. Open the PDF at high zoom (400%) in any PDF viewer
2. Screenshot each logo
3. Crop tightly in any image editor

### Step 2 — Rename and place the files

Rename the extracted files exactly as shown below and copy them into
the project:

```
assets/images/logo_faculty.png      ← the LEFT logo (gear/technology)
assets/images/logo_university.png   ← the RIGHT logo (Kasdi Merbah Univ.)
```

### Step 3 — Verify pubspec.yaml

The `pubspec.yaml` already includes:
```yaml
flutter:
  assets:
    - assets/images/
```

No further changes needed. The app will automatically find the logos.

> **Note:** If the logo files are missing, the app shows a green placeholder
> icon and text. This is intentional — the app won't crash.

---

## ⚙️ Flutter Setup (Step by Step)

### Prerequisites
- Flutter SDK ≥ 3.0.0 installed
- Android Studio or VS Code with Flutter extension
- Physical Android device (Bluetooth needed — emulators won't work!)
- USB debugging enabled on the device

### Step 1 — Get dependencies
```bash
cd lawn_mower_app
flutter pub get
```

### Step 2 — Build & run
```bash
flutter run
```

Or build APK for direct install:
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

Install on device:
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## 📱 Android Permissions (Already Configured)

The `AndroidManifest.xml` already includes all required permissions:

| Permission | Purpose |
|---|---|
| `BLUETOOTH_CONNECT` | Android 12+ — connect to devices |
| `BLUETOOTH_SCAN` | Android 12+ — scan for devices |
| `BLUETOOTH` | Android < 12 classic BT |
| `ACCESS_FINE_LOCATION` | Required for BT on Android < 12 |

The app requests these at runtime on first launch automatically.

---

## 🔌 Pairing HC-05/HC-06 with Your Phone

1. Power on your Arduino with the HC-05/HC-06 connected
2. On Android: **Settings → Bluetooth → Pair new device**
3. Find `HC-05` or `HC-06` in the list
4. Enter PIN: **1234** (default for most modules)
5. Once paired, open the app → tap **Connect** → select your device

---

## 🤖 Arduino Firmware Setup

### Required: Upload `arduino/lawn_mower_mega.ino`

1. Open **Arduino IDE**
2. Select board: `Tools → Board → Arduino Mega 2560`
3. Select port: `Tools → Port → COMx` (your Mega's port)
4. Open `lawn_mower_mega.ino` and upload

### Pin Wiring Summary

```
HC-05/HC-06:
  TX → Mega RX1 (pin 19)
  RX → Mega TX1 (pin 18)  [use voltage divider: 1kΩ + 2kΩ]
  VCC → 5V, GND → GND

Motor Driver (L298N):
  LEFT_IN1  → pin 30
  LEFT_IN2  → pin 31
  LEFT_EN   → pin 2  (PWM)
  RIGHT_IN3 → pin 32
  RIGHT_IN4 → pin 33
  RIGHT_EN  → pin 3  (PWM)

Cutter Motor:
  Relay IN  → pin 40

Ultrasonic HC-SR04:
  TRIG → pin 50
  ECHO → pin 51
```

### Serial Communication Protocol

Arduino → App: `D:42.5\n` (distance in cm, every 200ms)
App → Arduino: single character command

| Command | Character (default) | Action |
|---|---|---|
| Forward | `F` | Move forward |
| Backward | `B` | Move backward |
| Left | `L` | Turn left |
| Right | `R` | Turn right |
| Stop | `S` | Stop all motors |
| Cutter ON | `C` | Start blade motor |
| Cutter OFF | `X` | Stop blade motor |

> All characters are **configurable in the app's Settings screen**.

---

## 🎛️ App Features

### Main Screen
- **Grass-themed background** with mowing stripe pattern
- **Logos** at top-left and top-right (Faculty + University)
- **Connection status** indicator (green dot = connected)
- **Connect button** → lists all paired BT devices

### Direction Control
- **Press & Hold** → sends command continuously
- **Release finger** → instantly sends `S` (Stop) — no unintended movement!
- Center **STOP** button for emergency stop

### Distance Gauge
- Real-time distance from ultrasonic sensor
- Color-coded: 🟢 Green (safe) → 🟡 Yellow (warning) → 🔴 Red (danger)
- Threshold markers on progress bar
- Configurable thresholds in Settings

### Cutter Toggle
- ON/OFF toggle with animated slider
- Visual status indicator (spinning animation when on)
- Disabled when Bluetooth is disconnected

### Settings Screen
- Accessible via gear ⚙️ icon
- Change movement command characters
- Change cutter command characters
- Change danger/warning distance thresholds
- All settings **persist after app restart** (SharedPreferences)

---

## 🐛 Troubleshooting

| Problem | Solution |
|---|---|
| Can't find HC-05 in device list | Pair it in Android Bluetooth settings first |
| "Permission denied" error | Grant all permissions when app asks; check Settings → Apps |
| Motors move wrong direction | Swap IN1/IN2 or IN3/IN4 wires on the motor driver |
| Distance always shows 999 | Check HC-SR04 wiring; TRIG/ECHO pins 50/51 |
| Commands not received | Verify HC-05 baud rate = 9600; change in AT mode if needed |
| App crashes on start | Run on physical device, not emulator; check Flutter version |

---

## 📦 Dependencies

```yaml
flutter_bluetooth_serial: ^0.4.0   # Classic BT for HC-05/HC-06
shared_preferences: ^2.2.2          # Persistent settings storage
permission_handler: ^11.1.0         # Runtime permission requests
```

> **Note:** `flutter_bluetooth_serial` uses Classic Bluetooth (SPP profile),
> which is exactly what HC-05 and HC-06 modules use. BLE libraries will
> NOT work with these modules.
