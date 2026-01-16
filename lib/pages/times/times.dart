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
      await _prayerTimesService.initialize(position);

      final allPrayerTimes = _prayerTimesService.getAllPrayerTimes();
      final nextPrayer = _prayerTimesService.getNextPrayer();

      return {
        'allPrayerTimes': allPrayerTimes,
        'nextPrayer': nextPrayer,
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
                child: Text(
                  'خطأ: ${snapshot.error}',
                  style:
                      ArabicTextStyle(arabicFont: ArabicFont.dinNextLTArabic),
                ),
              );
            }

            final data = snapshot.data!;
            final allPrayerTimes =
                data['allPrayerTimes'] as Map<String, DateTime>;
            final nextPrayer = data['nextPrayer'] as Map<String, dynamic>;

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // still okay
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
            );
          },
        ),
      ),
    );
  }
}
