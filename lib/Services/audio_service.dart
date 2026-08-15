import 'package:audioplayers/audioplayers.dart';


class AudioService {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> playRingBell() async {
    // 'AssetSource' looks into your 'assets' folder automatically
    await _player.play(AssetSource('bellSound.mp3'));
  }
  static void dispose() {
    _player.dispose();
  }
}