import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'notification_service.dart';
import 'connectivity_service.dart';

class PrayerTimesService {
  late PrayerTimes _prayerTimes;
  late Coordinates _coordinates;
  final NotificationService _notificationService = NotificationService();
  final ConnectivityService _connectivityService = ConnectivityService();

  // Keys for SharedPreferences
  static const String _keyPrayerTimes = 'cached_prayer_times';
  static const String _keyLastUpdate = 'last_update';
  static const String _keyLatitude = 'cached_latitude';
  static const String _keyLongitude = 'cached_longitude';
  static const String _keyLocationName = 'cached_location_name';

  Future<bool> _isOnline() async {
    return await _connectivityService.isOnline();
  }

  Future<void> _savePrayerTimesToCache(Map<String, DateTime> prayerTimes,
      double latitude, double longitude, String locationName) async {
    final prefs = await SharedPreferences.getInstance();

    // Convert DateTime to ISO string for storage
    final Map<String, String> prayerTimesStrings = {};
    for (var entry in prayerTimes.entries) {
      prayerTimesStrings[entry.key] = entry.value.toIso8601String();
    }

    await prefs.setString(_keyPrayerTimes, json.encode(prayerTimesStrings));
    await prefs.setString(_keyLastUpdate, DateTime.now().toIso8601String());
    await prefs.setDouble(_keyLatitude, latitude);
    await prefs.setDouble(_keyLongitude, longitude);
    await prefs.setString(_keyLocationName, locationName);
  }

  Future<Map<String, dynamic>?> _loadCachedPrayerTimes() async {
    final prefs = await SharedPreferences.getInstance();

    final String? prayerTimesJson = prefs.getString(_keyPrayerTimes);
    final String? lastUpdateString = prefs.getString(_keyLastUpdate);
    final double? latitude = prefs.getDouble(_keyLatitude);
    final double? longitude = prefs.getDouble(_keyLongitude);
    final String? locationName = prefs.getString(_keyLocationName);

    if (prayerTimesJson == null ||
        lastUpdateString == null ||
        latitude == null ||
        longitude == null ||
        locationName == null) {
      return null;
    }

    // Convert back to DateTime
    final Map<String, dynamic> prayerTimesData = json.decode(prayerTimesJson);
    final Map<String, DateTime> prayerTimes = {};

    for (var entry in prayerTimesData.entries) {
      prayerTimes[entry.key] = DateTime.parse(entry.value);
    }

    return {
      'prayerTimes': prayerTimes,
      'lastUpdate': DateTime.parse(lastUpdateString),
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
    };
  }

  Future<bool> _isCacheValid() async {
    final cachedData = await _loadCachedPrayerTimes();
    if (cachedData == null) return false;

    final DateTime lastUpdate = cachedData['lastUpdate'];
    final DateTime now = DateTime.now();

    // Cache is valid if it's from today
    return lastUpdate.year == now.year &&
        lastUpdate.month == now.month &&
        lastUpdate.day == now.day;
  }

  Future<void> initialize(Position position, [String? locationName]) async {
    _coordinates = Coordinates(position.latitude, position.longitude);

    final bool isOnline = await _isOnline();
    final bool cacheValid = await _isCacheValid();

    if (isOnline) {
      // Online: Calculate fresh prayer times
      final params = CalculationMethod.muslim_world_league.getParameters();
      params.madhab = Madhab.shafi;
      _prayerTimes = PrayerTimes.today(_coordinates, params);

      // Cache the fresh data
      if (locationName != null) {
        await _savePrayerTimesToCache(getAllPrayerTimes(), position.latitude,
            position.longitude, locationName);
      }

      // Schedule notifications for all prayer times
      await _scheduleAllNotifications();
    } else {
      // Offline: Try to load from cache
      if (cacheValid) {
        final cachedData = await _loadCachedPrayerTimes();
        if (cachedData != null) {
          // Use cached coordinates
          _coordinates =
              Coordinates(cachedData['latitude'], cachedData['longitude']);

          // Reconstruct PrayerTimes from cached data
          final params = CalculationMethod.muslim_world_league.getParameters();
          params.madhab = Madhab.shafi;
          _prayerTimes = PrayerTimes.today(_coordinates, params);

          return; // Successfully loaded from cache
        }
      }

      // If we reach here, no valid cache exists and we're offline
      throw Exception('لا يوجد اتصال بالإنترنت ولا توجد بيانات محفوظة مسبقاً');
    }
  }

