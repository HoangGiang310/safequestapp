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

  // Tốc độ đọc ổn định, rõ ràng, không nhanh không chậm, phù hợp cho trẻ em (0.52)
  static const double defaultSpeechRate = 0.52;
  // Cao độ giọng đọc tươi vui, trong trẻo, gần gũi với trẻ thơ (1.2)
  static const double defaultPitch = 1.2;
  static const double defaultVolume = 1.0;
  
  AudioService._internal() {
    _init();
  }

  Future<void> _init() async {
    if (_isInitialized) return;
    try {
      await _flutterTts.setLanguage("vi-VN");
      // Ưu tiên chọn giọng đọc tiếng Việt nữ / trẻ trung / truyền cảm mượt mà
      try {
        List<dynamic> voices = await _flutterTts.getVoices;
        Map<String, String>? bestVoice;
        for (var voice in voices) {
          final locale = voice["locale"]?.toString() ?? "";
          final name = voice["name"]?.toString().toLowerCase() ?? "";
          if (locale.toLowerCase().contains("vi")) {
            // Ưu tiên giọng network hoặc voice nữ có độ tự nhiên cao
            if (name.contains("network") || name.contains("female") || name.contains("vic") || name.contains("vif")) {
              bestVoice = {"name": voice["name"].toString(), "locale": locale};
              break;
            }
            bestVoice ??= {"name": voice["name"].toString(), "locale": locale};
          }
        }
        if (bestVoice != null) {
          await _flutterTts.setVoice(bestVoice);
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

  String prepareChildFriendlyText(String text) {
    var formatted = text.trim();
    // Thay thế dấu hai chấm bằng dấu phẩy ngắt nhịp tự nhiên để TTS không đọc "hai chấm"
    formatted = formatted.replaceAll(RegExp(r':\s*'), ', ');
    // Loại bỏ các ký tự thô như *, _, #
    formatted = formatted.replaceAll(RegExp(r'[\*_~#]'), '');
    return formatted;
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

      final childFriendlyText = prepareChildFriendlyText(cleanText);
      await _flutterTts.speak(childFriendlyText);

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
