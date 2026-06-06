
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
└── water-quality-monitoring-app/   # Flutter cross-platform mobile application
    ├── lib/
    ├── android/
    └── pubspec.yaml

```

---

## 📱 Mobile Application Features

* **Real-Time Dashboard**: Displays instantaneous values for pH, TDS, Turbidity, and Temperature fed directly from the monitoring hardware via Firebase.
* **Status Classification & Recommendation**: Automatically evaluates safety indices (`SAFE`, `CAUTION`, `LIMITED USE`, `UNSAFE`) and yields clear, context-aware water usability actions.
* **Historical Data Visualization**: Renders interactive trend timelines over the active session utilizing `fl_chart`.
* **Push Notifications**: Integrated via Firebase Cloud Messaging (FCM) to trigger high-priority alerts on mobile devices the moment parameter anomalies cross critical safety thresholds.
* **Robust State Architecture**: Powered by Riverpod for reactive state caching and real-time database stream synchronization.

---

## 🛠️ Project Setup Instructions

### Prerequisites

* Install the [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable version).
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

```

```