import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

/// Service to handle voice recording and speech-to-text conversion
class VoiceMessageService {
  late stt.SpeechToText _speechToText;
  bool _isListening = false;
  String _recognizedText = '';
  double _confidence = 0.0;

  VoiceMessageService() {
    _speechToText = stt.SpeechToText();
  }

  /// Initialize speech-to-text service and request microphone permission
  Future<bool> initialize() async {
    try {
      // Request microphone permission (will succeed on web, user grants via browser)
      final micPermission = await Permission.microphone.request();

      if (!micPermission.isGranted && !micPermission.isDenied) {
        // On some platforms (like web), permissions work differently
        // so we proceed cautiously.
      }

      // Try to initialize speech-to-text
      bool available = false;
      try {
        available = await _speechToText.initialize(
          onError: (error) {},
          onStatus: (status) {},
        );
      } catch (e) {
        // Speech-to-text may not be available on all platforms (e.g., web)
        return false;
      }

      return available;
    } catch (e) {
      return false;
    }
  }

  /// Start listening for voice input
  Future<void> startListening() async {
    if (!_speechToText.isAvailable) {
      return;
    }

    if (_isListening) return;

    _recognizedText = '';
    _confidence = 0.0;
    _isListening = true;

    try {
      await _speechToText.listen(
        onResult: (result) {
          _recognizedText = result.recognizedWords;
          _confidence = result.confidence;
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
      );
    } catch (e) {
      _isListening = false;
    }
  }

  /// Stop listening and return recognized text
  Future<String> stopListening() async {
    if (!_isListening) return '';

    _isListening = false;

    try {
      await _speechToText.stop();
      return _recognizedText;
    } catch (e) {
      return '';
    }
  }

  /// Cancel listening (used when user cancels recording)
  Future<void> cancel() async {
    _isListening = false;
    _recognizedText = '';
    _confidence = 0.0;
    await _speechToText.cancel();
  }

  /// Check if currently listening
  bool get isListening => _isListening;

  /// Get recognized text
  String get recognizedText => _recognizedText;

  /// Get confidence level (0.0 - 1.0)
  double get confidence => _confidence;

  /// Get available locales for speech recognition
  Future<List<String>> getAvailableLocales() async {
    final locales = await _speechToText.locales();
    return locales.map((locale) => locale.localeId).toList();
  }

  /// Dispose resources
  void dispose() {
    if (_speechToText.isListening) {
      _speechToText.stop();
    }
  }
}
