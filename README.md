
# IoT Water Quality Monitoring System

A comprehensive engineering system containing both the hardware data-ingestion backend and a cross-platform mobile application. This repository is structured as a monorepo to cleanly separate the system architecture into frontend and backend workspaces.

## Repository Architecture
```text
undergrad-fyp/ (Main Repository Root)
│
├── iot backend/                    # Node.js data ingestion & alerting backend
│   ├── server.js
│   └── package.json
│
├── firmware/                       # Microcontroller firmware
│   └── firmware/firmware.ino
│
├── PCB design/                     # KiCad schematics, PCB, and Gerber files
* Install [Node.js](https://nodejs.org/) for the backend service.
│   └── WaterQualityMonitor/
* Create a MongoDB Atlas database for telemetry and alert history.
│
├── proteus/                        # Proteus system simulation
│
└── water-quality-monitoring-app/   # Flutter cross-platform mobile application
    ├── lib/
    ├── android/
    └── pubspec.yaml
The mobile app uses Firebase Cloud Messaging for push notifications and the generated FlutterFire configuration for platform credentials. From the app directory:

* **Robust State Architecture**: Powered by Riverpod for reactive state caching and real-time database stream synchronization.

---

## 🛠️ Project Setup Instructions

### Prerequisites

3. The CLI updates `lib/firebase_options.dart` and the native Firebase configuration files. The app initializes Firebase through `lib/services/firebase_service.dart`; no additional initialization code is required.

### 3. Backend Firebase and Environment Configuration

The backend uses Firebase Admin SDK to send push notifications. Place the Firebase Admin SDK service-account JSON at `iot backend/firebase-service-account.json` and keep it private. Do not commit it or paste its contents into the README.

Create `iot backend/.env` with:

```dotenv
MONGO_URI=mongodb+srv://<username>:<password>@<cluster>/<database>
PORT=5000
LOCAL_TIMEZONE=Etc/UTC
```

Install and start the backend:

```bash
cd "iot backend"
npm install
npm start
```

### 4. Firebase Database Structure & Security Rules

Ensure your Realtime Database contains a validated structural pattern under the `waterData` key:

```json
{
  "waterData": {
    "pH": 7.2,
    "TDS": 320,
    "turbidity": 2.1,
    "temperature": 25.0,
    "status": "SAFE",
    "timestamp": "2026-06-06T15:30:00Z"
  }
}
```

Use authenticated access in development and production. Do not deploy public read/write rules:

```json
{
  "rules": {
    ".read": "auth != null",
    ".write": "auth != null"
  }
}
```

### 5. Running the App Locally

```bash
<!--
The following example is retained as a quick reference for direct Firebase initialization.
-->
```dart
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

* Set up a project environment in the [Firebase Console](https://console.firebase.google.com/).

### 1. Navigating to the Target Module

Because this project utilizes a monorepo structure, always jump out of the main root folder and into the frontend app workspace before running your code:

```bash
cd water-quality-monitoring-app

```

### 2. Firebase Configuration

The mobile system relies on cloud-synced infrastructure. Configure your environment using the FlutterFire CLI:

1. Globally activate the CLI runner:
```bash
dart pub global activate flutterfire_cli

```


2. Configure your project environment in the app directory root:
```bash
flutterfire configure

```


3. Ensure initialization in your `main.dart` or database service passes the generated platform abstractions:
```dart
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

```



### 3. Firebase Database Structure & Security Rules

Ensure your Realtime Database contains a validated structural pattern parsing coordinates directly under the `waterData` key:

```json
{
  "waterData": {
    "pH": 7.2,
    "TDS": 320,
    "turbidity": 2.1,
    "temperature": 25.0,
    "status": "SAFE",
    "timestamp": "2026-06-06T15:30:00Z"
  }
}

```

For development staging and deployment assertions, update your database rules in the Firebase console:

```json
{
  "rules": {
    ".read": "true",
    ".write": "auth != null" 
  }
}

```

### 4. Running the App Locally

```bash
# Fetch core pub dependencies
flutter pub get

# Launch compiling and execution processes 
flutter run

```

---

## 📦 Core Architecture Dependencies

* `flutter_riverpod`: Local state synchronization and dependency injection.
* `firebase_core` & `firebase_database`: Primary pipeline connection to real-time database points.
* `firebase_messaging`: Background device token interceptors for instant safety notification delivery.
* `fl_chart`: High-performance canvas chart renderers for parameter trend history sheets.

---

## Version-Control Notes

KiCad's generated `WaterQualityMonitor-backups` directory is excluded from version control. Only the working schematics and PCB design files should be committed.
