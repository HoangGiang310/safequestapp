import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AudioService extends ChangeNotifier {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isPlaying = false;
  String? _currentSpeakingText;

  bool get isPlaying => _isPlaying;
  String? get currentSpeakingText => _currentSpeakingText;

  bool isSpeaking(String text) => _isPlaying && _currentSpeakingText == text.trim();

  // Tốc độ chuẩn vừa phải, rõ ràng cho trẻ em dễ nghe (0.48)
  static const double defaultSpeechRate = 0.48;
  // Cao độ giọng đọc tự nhiên, ấm áp (1.0)
  static const double defaultPitch = 1.0;
  static const double defaultVolume = 1.0;
  
  AudioService._internal() {
    _init();
  }

  Future<void> _init() async {
    if (_isInitialized) return;
    try {
      await _flutterTts.setLanguage("vi-VN");
      // Cố gắng chọn giọng đọc tiếng Việt mượt mà
      try {
        List<dynamic> voices = await _flutterTts.getVoices;
        for (var voice in voices) {
          if (voice["locale"] == "vi-VN" && voice["name"].toString().contains("network")) {
            await _flutterTts.setVoice({"name": voice["name"], "locale": voice["locale"]});
            break;
          }
        }
      } catch (e) {
        debugPrint("Error setting voice: $e");
      }

      await _flutterTts.setSpeechRate(defaultSpeechRate); 
      await _flutterTts.setVolume(defaultVolume);
      await _flutterTts.setPitch(defaultPitch); 
      
      await _flutterTts.awaitSpeakCompletion(true);

      _flutterTts.setStartHandler(() {
        _isPlaying = true;
        notifyListeners();
      });

      _flutterTts.setCompletionHandler(() {
        _isPlaying = false;
        _currentSpeakingText = null;
        notifyListeners();
      });

      _flutterTts.setCancelHandler(() {
        _isPlaying = false;
        _currentSpeakingText = null;
        notifyListeners();
      });

      _flutterTts.setErrorHandler((msg) {
        debugPrint("TTS error: $msg");
        _isPlaying = false;
        _currentSpeakingText = null;
        notifyListeners();
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint("AudioService init error: $e");
    }
  }

  Future<void> speak(String text, {double? rate, double? pitch}) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;
    if (!_isInitialized) await _init();

    await stop();

    _currentSpeakingText = cleanText;
    _isPlaying = true;
    notifyListeners();

    try {
      await _flutterTts.setSpeechRate(rate ?? defaultSpeechRate);
      await _flutterTts.setPitch(pitch ?? defaultPitch);
      await _flutterTts.setVolume(defaultVolume);
      await _flutterTts.speak(cleanText);

      if (_currentSpeakingText == cleanText) {
        _isPlaying = false;
        _currentSpeakingText = null;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("TTS speak error: $e");
      _isPlaying = false;
      _currentSpeakingText = null;
      notifyListeners();
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      debugPrint("TTS stop error: $e");
    }
    _isPlaying = false;
    _currentSpeakingText = null;
    notifyListeners();
  }
}
