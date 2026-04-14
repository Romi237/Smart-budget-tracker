// lib/services/sensor_service.dart
// Accelerometer sensor integration — detects device shake to refresh transactions.

import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class SensorService {
  static StreamSubscription<AccelerometerEvent>? _subscription;
  static const double _shakeThreshold = 15.0;
  static DateTime? _lastShake;

  /// Starts listening to the accelerometer.
  /// [onShake] is called when a shake gesture is detected.
  static void startListening({required VoidCallback onShake}) {
    _subscription?.cancel();
    _subscription = accelerometerEventStream().listen((event) {
      final magnitude = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );

      if (magnitude > _shakeThreshold) {
        final now = DateTime.now();
        if (_lastShake == null ||
            now.difference(_lastShake!) > const Duration(seconds: 2)) {
          _lastShake = now;
          onShake();
        }
      }
    });
  }

  /// Stops the accelerometer listener.
  static void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }
}

// Typedef to avoid importing foundation just for VoidCallback
typedef VoidCallback = void Function();
