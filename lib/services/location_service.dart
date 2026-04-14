// lib/services/location_service.dart
// GPS sensor integration — reads device location and tags transactions.

import 'package:geolocator/geolocator.dart';

class LocationService {
  static Position? _lastKnownPosition;

  /// Requests permission and fetches current GPS coordinates.
  /// Returns null if permission is denied or GPS is unavailable.
  static Future<Position?> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 8),
      );
      _lastKnownPosition = position;
      return position;
    } catch (_) {
      return _lastKnownPosition;
    }
  }

  /// Returns a formatted location string from lat/lng.
  static String formatCoordinates(double lat, double lng) {
    final latDir = lat >= 0 ? 'N' : 'S';
    final lngDir = lng >= 0 ? 'E' : 'W';
    return '${lat.abs().toStringAsFixed(4)}° $latDir, ${lng.abs().toStringAsFixed(4)}° $lngDir';
  }

  /// Returns the last known position without making a new request.
  static Position? get lastKnownPosition => _lastKnownPosition;
}
