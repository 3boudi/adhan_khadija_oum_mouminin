import 'package:flutter/material.dart';
import 'package:arabic_font/arabic_font.dart';
import '../../services/location_service.dart';
import '../../services/prayer_times_service.dart';
import '../../widgets/prayer_time_card.dart';
import 'package:lottie/lottie.dart';

class Times extends StatefulWidget {
  const Times({super.key});

  @override
  State<Times> createState() => _TimesState();
}

class _TimesState extends State<Times> {
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

      final allPrayerTimes = _prayerTimesService.getAllPrayerTimes();
      final nextPrayer = _prayerTimesService.getNextPrayer();
      final networkStatus = await _prayerTimesService.getNetworkStatus();

      return {
        'allPrayerTimes': allPrayerTimes,
        'nextPrayer': nextPrayer,
        'isFromCache': initResult['isFromCache'] ?? false,
        'isOnline': networkStatus['isOnline'],
        'lastUpdate': initResult['lastUpdate'],
      };
    } catch (e) {
      throw Exception('فشل في الحصول على البيانات: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl, // <-- This makes everything RTL
        child: FutureBuilder<Map<String, dynamic>>(
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
                          'خطأ: ${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: ArabicTextStyle(
                            arabicFont: ArabicFont.dinNextLTArabic,
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
                            backgroundColor:
                                const Color.fromARGB(255, 24, 84, 0),
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
            final allPrayerTimes =
                data['allPrayerTimes'] as Map<String, DateTime>;
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
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'أوقات الصلاة',
                          style: ArabicTextStyle(
                            arabicFont: ArabicFont.dinNextLTArabic,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 24, 84, 0),
                          ),
                        ),
                        // Status indicator
                        if (isFromCache)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: Colors.orange, width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isOnline ? Icons.cached : Icons.cloud_off,
                                  color: Colors.orange,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isOnline ? 'محفوظ' : 'غير متصل',
                                  style: ArabicTextStyle(
                                    arabicFont: ArabicFont.dinNextLTArabic,
                                    fontSize: 10,
                                    color: Colors.orange[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView(
                        children: allPrayerTimes.entries.map((entry) {
                          final prayerTime = entry.value;
                          final formattedTime =
                              '${prayerTime.hour}:${prayerTime.minute.toString().padLeft(2, '0')}';

                          return PrayerTimeCard(
                            prayerName: entry.key,
                            prayerTime: formattedTime,
                            isCurrent: entry.key == nextPrayer['name'],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
