import 'dart:async';
import 'package:flutter/material.dart';
import 'package:arabic_font/arabic_font.dart';

class NextPrayerWidget extends StatefulWidget {
  final String prayerName;
  final DateTime prayerTime;
  final Duration remainingTime;

  const NextPrayerWidget({
    super.key,
    required this.prayerName,
    required this.prayerTime,
    required this.remainingTime,
  });

  @override
  State<NextPrayerWidget> createState() => _NextPrayerWidgetState();
}

class _NextPrayerWidgetState extends State<NextPrayerWidget> {
  late Duration _remainingTime;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.remainingTime;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        setState(() {
          _remainingTime = _remainingTime - const Duration(seconds: 1);
        });
      } else {
        timer.cancel();
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color.fromARGB(255, 4, 79, 27),
            width: 4,
          )),
      child: Column(
        children: [
          Text(
            'الصلاة القادمة',
            style: ArabicTextStyle(
              arabicFont: ArabicFont.dinNextLTArabic,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 4, 79, 27),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.prayerName,
            style: ArabicTextStyle(
              arabicFont: ArabicFont.dinNextLTArabic,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 4, 79, 27),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '-${_formatDuration(_remainingTime)}',
            style: ArabicTextStyle(
              arabicFont: ArabicFont.dinNextLTArabic,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 4, 79, 27),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.prayerTime.hour}:${widget.prayerTime.minute.toString().padLeft(2, '0')}',
            style: ArabicTextStyle(
              arabicFont: ArabicFont.dinNextLTArabic,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 4, 79, 27),
            ),
          ),
        ],
      ),
    );
  }
}
