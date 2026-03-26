import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/water_data.dart';
import 'water_data_provider.dart';

class HistoryNotifier extends Notifier<List<WaterData>> {
  @override
  List<WaterData> build() {
    // Listen to real-time data and append it to the history list
    ref.listen<AsyncValue<WaterData>>(
      waterDataProvider,
      (previous, next) {
        if (next.value != null && next.value!.status != 'WAITING') {
          // Add only if it's new timestamp or list is empty to prevent spam
          final newEntry = next.value!;
          if (state.isEmpty || state.last.timestamp != newEntry.timestamp) {
            state = [...state, newEntry];
          }
        }
      },
    );
    return [];
  }
}

final historyProvider = NotifierProvider<HistoryNotifier, List<WaterData>>(
  () => HistoryNotifier(),
);
