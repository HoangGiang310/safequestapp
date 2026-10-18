import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class CelebrationSoundManager {
  static final CelebrationSoundManager _instance = CelebrationSoundManager._internal();
  factory CelebrationSoundManager() => _instance;

  final AudioPlayer _player = AudioPlayer();
  bool _soundEnabled = true;

  CelebrationSoundManager._internal();

  bool get isSoundEnabled => _soundEnabled;

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  Future<void> playCorrectAnswer() async {
    if (!_soundEnabled) return;
    try {
      // Vì chưa có file audio thật, dùng mock beep/chime nếu được, 
      // hoặc tạm để catch chống crash
      await _player.play(AssetSource('audio/correct.mp3'));
    } catch (e) {
      debugPrint("Audio not found, mock play success");
    }
  }

  Future<void> playWrongAnswer() async {
    if (!_soundEnabled) return;
    try {
      await _player.play(AssetSource('audio/wrong.mp3'));
    } catch (e) {
      debugPrint("Audio not found, mock play success");
    }
  }

  Future<void> playLevelComplete() async {
    if (!_soundEnabled) return;
    try {
      await _player.play(AssetSource('audio/level_complete.mp3'));
    } catch (e) {
      debugPrint("Audio not found, mock play success");
    }
  }

  Future<void> playBadgeUnlock() async {
    if (!_soundEnabled) return;
    try {
      await _player.play(AssetSource('audio/badge_unlock.mp3'));
    } catch (e) {
      debugPrint("Audio not found, mock play success");
    }
  }
}
