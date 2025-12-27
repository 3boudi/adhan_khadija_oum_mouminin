import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';

// Audio handler for background playback
class AdhanAudioHandler extends BaseAudioHandler {
  final _player = AudioPlayer();
  bool _shouldKeepPlaying = false;

  AdhanAudioHandler() {
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    // Set up audio attributes for alarm
    await _player.setAndroidAudioAttributes(
      const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.music,
        usage: AndroidAudioUsage.alarm,
        flags: AndroidAudioFlags.audibilityEnforced,
      ),
    );

    // Monitor playing state and force resume if paused unexpectedly
    _player.playingStream.listen((isPlaying) {
      if (!isPlaying && _shouldKeepPlaying) {
        final state = _player.processingState;
        if (state != ProcessingState.completed &&
            state != ProcessingState.idle) {
          Future.delayed(const Duration(milliseconds: 50), () {
            if (_shouldKeepPlaying) {
              _player.play();
            }
          });
        }
      }
    });

    // When audio completes, stop keeping it playing
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _shouldKeepPlaying = false;
        playbackState.add(playbackState.value.copyWith(
          processingState: AudioProcessingState.completed,
          playing: false,
        ));
      }
    });
  }

  Future<void> playAdhan() async {
    _shouldKeepPlaying = true;

    await _player.setAsset('assets/audio/adhan.mp3');

    playbackState.add(playbackState.value.copyWith(
      controls: [MediaControl.stop],
      processingState: AudioProcessingState.ready,
      playing: true,
    ));

    await _player.play();
  }

  @override
  Future<void> stop() async {
    _shouldKeepPlaying = false;
    await _player.stop();
    playbackState.add(playbackState.value.copyWith(
      processingState: AudioProcessingState.idle,
      playing: false,
    ));
  }

  Future<void> dispose() async {
    _shouldKeepPlaying = false;
    await _player.dispose();
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  static AdhanAudioHandler? _audioHandler;
  static AudioPlayer? _fallbackPlayer;
  static bool _shouldKeepPlaying = false;

  Future<void> initialize() async {
    tz.initializeTimeZones();

    // Get the local timezone
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/notification_icon');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Request notification permission for Android 13+
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Request exact alarm permission for Android 12+
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();

    // Initialize audio service handler with error handling
    try {
      _audioHandler = await AudioService.init(
        builder: () => AdhanAudioHandler(),
        config: AudioServiceConfig(
          androidNotificationChannelId: 'com.adhan.khadija.audio',
          androidNotificationChannelName: 'الأذان',
          androidNotificationOngoing: true,
          androidStopForegroundOnPause: false,
        ),
      );
    } catch (e) {
      print('Error initializing audio service: $e');
      // Continue without audio service - will use fallback
    }
  }

  static void _onNotificationResponse(NotificationResponse response) {
    // Handle notification tap or action
    if (response.actionId == 'stop_adhan') {
      stopAdhan();
      NotificationService()._cancelNotificationById(response.id ?? 0);
    }
  }

  Future<void> _cancelNotificationById(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  // Fallback player for when AudioService is not available
  static Future<void> _playWithFallback() async {
    try {
      _shouldKeepPlaying = true;
      await _fallbackPlayer?.dispose();
      _fallbackPlayer = AudioPlayer();

      // Set audio attributes for alarm
      await _fallbackPlayer!.setAndroidAudioAttributes(
        const AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          usage: AndroidAudioUsage.alarm,
          flags: AndroidAudioFlags.audibilityEnforced,
        ),
      );

      await _fallbackPlayer!.setAsset('assets/audio/adhan.mp3');

      // Monitor and auto-resume if paused
      _fallbackPlayer!.playingStream.listen((isPlaying) {
        if (!isPlaying && _shouldKeepPlaying && _fallbackPlayer != null) {
          final state = _fallbackPlayer!.processingState;
          if (state != ProcessingState.completed &&
              state != ProcessingState.idle) {
            Future.delayed(const Duration(milliseconds: 50), () {
              if (_shouldKeepPlaying && _fallbackPlayer != null) {
                _fallbackPlayer!.play();
              }
            });
          }
        }
      });

      _fallbackPlayer!.processingStateStream.listen((state) {
        if (state == ProcessingState.completed) {
          _shouldKeepPlaying = false;
        }
      });

      await _fallbackPlayer!.play();
    } catch (e) {
      print('Error playing with fallback: $e');
    }
  }

  // Play adhan sound using audio_service for background playback
  static Future<void> _playAdhanSound() async {
    try {
      if (_audioHandler != null) {
        await _audioHandler!.playAdhan();
      } else {
        await _playWithFallback();
      }
    } catch (e) {
      print('Error playing adhan: $e');
      // Try fallback
      await _playWithFallback();
    }
  }

  // Stop adhan sound
  static Future<void> stopAdhan() async {
    try {
      _shouldKeepPlaying = false;
      await _audioHandler?.stop();
      await _fallbackPlayer?.stop();
      await _fallbackPlayer?.dispose();
      _fallbackPlayer = null;
    } catch (e) {
      print('Error stopping adhan: $e');
    }
  }

  // Schedule prayer notification with adhan sound - works when app is closed
  Future<void> schedulePrayerNotification(
    String prayerName,
    DateTime prayerTime,
    int notificationId,
  ) async {
    // Don't schedule if time has passed
    if (prayerTime.isBefore(DateTime.now())) {
      return;
    }

    final tz.TZDateTime scheduledTime = tz.TZDateTime.from(
      prayerTime,
      tz.local,
    );

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'prayer_times_channel',
      'مواقيت الصلاة',
      channelDescription: 'إشعارات مواقيت الصلاة',
      importance: Importance.max,
      priority: Priority.high,
      sound: const RawResourceAndroidNotificationSound('adhan'),
      playSound: true,
      enableVibration: true,
      color: const Color.fromARGB(255, 0, 78, 3),
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      ongoing: true,
      autoCancel: false,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      actions: const <AndroidNotificationAction>[
        AndroidNotificationAction(
          'stop_adhan',
          'إيقاف الأذان',
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ],
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      'حان وقت صلاة $prayerName',
      'اللهم صل وسلم على سيدنا محمد',
      scheduledTime,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: null,
    );
  }

  // Schedule all prayer notifications for today and tomorrow
  Future<void> scheduleAllPrayerNotifications(
      Map<String, DateTime> prayers) async {
    // Cancel all existing notifications first
    await cancelAllNotifications();

    int id = 0;
    for (var entry in prayers.entries) {
      // Skip Sunrise (الشروق) - no adhan for sunrise
      if (entry.key == 'الشروق') continue;

      await schedulePrayerNotification(entry.key, entry.value, id);
      id++;
    }
  }

  // Show prayer notification immediately with adhan sound
  Future<void> showPrayerNotification(String prayerName) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'prayer_times_channel',
      'مواقيت الصلاة',
      channelDescription: 'إشعارات مواقيت الصلاة',
      importance: Importance.max,
      priority: Priority.high,
      sound: const RawResourceAndroidNotificationSound('adhan'),
      playSound: true,
      enableVibration: true,
      color: const Color.fromARGB(255, 0, 78, 3),
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      ongoing: true,
      autoCancel: false,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      actions: const <AndroidNotificationAction>[
        AndroidNotificationAction(
          'stop_adhan',
          'إيقاف الأذان',
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ],
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      prayerName.hashCode,
      'حان وقت صلاة $prayerName',
      'اللهم صل وسلم على سيدنا محمد',
      platformChannelSpecifics,
    );
  }

  // Test notification with adhan sound immediately
  Future<void> showTestAdhanNotification() async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'adhan_test_channel',
      'اختبار الأذان',
      channelDescription: 'قناة اختبار صوت الأذان',
      importance: Importance.max,
      priority: Priority.high,
      sound: const RawResourceAndroidNotificationSound('adhan'),
      playSound: true,
      enableVibration: true,
      color: const Color.fromARGB(255, 0, 78, 3),
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      ongoing: true,
      autoCancel: false,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      actions: const <AndroidNotificationAction>[
        AndroidNotificationAction(
          'stop_adhan',
          'إيقاف الأذان',
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ],
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      999,
      'اختبار الأذان',
      'الله أكبر الله أكبر - اشهد ان لا اله الا الله',
      platformChannelSpecifics,
    );
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    await stopAdhan();
  }
}
