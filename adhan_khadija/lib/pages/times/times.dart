import 'package:flutter/material.dart';
import 'package:arabic_font/arabic_font.dart';

class Times extends StatelessWidget {
  const Times({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'صفحة الأوقات',
          style: ArabicTextStyle(arabicFont: ArabicFont.dinNextLTArabic),
        ),
      ),
    );
  }
}
