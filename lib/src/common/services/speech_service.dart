import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final StreamController<String> _transcriptController =
      StreamController<String>.broadcast();
  bool _isListening = false;
  bool _hasSpeech = false;
  String _lastRecognizedWords = '';

  bool get isListening => _isListening;
  bool get hasSpeech => _hasSpeech;
  String get lastRecognizedWords => _lastRecognizedWords;
  Stream<String> get transcriptStream => _transcriptController.stream;

  Future<bool> initialize() async {
    bool available = await _speechToText.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          _isListening = false;
        }
      },
      onError: (error) {
        _transcriptController.addError(error);
      },
    );
    _hasSpeech = available;
    return available;
  }

  Future<void> startListening() async {
    if (!_isListening && _hasSpeech) {
      _isListening = true;
      await _speechToText.listen(
        onResult: (result) {
          _lastRecognizedWords = result.recognizedWords;
          if (result.finalResult) {
            _transcriptController.add(result.recognizedWords);
          } else {
            // Send partial results for live updates
            _transcriptController.add(result.recognizedWords);
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        localeId: 'en_US',
      );
    }
  }

  Future<void> stopListening() async {
    if (_isListening) {
      _isListening = false;
      await _speechToText.stop();
    }
  }

  Future<void> cancel() async {
    if (_isListening) {
      _isListening = false;
      await _speechToText.cancel();
    }
  }

  void dispose() {
    _transcriptController.close();
  }
}
