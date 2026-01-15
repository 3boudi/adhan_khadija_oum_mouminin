import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

class AudioService {
  late AudioPlayer _audioPlayer;

  AudioService() {
    _audioPlayer = AudioPlayer();
    _init();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
  }

  Future<void> playAdhan() async {
    try {
      await _audioPlayer.setAsset('assets/audio/adhan.mp3');
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing adhan: $e');
    }
  }

  Future<void> stopAdhan() async {
    await _audioPlayer.stop();
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
