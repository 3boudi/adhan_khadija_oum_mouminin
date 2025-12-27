import 'package:flutter/material.dart';
import './pages/home/home.dart';
import './services/notification_service.dart';
import './utils/permission_handler.dart' as perm_handler;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // طلب الأذونات
  await perm_handler.PermissionHandler.requestLocationPermission();
  await perm_handler.PermissionHandler.requestNotificationPermission();

  // تهيئة خدمة الإشعارات
  await NotificationService().initialize();

  runApp(
    MaterialApp(
      home: const Home(),
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
    ),
  );
}
