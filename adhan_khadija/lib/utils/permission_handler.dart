import 'package:permission_handler/permission_handler.dart';

class PermissionHandler {
  static Future<bool> requestLocationPermission() async {
    var status = await Permission.location.request();
    return status.isGranted;
  }

  static Future<bool> requestNotificationPermission() async {
    var status = await Permission.notification.request();
    return status.isGranted;
  }

  static Future<bool> areAllPermissionsGranted() async {
    var locationStatus = await Permission.location.status;
    var notificationStatus = await Permission.notification.status;
    return locationStatus.isGranted && notificationStatus.isGranted;
  }
}
