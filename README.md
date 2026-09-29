# IoT Water Quality Monitoring System

An end-to-end water-quality monitoring prototype. An ESP32 samples pH, total dissolved solids (TDS), turbidity, and temperature, classifies readings locally, and sends telemetry to a Node.js API. The API stores readings in MongoDB and can send Firebase Cloud Messaging (FCM) alerts. A Flutter app displays the latest readings, history, alerts, and locally generated insight.

This repository contains the mobile app, backend, microcontroller firmware, PCB design files, and Proteus simulation project.

> **Safety note:** This is an engineering prototype, not a certified drinking-water testing device. Do not use it as the sole basis for decisions about water safety.

## System Overview

```text
pH / TDS / turbidity / temperature sensors
                  |
                  v
ESP32 firmware -- Wi-Fi/HTTP --> Node.js API --> MongoDB
     |                                  |
     | Wi-Fi unavailable               +--> Firebase Admin / FCM --> Flutter app
     v                                  |
 GSM modem sends SMS                    +--> Latest readings and insight API

Flutter app -- HTTP polling / token registration --> Node.js API
```

The firmware currently samples for approximately 30 seconds per reading cycle. It posts JSON to `POST /api/telemetry`; when Wi-Fi is unavailable, its GSM path can send SMS alerts for critical water readings or a turbidity sensor fault. The backend persists readings, tracks device state, and sends push notifications when alert conditions warrant them. The app polls for the latest reading every 10 seconds, fetches history and insights, and registers its FCM token with the backend.

## Repository Layout

```text
.
|-- firmware/                         ESP32 Arduino firmware
|   `-- firmware/firmware.ino
|-- iot backend/                      Express API, MongoDB models, FCM and tests
|   |-- controllers/
|   |-- models/
|   |-- services/
|   |-- scripts/
|   `-- test/
|-- PCB design/WaterQualityMonitor/   KiCad schematics, PCB, and Gerbers
|-- proteus/                          Proteus simulation project and backups
|-- water-quality-monitoring-app/     Flutter mobile and web client
|   |-- lib/
|   |-- android/ ios/ web/ windows/ ...
|   `-- pubspec.yaml
└-- README.md
```

## Technology

- **Firmware:** ESP32 Arduino core, ArduinoJson, OneWire, and DallasTemperature libraries; Wi-Fi telemetry and optional GSM SMS fallback.
- **Backend:** Node.js, Express, Mongoose/MongoDB, Firebase Admin SDK, and dotenv.
- **Mobile app:** Flutter/Dart, Riverpod, Firebase Core/Messaging, local notifications, and `fl_chart`.
- **Electronics and simulation:** KiCad schematics/PCB/Gerber output and a Proteus project.

## Requirements

- Git.
- Node.js and npm for the backend.
- MongoDB instance or MongoDB Atlas database.
- Flutter SDK and Dart SDK compatible with the constraint in `water-quality-monitoring-app/pubspec.yaml` (`^3.9.2`). Install Android Studio/Android SDK for Android builds; install the relevant platform toolchain for other targets.
- A Firebase project with Cloud Messaging enabled for push notifications. The app also needs its generated Firebase platform configuration.
- Arduino IDE or PlatformIO with ESP32 board support for firmware work.
- KiCad and Proteus only when editing or opening the hardware design and simulation files.

## Configuration

### Backend

Create `iot backend/.env`:

```dotenv
MONGO_URI=mongodb+srv://<user>:<password>@<cluster>/<database>
PORT=5000
```

The backend initializes Firebase Admin from either `FIREBASE_SERVICE_ACCOUNT` (a JSON string, suited to a deployment secret) or a local `iot backend/firebase-service-account.json` file. Provide a valid service account through one of these mechanisms to send push notifications. Keep service-account credentials private; never put their contents in source control, issue comments, or documentation. If a service-account key has been committed or otherwise exposed, revoke it and create a replacement.

The current backend requires MongoDB to persist telemetry and alerts. The local service listens on port `5000` by default; `PORT` overrides this.

### Flutter and Firebase

The Flutter app calls Firebase initialization in `lib/services/firebase_service.dart` using `lib/firebase_options.dart`. That options file is generated Firebase client configuration, not the Admin service-account key. To connect the app to your own Firebase project:

1. Create or select a Firebase project and enable Cloud Messaging.
2. From the Flutter app directory, install and run FlutterFire CLI if needed:

   ```shell
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

3. Select the project and platforms you intend to run, then review the generated `lib/firebase_options.dart` and native configuration files.
4. For push delivery, make sure the backend's Firebase Admin service account belongs to the same Firebase project as the app.

The app currently targets device ID `ESP32_221A74`. Keep the firmware ID and app `AppConfig.targetDeviceId` aligned, or update both to the ID used by your device.

### Local API URL

The firmware's `serverEndpoint`, the app's latest-reading `apiEndpoint` in `lib/providers/water_data_provider.dart`, and the app's `AppConfig.backendBaseUrl` in `lib/utils/constants.dart` determine which backend is used. They currently include the hosted API URL. For local testing, update these values to your reachable local backend address. A physical phone or ESP32 cannot use its own `localhost` to reach your development computer; use the computer's LAN IP address and ensure the port is reachable. The app has separate URL use for telemetry fetching and token registration, so update both app locations consistently.