  Future<Map<String, dynamic>> initializeWithLocationName(
      Position position, String locationName) async {
    await initialize(position, locationName);

    // Check if data came from cache
    final bool isOnline = await _isOnline();
    final cachedData = await _loadCachedPrayerTimes();

    return {
      'locationName': isOnline
          ? locationName
          : (cachedData?['locationName'] ?? locationName),
      'isFromCache': !isOnline && cachedData != null,
      'lastUpdate': cachedData?['lastUpdate'],
    };
  }

  Future<void> _scheduleAllNotifications() async {
    final todayPrayers = getAllPrayerTimes();
    final tomorrowPrayers = _getTomorrowPrayerTimes();

    // Combine today and tomorrow prayers
    final Map<String, DateTime> allPrayers = {};

    // Add today's remaining prayers
    final now = DateTime.now();
    for (var entry in todayPrayers.entries) {
      if (entry.value.isAfter(now)) {
        allPrayers[entry.key] = entry.value;
      }
    }

    // Add tomorrow's prayers with suffix to make keys unique
    for (var entry in tomorrowPrayers.entries) {
      allPrayers['${entry.key}_tomorrow'] = entry.value;
    }

    await _notificationService.scheduleAllPrayerNotifications(allPrayers);
  }

  Map<String, DateTime> _getTomorrowPrayerTimes() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final tomorrowParams =
        CalculationMethod.muslim_world_league.getParameters();
    tomorrowParams.madhab = Madhab.shafi;
    final tomorrowDateComponents =
        DateComponents(tomorrow.year, tomorrow.month, tomorrow.day);
    final tomorrowPrayerTimes =
        PrayerTimes(_coordinates, tomorrowDateComponents, tomorrowParams);

    return {
      'الفجر': tomorrowPrayerTimes.fajr,
      'الشروق': tomorrowPrayerTimes.sunrise,
      'الظهر': tomorrowPrayerTimes.dhuhr,
      'العصر': tomorrowPrayerTimes.asr,
      'المغرب': tomorrowPrayerTimes.maghrib,
      'العشاء': tomorrowPrayerTimes.isha,
    };
  }

  PrayerTimes get prayerTimes => _prayerTimes;

  Map<String, DateTime> getAllPrayerTimes() {
    return {
      'الفجر': _prayerTimes.fajr,
      'الشروق': _prayerTimes.sunrise,
      'الظهر': _prayerTimes.dhuhr,
      'العصر': _prayerTimes.asr,
      'المغرب': _prayerTimes.maghrib,
      'العشاء': _prayerTimes.isha,
    };
  }

  Map<String, dynamic> getNextPrayer() {
    final now = DateTime.now();
    final prayers = getAllPrayerTimes();

    for (var entry in prayers.entries) {
      if (entry.value.isAfter(now)) {
        return {
          'name': entry.key,
          'time': entry.value,
          'remaining': entry.value.difference(now),
        };
      }
    }

    // If no prayer found (it's after Isha), return Fajr of next day
    final tomorrow = DateTime.now().add(Duration(days: 1));
    final tomorrowParams =
        CalculationMethod.muslim_world_league.getParameters();
    tomorrowParams.madhab = Madhab.shafi;
    final tomorrowDateComponents =
        DateComponents(tomorrow.year, tomorrow.month, tomorrow.day);
    final tomorrowPrayerTimes =
        PrayerTimes(_coordinates, tomorrowDateComponents, tomorrowParams);

    return {
      'name': 'الفجر',
      'time': tomorrowPrayerTimes.fajr,
      'remaining': tomorrowPrayerTimes.fajr.difference(now),
    };
  }

  Future<Map<String, dynamic>> getNetworkStatus() async {
    final isOnline = await _isOnline();
    final cachedData = await _loadCachedPrayerTimes();

    return {
      'isOnline': isOnline,
      'hasCachedData': cachedData != null,
      'lastUpdate': cachedData?['lastUpdate'],
    };
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPrayerTimes);
    await prefs.remove(_keyLastUpdate);
    await prefs.remove(_keyLatitude);
    await prefs.remove(_keyLongitude);
    await prefs.remove(_keyLocationName);
  }

  Future<bool> hasCachedData() async {
    final cachedData = await _loadCachedPrayerTimes();
    return cachedData != null;
  }
}
