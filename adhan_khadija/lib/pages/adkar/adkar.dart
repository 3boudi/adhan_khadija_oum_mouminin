import 'package:flutter/material.dart';
import 'package:arabic_font/arabic_font.dart';
import '../../services/notification_service.dart';

class Adkar extends StatelessWidget {
  const Adkar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'صفحة الأذكار',
              style: ArabicTextStyle(
                arabicFont: ArabicFont.dinNextLTArabic,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 24, 84, 0),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () async {
                final notificationService = NotificationService();
                await notificationService.initialize();
                await notificationService.showTestAdhanNotification();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم إرسال إشعار اختبار الأذان'),
                    backgroundColor: Color.fromARGB(255, 24, 84, 0),
                  ),
                );
              },
              icon: const Icon(Icons.notifications_active, size: 28),
              label: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'اختبار صوت الأذان',
                  style: ArabicTextStyle(
                    arabicFont: ArabicFont.dinNextLTArabic,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 24, 84, 0),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
