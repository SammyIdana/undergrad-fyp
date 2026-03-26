import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/water_data.dart';
import '../firebase_options.dart';

final waterDataProvider = StreamProvider<WaterData>((ref) async* {
  // Ensure Firebase is initialized before accessing the database
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  try {
    final dbRef = FirebaseDatabase.instance.ref().child('waterData');
    await for (final event in dbRef.onValue) {
      final data = event.snapshot.value;
      if (data != null && data is Map<dynamic, dynamic>) {
        yield WaterData.fromJson(data);
      } else {
        yield WaterData(
          ph: 0.0,
          tds: 0.0,
          turbidity: 0.0,
          temperature: 0.0,
          status: 'WAITING',
          timestamp: DateTime.now(),
        );
      }
    }
  } catch (e) {
    debugPrint('Firebase not configured, using mock data.');
    yield* Stream.periodic(const Duration(seconds: 3), (count) {
      double ph = 7.0 + (count % 3) * 0.2;
      double tds = 300.0 + (count * 10);
      double temp = 25.0 + (count % 2);
      String status = 'SAFE';
      if (tds > 400) status = 'CAUTION';
      if (tds > 500) status = 'LIMITED USE';
      if (tds > 600) status = 'DANGEROUS';
      return WaterData(
        ph: ph,
        tds: tds,
        turbidity: 1.0,
        temperature: temp,
        status: status,
        timestamp: DateTime.now(),
      );
    });
  }
});
