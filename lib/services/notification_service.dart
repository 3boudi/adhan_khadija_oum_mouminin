import 'dart:typed_data';
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
  bool _isInitialized = false;

  AdhanAudioHandler() {
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    if (_isInitialized) return;

    try {
      // Configure audio session to behave like an ALARM - not music
      final session = await AudioSession.instance;
      await session.configure(AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.duckOthers,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        avAudioSessionRouteSharingPolicy:
            AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
        androidAudioAttributes: const AndroidAudioAttributes(
          contentType: AndroidAudioContentType.sonification,
          usage: AndroidAudioUsage.alarm, // CRITICAL: Must be alarm
          flags: AndroidAudioFlags.audibilityEnforced,
        ),
        androidAudioFocusGainType:
            AndroidAudioFocusGainType.gain, // Changed to GAIN for full control
        androidWillPauseWhenDucked: false, // CRITICAL: Don't pause when ducked
      ));

      // Set audio attributes for alarm - prevents volume button interruption
      await _player.setAndroidAudioAttributes(
        const AndroidAudioAttributes(
          contentType: AndroidAudioContentType.sonification,
          usage: AndroidAudioUsage.alarm,
          flags: AndroidAudioFlags.audibilityEnforced,
        ),
      );

      // Set volume to max
      await _player.setVolume(1.0);

      // CRITICAL: Monitor interruptions and FORCE resume
      session.interruptionEventStream.listen((event) {
        debugPrint('🔔 Interruption event: begin=${event.begin}');
        if (_shouldKeepPlaying) {
          if (!event.begin) {
            // Interruption ended - force resume immediately
            Future.delayed(const Duration(milliseconds: 50), () {
              if (_shouldKeepPlaying) {
                debugPrint('🔄 Forcing resume after interruption');
                _player.play();
              }
            });
          }
        }
      });

      // CRITICAL: Handle headphones unplugged
      session.becomingNoisyEventStream.listen((_) {
        debugPrint('🔊 Becoming noisy event');
        if (_shouldKeepPlaying) {
          Future.delayed(const Duration(milliseconds: 50), () {
            if (_shouldKeepPlaying) {
              debugPrint('🔄 Resuming after noisy event');
              _player.play();
            }
          });
        }
      });

      // CRITICAL: Auto-resume if paused unexpectedly
      _player.playingStream.listen((isPlaying) {
        if (!isPlaying && _shouldKeepPlaying) {
          final state = _player.processingState;
          debugPrint(
              '⏸️ Playing stopped: state=$state, shouldKeepPlaying=$_shouldKeepPlaying');

          if (state != ProcessingState.completed &&
              state != ProcessingState.idle) {
            Future.delayed(const Duration(milliseconds: 150), () {
              if (_shouldKeepPlaying && !_player.playing) {
                debugPrint('🔄 Auto-resuming adhan playback');
                _player.play().catchError((e) {
                  debugPrint('❌ Error resuming: $e');
                });
              }
            });
          }
        }
      });

      // When audio completes naturally
      _player.processingStateStream.listen((state) {
        debugPrint('📊 Processing state: $state');
        if (state == ProcessingState.completed) {
          _shouldKeepPlaying = false;
          playbackState.add(playbackState.value.copyWith(
            processingState: AudioProcessingState.completed,
            playing: false,
          ));
        }
      });

      _isInitialized = true;
      debugPrint('✅ Audio handler initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing audio handler: $e');
    }
  }

  Future<void> playAdhan() async {
    try {
      debugPrint('🎵 Starting adhan playback...');
      _shouldKeepPlaying = true;

      if (!_isInitialized) {
        await _initPlayer();
      }

      // Stop any existing playback
      await _player.stop();

      // Load the audio file
      await _player.setAsset('assets/audio/adhan.mp3');

      // Set to max volume
      await _player.setVolume(1.0);

      // Disable looping
      await _player.setLoopMode(LoopMode.off);

      // Update playback state
      playbackState.add(playbackState.value.copyWith(
        controls: [MediaControl.stop],
        processingState: AudioProcessingState.ready,
        playing: true,
      ));

      // Start playing
      await _player.play();

      debugPrint('✅ Adhan playback started successfully');
    } catch (e) {
      debugPrint('❌ Error playing adhan: $e');
      _shouldKeepPlaying = false;
    }
  }

  @override
  Future<void> stop() async {
    debugPrint('⏹️ Stopping adhan...');
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
    _isInitialized = false;
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
  static AudioSession? _fallbackSession;

  Future<void> initialize() async {
    tz.initializeTimeZones();

    try {
      final timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName.toString()));
    } catch (e) {
      tz.setLocalLocation(tz.UTC);
    }

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/notification_icon');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();

    // Initialize audio service handler
    try {
      _audioHandler = await AudioService.init(
        builder: () => AdhanAudioHandler(),
        config: AudioServiceConfig(
          androidNotificationChannelId: 'com.adhan.khadija.audio',
          androidNotificationChannelName: 'الأذان',
          androidNotificationOngoing: true, // CHANGED: Keep ongoing
          androidStopForegroundOnPause: false, // CHANGED: Don't stop on pause
          androidNotificationIcon: 'drawable/notification_icon',
        ),
      );
      debugPrint('✅ Audio service initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing audio service: $e');
    }
  }

  static void _onNotificationResponse(NotificationResponse response) {
    debugPrint('📲 Notification response: ${response.actionId}');
    if (response.actionId == 'stop_adhan') {
      stopAdhan();
      NotificationService()._cancelNotificationById(response.id ?? 0);
    } else if (response.actionId == null) {
      // Notification tapped (not action button)
      // Don't stop, just bring app to foreground
      debugPrint('📲 Notification tapped, not stopping adhan');
    }
  }

  Future<void> _cancelNotificationById(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  // Enhanced fallback player with alarm behavior
  static Future<void> _playWithFallback() async {
    try {
      debugPrint('🔄 Using fallback player...');
      _shouldKeepPlaying = true;
      await _fallbackPlayer?.dispose();
      _fallbackPlayer = AudioPlayer();

      // Configure audio session for alarm behavior
      _fallbackSession = await AudioSession.instance;
      await _fallbackSession!.configure(AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.duckOthers,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        androidAudioAttributes: const AndroidAudioAttributes(
          contentType: AndroidAudioContentType.sonification,
          usage: AndroidAudioUsage.alarm,
          flags: AndroidAudioFlags.audibilityEnforced,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: false,
      ));

      // Set audio attributes for alarm
      await _fallbackPlayer!.setAndroidAudioAttributes(
        const AndroidAudioAttributes(
          contentType: AndroidAudioContentType.sonification,
          usage: AndroidAudioUsage.alarm,
          flags: AndroidAudioFlags.audibilityEnforced,
        ),
      );

      await _fallbackPlayer!.setVolume(1.0);
      await _fallbackPlayer!.setAsset('assets/audio/adhan.mp3');

      // Handle interruptions
      _fallbackSession!.interruptionEventStream.listen((event) {
        if (_shouldKeepPlaying && !event.begin) {
          Future.delayed(const Duration(milliseconds: 50), () {
            if (_shouldKeepPlaying) {
              _fallbackPlayer?.play();
            }
          });
        }
      });

      _fallbackSession!.becomingNoisyEventStream.listen((_) {
        if (_shouldKeepPlaying) {
          Future.delayed(const Duration(milliseconds: 50), () {
            if (_shouldKeepPlaying) {
              _fallbackPlayer?.play();
            }
          });
        }
      });

      // Auto-resume if paused
      _fallbackPlayer!.playingStream.listen((isPlaying) {
        if (!isPlaying && _shouldKeepPlaying && _fallbackPlayer != null) {
          final state = _fallbackPlayer!.processingState;
          if (state != ProcessingState.completed &&
              state != ProcessingState.idle) {
            Future.delayed(const Duration(milliseconds: 150), () {
              if (_shouldKeepPlaying &&
                  _fallbackPlayer != null &&
                  !_fallbackPlayer!.playing) {
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
      debugPrint('✅ Fallback player started successfully');
    } catch (e) {
      debugPrint('❌ Error playing with fallback: $e');
    }
  }

  // CRITICAL: Play adhan sound when notification appears
  static Future<void> _playAdhanSound() async {
    try {
      debugPrint('🎵 Playing adhan sound...');
      if (_audioHandler != null) {
        await _audioHandler!.playAdhan();
      } else {
        await _playWithFallback();
      }
    } catch (e) {
      debugPrint('❌ Error playing adhan: $e');
      await _playWithFallback();
    }
  }

  static Future<void> stopAdhan() async {
    try {
      debugPrint('⏹️ Stopping all adhan playback...');
      _shouldKeepPlaying = false;
      await _audioHandler?.stop();
      await _fallbackPlayer?.stop();
      await _fallbackPlayer?.dispose();
      _fallbackPlayer = null;
    } catch (e) {
      debugPrint('❌ Error stopping adhan: $e');
    }
  }

  Future<void> schedulePrayerNotification(
    String prayerName,
    DateTime prayerTime,
    int notificationId,
  ) async {
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
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
      color: const Color.fromARGB(255, 0, 78, 3),
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      ongoing: true, // Can't be dismissed by swiping
      autoCancel: false, // Won't dismiss automatically
      audioAttributesUsage: AudioAttributesUsage.alarm, // CRITICAL
      channelShowBadge: true,
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

    debugPrint('📅 Scheduled notification for $prayerName at $prayerTime');
  }

  Future<void> scheduleAllPrayerNotifications(
      Map<String, DateTime> prayers) async {
    await cancelAllNotifications();

    int id = 0;
    for (var entry in prayers.entries) {
      if (entry.key == 'الشروق') continue;
      await schedulePrayerNotification(entry.key, entry.value, id);
      id++;
    }
  }

  Future<void> showPrayerNotification(String prayerName) async {
    // CRITICAL: Play the adhan sound using audio handler
    await _playAdhanSound();

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'prayer_times_channel',
      'مواقيت الصلاة',
      channelDescription: 'إشعارات مواقيت الصلاة',
      importance: Importance.max,
      priority: Priority.high,
      playSound: false, // We're handling sound ourselves
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
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

  Future<void> showTestAdhanNotification() async {
    // CRITICAL: Play the adhan sound using audio handler
    await _playAdhanSound();

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'adhan_test_channel',
      'اختبار الأذان',
      channelDescription: 'قناة اختبار صوت الأذان',
      importance: Importance.max,
      priority: Priority.high,
      playSound: false, // We're handling sound ourselves
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
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
