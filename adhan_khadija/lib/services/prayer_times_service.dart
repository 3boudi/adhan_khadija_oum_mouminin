import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'notification_service.dart';

class PrayerTimesService {
  late PrayerTimes _prayerTimes;
  late Coordinates _coordinates;
  final NotificationService _notificationService = NotificationService();

  Future<void> initialize(Position position) async {
    _coordinates = Coordinates(position.latitude, position.longitude);
    final params = CalculationMethod.muslim_world_league.getParameters();
    params.madhab = Madhab.shafi;
    _prayerTimes = PrayerTimes.today(_coordinates, params);

    // Schedule notifications for all prayer times - works even when app is closed
    await _scheduleAllNotifications();
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
}
