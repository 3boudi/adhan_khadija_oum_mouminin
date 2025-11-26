import 'package:flutter/material.dart';
import 'package:arabic_font/arabic_font.dart';
import 'package:animated_analog_clock/animated_analog_clock.dart';

class LocationTime extends StatefulWidget {
  const LocationTime({super.key});

  @override
  State<LocationTime> createState() => _LocationTimeState();
}

class _LocationTimeState extends State<LocationTime> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(height: 90),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.location_on,
                  color: Color.fromARGB(255, 24, 84, 0),
                  size: 35,
                ),
                SizedBox(width: 8),
                Text(
                  'قايس خنشلة',
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

          const SizedBox(height: 30),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // صورة الخلفية
                Image.asset(
                  'assets/mosque.png', // مسار الصورة
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),

                // الساعة فوق الصورة
                const AnimatedAnalogClock(
                  location: null,
                  size: 300,
                  backgroundColor: Colors.transparent, // مهم جداً
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
        ],
      ),
    );
  }
}
