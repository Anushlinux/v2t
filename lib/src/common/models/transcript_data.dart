/// Model to represent transcript with partial and final text
class TranscriptData {
  final String finalText;
  final String partialText;

  const TranscriptData({required this.finalText, required this.partialText});

  /// Get the full display text (final + partial)
  String get displayText {
    if (partialText.isEmpty) return finalText;
    if (finalText.isEmpty) return partialText;
    return '$finalText $partialText';
  }

  /// Check if there's any text
  bool get isEmpty => finalText.isEmpty && partialText.isEmpty;

  TranscriptData copyWith({String? finalText, String? partialText}) {
    return TranscriptData(
      finalText: finalText ?? this.finalText,
      partialText: partialText ?? this.partialText,
    );
  }

  TranscriptData clear() {
    return const TranscriptData(finalText: '', partialText: '');
  }
}
