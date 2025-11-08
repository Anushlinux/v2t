import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Real-time audio waveform animation with scrolling effect
class AudioWaveform extends StatefulWidget {
  final bool isActive;
  final int barCount;
  final double height;
  final double width;
  final Color? color;
  final double barWidth;
  final double barGap;
  final double barRadius;
  final double scrollSpeed;
  final bool fadeEdges;
  final double fadeWidth;

  const AudioWaveform({
    super.key,
    required this.isActive,
    this.barCount = 60,
    this.height = 60.0,
    this.width = double.infinity,
    this.color,
    this.barWidth = 4.0,
    this.barGap = 2.0,
    this.barRadius = 2.0,
    this.scrollSpeed = 50.0,
    this.fadeEdges = true,
    this.fadeWidth = 24.0,
  });

  @override
  State<AudioWaveform> createState() => _AudioWaveformState();
}

class _AudioWaveformState extends State<AudioWaveform>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    if (widget.isActive) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(AudioWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _animationController.repeat();
    } else if (!widget.isActive && oldWidget.isActive) {
      _animationController.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  double _generateBarHeight(int index, double time) {
    if (!widget.isActive) {
      return 0.05;
    }

    // Create dynamic waveform pattern
    final normalizedPos = index / widget.barCount;
    final timeValue = time * 2 * math.pi;

    // Primary wave with varying frequency
    final primaryFreq = 2.0 + normalizedPos * 3.0;
    final primaryWave = math.sin(
      normalizedPos * primaryFreq * math.pi + timeValue,
    );

    // Secondary wave for variation
    final secondaryFreq = 4.0 + normalizedPos * 2.0;
    final secondaryWave =
        math.sin(normalizedPos * secondaryFreq * math.pi + timeValue * 1.3) *
        0.5;

    // Tertiary wave for fine detail
    final tertiaryFreq = 8.0 + normalizedPos * 4.0;
    final tertiaryWave =
        math.sin(normalizedPos * tertiaryFreq * math.pi + timeValue * 0.7) *
        0.3;

    // Combine waves
    final combined = (primaryWave + secondaryWave + tertiaryWave) / 3.0;
    final normalized = (combined + 1.0) / 2.0;

    // Scale to appropriate height
    return 0.05 + normalized * 0.85;
  }

  List<double> _computeScrollingBars(double scrollOffset, Size size) {
    final totalBarWidth = widget.barWidth + widget.barGap;
    // Calculate how many bars we need to cover the visible area plus some buffer
    final visibleBarCount =
        ((size.width + scrollOffset) / totalBarWidth).ceil() + 2;
    final bars = <double>[];

    // Calculate which bars should be visible based on scroll offset
    // Bars scroll from right to left, so we start from the scroll offset
    final startIndex = (scrollOffset / totalBarWidth).floor();

    for (int i = 0; i < visibleBarCount; i++) {
      final barIndex = startIndex + i;
      // Use barIndex to generate consistent pattern, wrapping around
      final patternIndex = barIndex % widget.barCount;
      final time = (_animationController.value + barIndex * 0.05) % 1.0;
      final height = _generateBarHeight(patternIndex, time);
      bars.add(height);
    }

    return bars;
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppTheme.accentPrimary;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = widget.width == double.infinity
            ? constraints.maxWidth
            : widget.width;

        // Validate dimensions before painting
        if (width <= 0 ||
            !width.isFinite ||
            widget.height <= 0 ||
            !widget.height.isFinite) {
          return const SizedBox.shrink();
        }

        // Validate bar properties
        if (widget.barWidth <= 0 || widget.barGap < 0 || widget.barCount <= 0) {
          return const SizedBox.shrink();
        }

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            // Calculate scroll offset for continuous scrolling effect
            // Bars move from right to left, so offset increases
            final totalBarWidth = widget.barWidth + widget.barGap;
            if (totalBarWidth <= 0) {
              return const SizedBox.shrink();
            }

            final maxOffset = totalBarWidth * widget.barCount;
            final scrollOffset = widget.isActive
                ? (_animationController.value * widget.scrollSpeed) % maxOffset
                : 0.0;

            final barHeights = _computeScrollingBars(
              scrollOffset,
              Size(width, widget.height),
            );

            return CustomPaint(
              size: Size(width, widget.height),
              painter: _WaveformPainter(
                barHeights: barHeights,
                color: color,
                isActive: widget.isActive,
                barWidth: widget.barWidth,
                barGap: widget.barGap,
                barRadius: widget.barRadius,
                scrollOffset: scrollOffset,
                fadeEdges: widget.fadeEdges,
                fadeWidth: widget.fadeWidth,
              ),
            );
          },
        );
      },
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final List<double> barHeights;
  final Color color;
  final bool isActive;
  final double barWidth;
  final double barGap;
  final double barRadius;
  final double scrollOffset;
  final bool fadeEdges;
  final double fadeWidth;

  _WaveformPainter({
    required this.barHeights,
    required this.color,
    required this.isActive,
    required this.barWidth,
    required this.barGap,
    required this.barRadius,
    required this.scrollOffset,
    required this.fadeEdges,
    required this.fadeWidth,
  });

  double _getFadeOpacity(double x, Size size) {
    if (!fadeEdges || fadeWidth <= 0) return 1.0;

    // Fade on left edge
    if (x < fadeWidth) {
      final opacity = (x / fadeWidth).clamp(0.0, 1.0);
      return opacity;
    }

    // Fade on right edge
    if (x > size.width - fadeWidth) {
      final opacity = ((size.width - x) / fadeWidth).clamp(0.0, 1.0);
      return opacity;
    }

    return 1.0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Validate size before painting
    if (barHeights.isEmpty ||
        size.width <= 0 ||
        size.height <= 0 ||
        !size.width.isFinite ||
        !size.height.isFinite) {
      return;
    }

    final totalBarWidth = barWidth + barGap;
    if (totalBarWidth <= 0 || barWidth <= 0) {
      return;
    }

    final centerY = size.height / 2;

    // Calculate starting position based on scroll offset
    final startIndex = (scrollOffset / totalBarWidth).floor();

    for (int i = 0; i < barHeights.length; i++) {
      final barHeight = barHeights[i].clamp(0.0, 1.0);
      final height = barHeight * size.height * 0.9;

      // Skip very small bars
      if (height < 1.0) continue;

      // Calculate x position with scroll offset
      // Bars scroll from right to left, so we subtract the offset
      final barIndex = startIndex + i;
      final x = barIndex * totalBarWidth - scrollOffset;

      // Skip bars outside visible area (with fade width buffer)
      if (x + barWidth < -fadeWidth || x > size.width + fadeWidth) continue;

      // Validate bar dimensions before creating rect
      final barY = centerY - height / 2;
      if (barWidth <= 0 || height <= 0) continue;

      final barRect = Rect.fromLTWH(
        x.clamp(-fadeWidth, size.width + fadeWidth),
        barY.clamp(0.0, size.height),
        barWidth.clamp(0.0, size.width + fadeWidth * 2),
        height.clamp(0.0, size.height),
      );

      // Validate rect before creating shader
      if (barRect.width <= 0 ||
          barRect.height <= 0 ||
          !barRect.width.isFinite ||
          !barRect.height.isFinite) {
        continue;
      }

      // Calculate fade opacity
      final opacity = _getFadeOpacity(x + barWidth / 2, size).clamp(0.0, 1.0);

      // Create enhanced gradient with glow effect
      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(opacity),
          color.withOpacity((opacity * 0.8).clamp(0.0, 1.0)),
          color.withOpacity((opacity * 0.5).clamp(0.0, 1.0)),
          color.withOpacity((opacity * 0.2).clamp(0.0, 1.0)),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      );

      try {
        final paint = Paint()
          ..style = PaintingStyle.fill
          ..shader = gradient.createShader(barRect);

        // Draw main bar with rounded corners
        final rect = RRect.fromRectAndRadius(
          barRect,
          Radius.circular(barRadius.clamp(0.0, barWidth / 2)),
        );

        canvas.drawRRect(rect, paint);

        // Add subtle glow effect for active bars
        if (isActive && height > size.height * 0.2) {
          final glowPaint = Paint()
            ..style = PaintingStyle.fill
            ..color = color.withOpacity((opacity * 0.15).clamp(0.0, 1.0))
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

          canvas.drawRRect(rect, glowPaint);
        }
      } catch (e) {
        // Skip this bar if shader creation fails
        continue;
      }
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter oldDelegate) {
    return oldDelegate.barHeights != barHeights ||
        oldDelegate.color != color ||
        oldDelegate.isActive != isActive ||
        oldDelegate.scrollOffset != scrollOffset ||
        oldDelegate.barWidth != barWidth ||
        oldDelegate.barGap != barGap ||
        oldDelegate.barRadius != barRadius;
  }
}
