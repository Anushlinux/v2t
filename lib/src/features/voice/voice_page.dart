import 'dart:async';
import 'package:flutter/material.dart';
import '../../common/services/speech_service.dart';
import '../../common/theme/app_theme.dart';
import '../../common/widgets/glass_container.dart';
import '../../common/widgets/agent_orb.dart';
import '../../common/widgets/audio_waveform.dart';
import '../../common/widgets/glass_button.dart';
import '../../common/models/transcript_data.dart';

class VoicePage extends StatefulWidget {
  const VoicePage({super.key});

  @override
  State<VoicePage> createState() => _VoicePageState();
}

class _VoicePageState extends State<VoicePage> {
  final SpeechService _speechService = SpeechService();
  final ScrollController _scrollController = ScrollController();
  TranscriptData _transcriptData = const TranscriptData(
    finalText: '',
    partialText: '',
  );
  bool _isInitialized = false;
  bool _isInitializing = true;
  StreamSubscription<TranscriptData>? _transcriptSubscription;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    try {
      setState(() {
        _isInitializing = true;
      });

      final initialized = await _speechService.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = initialized;
          _isInitializing = false;
        });

        if (!initialized) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Speech recognition not available. Please check permissions.',
              ),
              backgroundColor: AppTheme.error,
              action: SnackBarAction(
                label: 'Retry',
                textColor: AppTheme.textPrimary,
                onPressed: _initializeSpeech,
              ),
            ),
          );
        } else {
          _transcriptSubscription = _speechService.transcriptStream.listen(
            (transcriptData) {
              if (mounted) {
                setState(() {
                  _transcriptData = transcriptData;
                });
                // Auto-scroll to bottom when new text arrives
                _scrollToBottom();
              }
            },
            onError: (error) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $error'),
                    backgroundColor: AppTheme.error,
                    action: SnackBarAction(
                      label: 'Retry',
                      textColor: AppTheme.textPrimary,
                      onPressed: () {
                        _speechService.cancel();
                        _initializeSpeech();
                      },
                    ),
                  ),
                );
              }
            },
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initialize speech recognition: $e'),
            backgroundColor: AppTheme.error,
            action: SnackBarAction(
              label: 'Retry',
              textColor: AppTheme.textPrimary,
              onPressed: _initializeSpeech,
            ),
          ),
        );
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
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

    try {
      if (_speechService.isListening) {
        await _speechService.stopListening();
      } else {
        await _speechService.startListening();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  void _clearTranscript() {
    _speechService.clearTranscript();
    setState(() {
      _transcriptData = const TranscriptData(finalText: '', partialText: '');
    });
  }

  AgentOrbState _getOrbState() {
    if (!_isInitialized) {
      return AgentOrbState.idle;
    }
    if (_speechService.isListening) {
      return _transcriptData.displayText.isNotEmpty
          ? AgentOrbState.talking
          : AgentOrbState.listening;
    }
    return AgentOrbState.idle;
  }

  @override
  void dispose() {
    _transcriptSubscription?.cancel();
    _scrollController.dispose();
    _speechService.cancel();
    _speechService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orbState = _getOrbState();
    final isListening = _speechService.isListening;
    final hasText = !_transcriptData.isEmpty;

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
              else if (_isInitializing)
                const Padding(
                  padding: EdgeInsets.all(AppTheme.spacingXL),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.accentPrimary,
                      ),
                    ),
                  ),
                )
              else
                const SizedBox(height: 80),
              const SizedBox(height: AppTheme.spacingXL),
              // Transcript Container
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingL,
                  ),
                  child: SizedBox(
                    height: 300,
                    child: GlassContainer(
                      height: 300,
                      padding: const EdgeInsets.all(AppTheme.spacingL),
                      child: !hasText
                          ? const Center(
                              child: Text(
                                'Tap the orb to start speaking...',
                                style: AppTheme.bodyMedium,
                              ),
                            )
                          : SingleChildScrollView(
                              controller: _scrollController,
                              reverse: false,
                              physics: const BouncingScrollPhysics(),
                              child: Text(
                                _transcriptData.displayText,
                                textAlign: TextAlign.left,
                                softWrap: true,
                                style: AppTheme.bodyLarge.copyWith(
                                  fontSize: 16,
                                  height: 1.6,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              // Action buttons
              if (hasText)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingL,
                  ),
                  child: GlassButton(
                    label: 'Clear',
                    icon: Icons.clear,
                    onPressed: _clearTranscript,
                    isPrimary: false,
                    height: 48,
                  ),
                )
              else
                const SizedBox(height: 48),
              const SizedBox(height: AppTheme.spacingL),
            ],
          ),
        ),
      ),
    );
  }
}
