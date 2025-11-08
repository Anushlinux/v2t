import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../common/services/speech_service.dart';

class VoicePage extends StatefulWidget {
  const VoicePage({super.key});

  @override
  State<VoicePage> createState() => _VoicePageState();
}

class _VoicePageState extends State<VoicePage> {
  final SpeechService _speechService = SpeechService();
  String _transcript = '';
  bool _isInitialized = false;
  StreamSubscription<String>? _transcriptSubscription;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    try {
      final initialized = await _speechService.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = initialized;
        });

        if (!initialized) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Speech recognition not available. Please check permissions.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          _transcriptSubscription = _speechService.transcriptStream.listen(
            (text) {
              setState(() {
                _transcript = text;
              });
            },
            onError: (error) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $error'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initialize speech recognition: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleListening() async {
    if (!_isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Speech recognition not initialized'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_speechService.isListening) {
      await _speechService.stopListening();
      // Keep the last transcript
      setState(() {
        _transcript = _speechService.lastRecognizedWords;
      });
    } else {
      await _speechService.startListening();
    }
  }

  @override
  void dispose() {
    _transcriptSubscription?.cancel();
    _speechService.cancel();
    _speechService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Voice to Text')),
      body: SafeArea(
        child: Column(
          children: [
            if (user != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                color: Colors.blue.shade50,
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Logged in as: ${user.email}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Transcript',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            _transcript.isEmpty
                                ? 'Tap the microphone button to start speaking...'
                                : _transcript,
                            style: TextStyle(
                              fontSize: 16,
                              color: _transcript.isEmpty
                                  ? Colors.grey.shade600
                                  : Colors.black87,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (!_isInitialized)
                      const Center(child: CircularProgressIndicator()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isInitialized ? _toggleListening : null,
        backgroundColor: _speechService.isListening ? Colors.red : Colors.blue,
        icon: Icon(
          _speechService.isListening ? Icons.mic : Icons.mic_none,
          size: 28,
        ),
        label: Text(
          _speechService.isListening ? 'Stop Listening' : 'Start Listening',
          style: const TextStyle(fontSize: 16),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
