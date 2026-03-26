# IoT Water Quality Monitoring App

A complete Flutter application for an IoT-based water quality monitoring system. The app interfaces with Firebase Realtime Database and Firebase Cloud Messaging to provide real-time updates and push notifications.

## Features
- **Real-Time Dashboard**: Displays real-time values of pH, TDS, Turbidity, and Temperature without needing to refresh.
- **Status Classification & Recommendation**: Automatically evaluates the safety level (`SAFE`, `CAUTION`, `LIMITED USE`, `DANGEROUS`) and provides recommendations on water usability.
- **Historical Data Visualization**: Interactive line charts using `fl_chart` to view chronological history over the active session.
- **Push Notifications**: Integrated Firebase Cloud Messaging (FCM) to receive alerts when the water status reaches critical levels.

## Setup Instructions

### Prerequisites
- Install [Flutter SDK](https://docs.flutter.dev/get-started/install) (Ensure it's the latest stable version).
- Set up a [Firebase Project](https://console.firebase.google.com/).

### 1. Firebase Configuration (Mandatory)
Since this app relies on Firebase Services, you must configure it for your target platforms (Android/iOS):
1. **Option 1 (Recommended)**: Use [FlutterFire CLI](https://firebase.google.com/docs/flutter/setup). 
   - Run `dart pub global activate flutterfire_cli`.
   - Run `flutterfire configure` in the project root and select your Firebase app. This automatically creates `lib/firebase_options.dart`.
2. **Option 2 (Manual)**: 
   - For Android: Download `google-services.json` from the Firebase Console and place it in `android/app/`.
   - For iOS: Download `GoogleService-Info.plist` from the Firebase Console and place it in `ios/Runner/`.

If using Option 1, replace `await Firebase.initializeApp();` in `firebase_service.dart` with:
```dart
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
```

### 2. Firebase Database Rules & Structure
Make sure your Realtime Database contains a schema like this under the `waterData` node:
```json
{
  "waterData": {
    "pH": 7.2,
    "TDS": 320,
    "turbidity": 2.1,
    "temperature": 25,
    "status": "SAFE",
    "timestamp": "2026-03-25T10:00:00Z"
  }
}
```

Make sure the read rules are appropriately defined in Firebase Console:
```json
{
  "rules": {
    ".read": "auth != null" // or true for public testing
  }
}
```

### 3. Running the App
1. Navigate to the project directory:
   ```bash
   cd water_monitor_app
   ```
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run on a connected device/emulator:
   ```bash
   flutter run
   ```

## Dependencies
- `firebase_core`: Required to connect the application to the Firebase backend.
- `firebase_database`: Access Firebase Realtime Database.
- `firebase_messaging`: Receive FCM push notifications.
- `flutter_riverpod`: Riverpod for reactive state management.
- `fl_chart`: For generating the interactive chart views.
