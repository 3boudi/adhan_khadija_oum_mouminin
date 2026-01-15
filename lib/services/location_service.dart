import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location service is enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Prompt user to enable location services
      await Geolocator.openLocationSettings();
      throw Exception('يرجى تفعيل خدمات الموقع من الإعدادات');
    }

    // Check location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('يرجى السماح بالوصول إلى الموقع الجغرافي');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Open app settings for user to manually enable permission
      await Geolocator.openAppSettings();
      throw Exception('يرجى تفعيل إذن الموقع من إعدادات التطبيق');
    }

    // Get current position
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } catch (e) {
      throw Exception('فشل في الحصول على الموقع الحالي: ${e.toString()}');
    }
  }

  Future<String> getLocationName(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return place.locality ??
            place.subAdministrativeArea ??
            place.administrativeArea ??
            "Unknown";
      }
      return 'موقع غير معروف';
    } catch (e) {
      return 'موقع غير معروف';
    }
  }
}
