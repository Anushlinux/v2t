import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../models/transcript_data.dart';

class SpeechService {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final StreamController<TranscriptData> _transcriptController =
      StreamController<TranscriptData>.broadcast();

  bool _isListening = false;
  bool _hasSpeech = false;
  String _lastRecognizedWords = '';
  String _accumulatedFinalText = '';
  String _currentPartialText = '';

  // Debouncing for partial results
  Timer? _partialResultTimer;
  static const Duration _debounceDelay = Duration(milliseconds: 50);

  bool get isListening => _isListening;
  bool get hasSpeech => _hasSpeech;
  String get lastRecognizedWords => _lastRecognizedWords;
  String get accumulatedFinalText => _accumulatedFinalText;
  Stream<TranscriptData> get transcriptStream => _transcriptController.stream;

  Future<bool> initialize() async {
    try {
      // Web platform may require different error handling
      bool available = await _speechToText.initialize(
        onStatus: (status) {
          // Better state synchronization
          // 'done' means paused due to silence - don't stop listening, it may resume
          // 'notListening' means actually stopped - set listening to false
          if (status == 'notListening') {
            _isListening = false;
            // Clear partial text when actually stopped
            if (_currentPartialText.isNotEmpty) {
              _currentPartialText = '';
              _emitTranscript();
            }
          } else if (status == 'done') {
            // 'done' is a pause, not a stop - keep listening state
            // Partial text may be cleared but don't set _isListening = false
            // The recognition may resume automatically
          } else if (status == 'listening') {
            _isListening = true;
          }
        },
        onError: (error) {
          _transcriptController.addError(error);
        },
      );
      _hasSpeech = available;
      return available;
    } catch (e) {
      _transcriptController.addError(e);
      return false;
    }
  }

  Future<void> startListening() async {
    if (!_isListening && _hasSpeech) {
      try {
        _isListening = true;

        // Configure locale based on platform
        final localeId = kIsWeb ? 'en-US' : 'en_US';

        await _speechToText.listen(
          onResult: (result) {
            // Only use recognizedWords, ignore any debug metadata
            _lastRecognizedWords = result.recognizedWords;

            if (result.finalResult) {
              // Cancel any pending partial result timer
              _partialResultTimer?.cancel();
              _partialResultTimer = null;

              // Append final result to accumulated text
              if (_accumulatedFinalText.isNotEmpty) {
                _accumulatedFinalText =
                    '$_accumulatedFinalText $result.recognizedWords';
              } else {
                _accumulatedFinalText = result.recognizedWords;
              }

              // Clear partial text
              _currentPartialText = '';

              // Emit updated transcript immediately
              _emitTranscript();
            } else {
              // Handle partial results with minimal debouncing for real-time feel
              _currentPartialText = result.recognizedWords;
              _debouncePartialResult();
            }
          },
          listenFor: const Duration(seconds: 60),
          pauseFor: const Duration(seconds: 12),
          partialResults: true,
          localeId: localeId,
          cancelOnError: false,
        );
      } catch (e) {
        _isListening = false;
        _transcriptController.addError(e);
        rethrow;
      }
    }
  }

  void _debouncePartialResult() {
    // Cancel existing timer
    _partialResultTimer?.cancel();

    // Create new timer to debounce partial results
    _partialResultTimer = Timer(_debounceDelay, () {
      _emitTranscript();
    });
  }

  void _emitTranscript() {
    final transcriptData = TranscriptData(
      finalText: _accumulatedFinalText,
      partialText: _currentPartialText,
    );
    _transcriptController.add(transcriptData);
  }

  Future<void> stopListening() async {
    if (_isListening) {
      // Cancel any pending partial result timer
      _partialResultTimer?.cancel();
      _partialResultTimer = null;

      try {
        await _speechToText.stop();
      } catch (e) {
        _transcriptController.addError(e);
      } finally {
        _isListening = false;
        // Clear partial text when stopping
        if (_currentPartialText.isNotEmpty) {
          _currentPartialText = '';
          _emitTranscript();
        }
      }
    }
  }

  Future<void> cancel() async {
    if (_isListening) {
      // Cancel any pending partial result timer
      _partialResultTimer?.cancel();
      _partialResultTimer = null;

      try {
        await _speechToText.cancel();
      } catch (e) {
        _transcriptController.addError(e);
      } finally {
        _isListening = false;
        _currentPartialText = '';
        _emitTranscript();
      }
    }
  }

  /// Clear the accumulated transcript
  void clearTranscript() {
    _accumulatedFinalText = '';
    _currentPartialText = '';
    _lastRecognizedWords = '';
    _emitTranscript();
  }

  void dispose() {
    _partialResultTimer?.cancel();
    _transcriptController.close();
  }
}