Avoid committing personal Wi-Fi credentials, phone numbers, API secrets, or service-account files in firmware or source files. Supply local device settings privately and replace any example/default credentials before flashing hardware.

## Run Locally

### 1. Start the backend

With MongoDB and Firebase Admin credentials configured as above:

```shell
cd "iot backend"
npm install
npm start
```

Check that the service responds at `http://localhost:5000/`. The root route returns a JSON health response. The API currently has no authentication or authorization middleware; do not expose a self-hosted instance to an untrusted network without adding appropriate access controls and transport security.

### 2. Run the Flutter app

In a separate terminal:

```shell
cd water-quality-monitoring-app
flutter pub get
flutter run
```

Select an available emulator or attached device. Configure the API URLs and Firebase project first if you are not using the currently configured hosted API and Firebase project. Flutter web uses the local backend URL in `AppConfig.backendBaseUrl` for token registration; its latest-reading provider also has a separately configured URL.

### 3. Build and upload firmware

Open `firmware/firmware/firmware.ino` in Arduino IDE (or import it into your preferred ESP32 Arduino workflow). Install ESP32 board support and the ArduinoJson, OneWire, and DallasTemperature libraries. `WiFi`, `HTTPClient`, and ADC support are provided by the ESP32 Arduino core.

Before uploading, configure the Wi-Fi credentials, API endpoint, device ID, GSM wiring, and SMS recipient for your own setup. Connect the sensors according to the pin definitions in the sketch:

| Component | ESP32 pin in firmware |
| --- | --- |
| DS18B20 data | GPIO 4 |
| TDS analog output | GPIO 35 |
| Turbidity analog output | GPIO 32 |
| pH analog output | GPIO 34 |
| GSM UART RX | GPIO 16 |
| GSM UART TX | GPIO 17 |

Confirm the sensor modules' voltage requirements, ESP32 ADC constraints, GSM modem power supply, and common ground before wiring. Calibrate sensor conversion constants against known reference solutions and verify readings independently before relying on the output. Open Serial Monitor at `115200` baud for sampling and transmission diagnostics.

## Telemetry Contract

The firmware sends this shape to `POST /api/telemetry` with `Content-Type: application/json`:

```json
{
  "deviceId": "ESP32_221A74",
  "status": "SAFE",
  "flags": {
    "hardwareFault": false,
    "isCritical": false
  },
  "metrics": {
    "temperature": 25.0,
    "tds_ppm": 250,
    "turbidity_ntu": 2.0,
    "ph": 7.0
  }
}
```

The API adds the timestamp when it stores the reading. The backend's Mongoose model requires `deviceId`, `status`, and all four metric values. Status values produced in the firmware include `SAFE`, `CAUTION`, `LIMITED USE`, and `UNSAFE`.

## API Reference

The Express service currently provides:

| Method | Path | Purpose |
| --- | --- | --- |
| `GET` | `/` | Service health response |
| `GET` | `/api/telemetry` | Telemetry ingress status message |
| `POST` | `/api/telemetry` | Store a reading and evaluate push-alert conditions |
| `GET` | `/api/telemetry/latest/:deviceId` | Latest reading for a device |
| `GET` | `/api/telemetry/latest/:deviceId/insight` | Local rule-based insight for the latest reading |
| `POST` | `/api/register-token` | Register/update an FCM token (`deviceId`, `token`, `platform`) |
| `GET` | `/api/alerts` | Return the most recent 50 alert records |
| `POST` | `/api/alerts/:id/read` | Mark an alert as read |

## Tests

Run the backend's current unit tests from `iot backend/`:

```shell
npm run test:alert
npm run test:ai
```

`npm run test:push` sends a real Firebase push notification and requires valid credentials and a target token. Use it only when you intend to deliver a test notification. Flutter tests can be run from the app directory:

```shell
flutter test
flutter analyze
```

## Hardware Design and Simulation

- Open `PCB design/WaterQualityMonitor/WaterQualityMonitor.kicad_pro` in KiCad for the PCB project. Individual sheets divide the design into power, MCU, sensors, GSM, and indicators. Fabrication outputs are in `PCB design/WaterQualityMonitor/Gerbers/`.
- Open `proteus/System Simulation.pdsprj` in Proteus to inspect the circuit simulation project.
- KiCad backup and local project-state files are not part of the normal design deliverables. Review generated outputs before committing them.

## Notes and Limitations

- The mobile dashboard and latest-reading endpoint are configured for one target device by default.
- Firebase Realtime Database is not the telemetry source in the current app flow; readings are fetched from the Node.js API backed by MongoDB.
- Firmware threshold and sensor-calibration values are implementation settings, not a regulatory certification or proof of water potability.
- The backend currently exposes its API routes without authentication. Treat the included service as a development/prototype baseline until access control, validation, deployment secrets, and HTTPS are reviewed for your deployment.