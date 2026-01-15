import 'package:flutter/material.dart';
import 'package:arabic_font/arabic_font.dart';

class PrayerTimeCard extends StatelessWidget {
  final String prayerName;
  final String prayerTime;
  final bool isCurrent;

  const PrayerTimeCard({
    super.key,
    required this.prayerName,
    required this.prayerTime,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrent
            ? const Color.fromARGB(255, 24, 84, 0).withValues(alpha: 0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent
              ? const Color.fromARGB(255, 24, 84, 0)
              : Colors.grey.shade300,
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            prayerName,
            style: ArabicTextStyle(
              arabicFont: ArabicFont.dinNextLTArabic,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isCurrent
                  ? const Color.fromARGB(255, 24, 84, 0)
                  : Colors.black,
            ),
          ),
          Text(
            prayerTime,
            style: ArabicTextStyle(
              arabicFont: ArabicFont.dinNextLTArabic,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isCurrent
                  ? const Color.fromARGB(255, 24, 84, 0)
                  : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
