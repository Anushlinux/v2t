import 'dart:async';
import 'package:flutter/material.dart';
import '../../common/services/speech_service.dart';
import '../../common/theme/app_theme.dart';
import '../../common/widgets/glass_container.dart';
import '../../common/widgets/agent_orb.dart';
import '../../common/widgets/audio_waveform.dart';

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
            SnackBar(
              content: const Text(
                'Speech recognition not available. Please check permissions.',
              ),
              backgroundColor: AppTheme.error,
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
                    backgroundColor: AppTheme.error,
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
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _toggleListening() async {
    if (!_isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Speech recognition not initialized'),
          backgroundColor: AppTheme.warning,
        ),
      );
      return;
    }

    if (_speechService.isListening) {
      await _speechService.stopListening();
      setState(() {
        _transcript = _speechService.lastRecognizedWords;
      });
    } else {
      await _speechService.startListening();
    }
  }

  AgentOrbState _getOrbState() {
    if (!_isInitialized) {
      return AgentOrbState.idle;
    }
    if (_speechService.isListening) {
      return _transcript.isNotEmpty
          ? AgentOrbState.talking
          : AgentOrbState.listening;
    }
    return AgentOrbState.idle;
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
    final orbState = _getOrbState();
    final isListening = _speechService.isListening;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: AppTheme.spacingXL),
              // Agent Orb (centered)
              AgentOrb(
                state: orbState,
                size: 140,
                onTap: _isInitialized ? _toggleListening : null,
              ),
              const SizedBox(height: AppTheme.spacingXL),
              // Audio Waveform
              if (_isInitialized)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingXL,
                  ),
                  child: AudioWaveform(isActive: isListening, height: 80),
                )
              else
                const Padding(
                  padding: EdgeInsets.all(AppTheme.spacingXL),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.accentPrimary,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: AppTheme.spacingXL),
              // Transcript Container
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingL,
                  ),
                  child: SizedBox(
                    height: 300,
                    child: GlassContainer(
                      padding: const EdgeInsets.all(AppTheme.spacingL),
                      child: _transcript.isEmpty
                          ? Center(
                              child: Text(
                                'Tap the orb to start speaking...',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.textTertiary,
                                ),
                              ),
                            )
                          : SingleChildScrollView(
                              child: Text(
                                _transcript,
                                style: AppTheme.bodyLarge.copyWith(
                                  fontSize: 16,
                                  height: 1.6,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),
            ],
          ),
        ),
      ),
    );
  }
}
