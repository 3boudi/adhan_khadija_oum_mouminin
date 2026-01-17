import 'package:flutter/material.dart';
import 'package:arabic_font/arabic_font.dart';
import 'package:animated_analog_clock/animated_analog_clock.dart';
import '../../services/location_service.dart';
import '../../services/prayer_times_service.dart';
import '../../widgets/next_prayer_widget.dart';
import 'package:lottie/lottie.dart';

class LocationTime extends StatefulWidget {
  const LocationTime({super.key});

  @override
  State<LocationTime> createState() => _LocationTimeState();
}

class _LocationTimeState extends State<LocationTime> {
  late Future<Map<String, dynamic>> _prayerData;
  late PrayerTimesService _prayerTimesService;
  late LocationService _locationService;

  @override
  void initState() {
    super.initState();
    _locationService = LocationService();
    _prayerTimesService = PrayerTimesService();
    _prayerData = _getPrayerData();
  }

  Future<Map<String, dynamic>> _getPrayerData() async {
    try {
      final position = await _locationService.getCurrentLocation();
      final locationName = await _locationService.getLocationName(
        position.latitude,
        position.longitude,
      );

      final initResult = await _prayerTimesService.initializeWithLocationName(
          position, locationName);

      final nextPrayer = _prayerTimesService.getNextPrayer();
      final networkStatus = await _prayerTimesService.getNetworkStatus();

      return {
        'locationName': initResult['locationName'],
        'nextPrayer': nextPrayer,
        'position': position,
        'isFromCache': initResult['isFromCache'] ?? false,
        'isOnline': networkStatus['isOnline'],
        'lastUpdate': initResult['lastUpdate'],
      };
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _prayerData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: ColorFiltered(
              colorFilter: const ColorFilter.mode(
                  Color.fromARGB(255, 24, 84, 0), BlendMode.srcATop),
              child: Lottie.asset(
                'assets/lottie/loading.json',
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Color.fromARGB(255, 24, 84, 0),
                      size: 60,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _prayerData = _getPrayerData();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 24, 84, 0),
                      ),
                      child: const Text(
                        'إعادة المحاولة',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final data = snapshot.data!;
        final locationName = data['locationName'] as String;
        final nextPrayer = data['nextPrayer'] as Map<String, dynamic>;
        final isFromCache = data['isFromCache'] as bool;
        final isOnline = data['isOnline'] as bool;

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _prayerData = _getPrayerData();
            });
            await _prayerData;
          },
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 50),
              // Status indicator
              if (isFromCache)
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isOnline ? Icons.cached : Icons.cloud_off,
                        color: Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isOnline ? 'البيانات محفوظة محلياً' : 'وضع عدم الاتصال',
                        style: ArabicTextStyle(
                          arabicFont: ArabicFont.dinNextLTArabic,
                          fontSize: 12,
                          color: Colors.orange[800],
                        ),
                      ),
                    ],
                  ),
                ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Color.fromARGB(255, 24, 84, 0),
                      size: 35,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      locationName,
                      style: ArabicTextStyle(
                        arabicFont: ArabicFont.dinNextLTArabic,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 24, 84, 0),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'assets/mosque.png',
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    const AnimatedAnalogClock(
                      location: null,
                      size: 300,
                      backgroundColor: Colors.transparent,
                      hourHandColor: Color(0xFF7a6200),
                      minuteHandColor: Color(0xFF7a6200),
                      secondHandColor: Colors.amber,
                      centerDotColor: Color.fromARGB(255, 4, 79, 27),
                      hourDashColor: Color.fromARGB(255, 255, 221, 0),
                      minuteDashColor: Color.fromARGB(255, 4, 79, 27),
                      extendHourHand: true,
                      extendMinuteHand: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: NextPrayerWidget(
                  prayerName: nextPrayer['name'],
                  prayerTime: nextPrayer['time'],
                  remainingTime: nextPrayer['remaining'],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
