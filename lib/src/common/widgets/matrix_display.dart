import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Dot-matrix display widget for retro-style text visualization
/// Displays text in a LED matrix style with circular cells
class MatrixDisplay extends StatelessWidget {
  final String text;
  final double cellSize;
  final double cellGap;
  final Color? activeColor;
  final Color? inactiveColor;
  final int rows;
  final int colsPerChar;

  const MatrixDisplay({
    super.key,
    required this.text,
    this.cellSize = 6.0,
    this.cellGap = 2.0,
    this.activeColor,
    this.inactiveColor,
    this.rows = 7,
    this.colsPerChar = 5,
  });

  @override
  Widget build(BuildContext context) {
    final active = activeColor ?? AppTheme.accentPrimary;
    final inactive = inactiveColor ?? AppTheme.textTertiary.withOpacity(0.2);

    if (text.isEmpty) {
      return _buildEmptyState(inactive);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Wrap(
        alignment: WrapAlignment.start,
        spacing: cellGap * 2,
        runSpacing: cellGap * 2,
        children: text.split('').map((char) {
          return _buildCharacter(char, active, inactive);
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(Color inactive) {
    return Container(
      height: rows * (cellSize + cellGap) - cellGap,
      alignment: Alignment.center,
      child: Text(
        'Tap the orb to start speaking...',
        style: AppTheme.bodyMedium.copyWith(color: AppTheme.textTertiary),
      ),
    );
  }

  Widget _buildCharacter(String char, Color active, Color inactive) {
    final pattern = _getCharacterPattern(char);
    final charWidth = colsPerChar * (cellSize + cellGap) - cellGap;

    return Container(
      width: charWidth,
      margin: EdgeInsets.only(right: cellGap * 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(rows, (row) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(colsPerChar, (col) {
              final isActive =
                  row < pattern.length &&
                  col < pattern[row].length &&
                  pattern[row][col] == 1;
              return Container(
                width: cellSize,
                height: cellSize,
                margin: EdgeInsets.only(
                  right: col < colsPerChar - 1 ? cellGap : 0,
                  bottom: row < rows - 1 ? cellGap : 0,
                ),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? active : inactive,
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: active.withOpacity(0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              );
            }),
          );
        }),
      ),
    );
  }

  /// Returns a 2D pattern for a character (1 = active, 0 = inactive)
  /// Simplified 7x5 dot matrix patterns for common characters
  List<List<int>> _getCharacterPattern(String char) {
    final upperChar = char.toUpperCase();

    // Simple patterns for common characters
    switch (upperChar) {
      case 'A':
        return [
          [0, 1, 1, 1, 0],
          [1, 0, 0, 0, 1],
          [1, 1, 1, 1, 1],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [0, 0, 0, 0, 0],
        ];
      case 'B':
        return [
          [1, 1, 1, 1, 0],
          [1, 0, 0, 0, 1],
          [1, 1, 1, 1, 0],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [1, 1, 1, 1, 0],
          [0, 0, 0, 0, 0],
        ];
      case 'C':
        return [
          [0, 1, 1, 1, 0],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 0],
          [1, 0, 0, 0, 0],
          [1, 0, 0, 0, 1],
          [0, 1, 1, 1, 0],
          [0, 0, 0, 0, 0],
        ];
      case 'D':
        return [
          [1, 1, 1, 1, 0],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [1, 1, 1, 1, 0],
          [0, 0, 0, 0, 0],
        ];
      case 'E':
        return [
          [1, 1, 1, 1, 1],
          [1, 0, 0, 0, 0],
          [1, 1, 1, 1, 0],
          [1, 0, 0, 0, 0],
          [1, 0, 0, 0, 0],
          [1, 1, 1, 1, 1],
          [0, 0, 0, 0, 0],
        ];
      case 'F':
        return [
          [1, 1, 1, 1, 1],
          [1, 0, 0, 0, 0],
          [1, 1, 1, 1, 0],
          [1, 0, 0, 0, 0],
          [1, 0, 0, 0, 0],
          [1, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
        ];
      case 'G':
        return [
          [0, 1, 1, 1, 0],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 0],
          [1, 0, 1, 1, 1],
          [1, 0, 0, 0, 1],
          [0, 1, 1, 1, 0],
          [0, 0, 0, 0, 0],
        ];
      case 'H':
        return [
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [1, 1, 1, 1, 1],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [0, 0, 0, 0, 0],
        ];
      case 'I':
        return [
          [1, 1, 1, 1, 1],
          [0, 0, 1, 0, 0],
          [0, 0, 1, 0, 0],
          [0, 0, 1, 0, 0],
          [0, 0, 1, 0, 0],
          [1, 1, 1, 1, 1],
          [0, 0, 0, 0, 0],
        ];
      case 'J':
        return [
          [0, 0, 1, 1, 1],
          [0, 0, 0, 1, 0],
          [0, 0, 0, 1, 0],
          [0, 0, 0, 1, 0],
          [1, 0, 0, 1, 0],
          [0, 1, 1, 0, 0],
          [0, 0, 0, 0, 0],
        ];
      case 'K':
        return [
          [1, 0, 0, 0, 1],
          [1, 0, 0, 1, 0],
          [1, 1, 1, 0, 0],
          [1, 0, 0, 1, 0],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [0, 0, 0, 0, 0],
        ];
      case 'L':
        return [
          [1, 0, 0, 0, 0],
          [1, 0, 0, 0, 0],
          [1, 0, 0, 0, 0],
          [1, 0, 0, 0, 0],
          [1, 0, 0, 0, 0],
          [1, 1, 1, 1, 1],
          [0, 0, 0, 0, 0],
        ];
      case 'M':
        return [
          [1, 0, 0, 0, 1],
          [1, 1, 0, 1, 1],
          [1, 0, 1, 0, 1],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [0, 0, 0, 0, 0],
        ];
      case 'N':
        return [
          [1, 0, 0, 0, 1],
          [1, 1, 0, 0, 1],
          [1, 0, 1, 0, 1],
          [1, 0, 0, 1, 1],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [0, 0, 0, 0, 0],
        ];
      case 'O':
        return [
          [0, 1, 1, 1, 0],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [0, 1, 1, 1, 0],
          [0, 0, 0, 0, 0],
        ];
      case 'P':
        return [
          [1, 1, 1, 1, 0],
          [1, 0, 0, 0, 1],
          [1, 1, 1, 1, 0],
          [1, 0, 0, 0, 0],
          [1, 0, 0, 0, 0],
          [1, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
        ];
      case 'Q':
        return [
          [0, 1, 1, 1, 0],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [1, 0, 1, 0, 1],
          [1, 0, 0, 1, 1],
          [0, 1, 1, 1, 1],
          [0, 0, 0, 0, 0],
        ];
      case 'R':
        return [
          [1, 1, 1, 1, 0],
          [1, 0, 0, 0, 1],
          [1, 1, 1, 1, 0],
          [1, 0, 1, 0, 0],
          [1, 0, 0, 1, 0],
          [1, 0, 0, 0, 1],
          [0, 0, 0, 0, 0],
        ];
      case 'S':
        return [
          [0, 1, 1, 1, 0],
          [1, 0, 0, 0, 1],
          [0, 1, 1, 0, 0],
          [0, 0, 0, 1, 0],
          [1, 0, 0, 0, 1],
          [0, 1, 1, 1, 0],
          [0, 0, 0, 0, 0],
        ];
      case 'T':
        return [
          [1, 1, 1, 1, 1],
          [0, 0, 1, 0, 0],
          [0, 0, 1, 0, 0],
          [0, 0, 1, 0, 0],
          [0, 0, 1, 0, 0],
          [0, 0, 1, 0, 0],
          [0, 0, 0, 0, 0],
        ];
      case 'U':
        return [
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [0, 1, 1, 1, 0],
          [0, 0, 0, 0, 0],
        ];
      case 'V':
        return [
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [0, 1, 0, 1, 0],
          [0, 1, 0, 1, 0],
          [0, 0, 1, 0, 0],
          [0, 0, 0, 0, 0],
        ];
      case 'W':
        return [
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [1, 0, 1, 0, 1],
          [1, 1, 0, 1, 1],
          [1, 0, 0, 0, 1],
          [0, 0, 0, 0, 0],
        ];
      case 'X':
        return [
          [1, 0, 0, 0, 1],
          [0, 1, 0, 1, 0],
          [0, 0, 1, 0, 0],
          [0, 0, 1, 0, 0],
          [0, 1, 0, 1, 0],
          [1, 0, 0, 0, 1],
          [0, 0, 0, 0, 0],
        ];
      case 'Y':
        return [
          [1, 0, 0, 0, 1],
          [0, 1, 0, 1, 0],
          [0, 0, 1, 0, 0],
          [0, 0, 1, 0, 0],
          [0, 0, 1, 0, 0],
          [0, 0, 1, 0, 0],
          [0, 0, 0, 0, 0],
        ];
      case 'Z':
        return [
          [1, 1, 1, 1, 1],
          [0, 0, 0, 0, 1],
          [0, 0, 0, 1, 0],
          [0, 0, 1, 0, 0],
          [0, 1, 0, 0, 0],
          [1, 1, 1, 1, 1],
          [0, 0, 0, 0, 0],
        ];
      case '0':
        return [
          [0, 1, 1, 1, 0],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [0, 1, 1, 1, 0],
          [0, 0, 0, 0, 0],
        ];
      case '1':
        return [
          [0, 0, 1, 0, 0],
          [0, 1, 1, 0, 0],
          [0, 0, 1, 0, 0],
          [0, 0, 1, 0, 0],
          [0, 0, 1, 0, 0],
          [0, 1, 1, 1, 0],
          [0, 0, 0, 0, 0],
        ];
      case '2':
        return [
          [0, 1, 1, 1, 0],
          [1, 0, 0, 0, 1],
          [0, 0, 0, 1, 0],
          [0, 0, 1, 0, 0],
          [0, 1, 0, 0, 0],
          [1, 1, 1, 1, 1],
          [0, 0, 0, 0, 0],
        ];
      case '3':
        return [
          [0, 1, 1, 1, 0],
          [1, 0, 0, 0, 1],
          [0, 0, 1, 1, 0],
          [0, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [0, 1, 1, 1, 0],
          [0, 0, 0, 0, 0],
        ];
      case '4':
        return [
          [0, 0, 0, 1, 0],
          [0, 0, 1, 1, 0],
          [0, 1, 0, 1, 0],
          [1, 1, 1, 1, 1],
          [0, 0, 0, 1, 0],
          [0, 0, 0, 1, 0],
          [0, 0, 0, 0, 0],
        ];
      case '5':
        return [
          [1, 1, 1, 1, 1],
          [1, 0, 0, 0, 0],
          [1, 1, 1, 1, 0],
          [0, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [0, 1, 1, 1, 0],
          [0, 0, 0, 0, 0],
        ];
      case '6':
        return [
          [0, 1, 1, 1, 0],
          [1, 0, 0, 0, 0],
          [1, 1, 1, 1, 0],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [0, 1, 1, 1, 0],
          [0, 0, 0, 0, 0],
        ];
      case '7':
        return [
          [1, 1, 1, 1, 1],
          [0, 0, 0, 0, 1],
          [0, 0, 0, 1, 0],
          [0, 0, 1, 0, 0],
          [0, 1, 0, 0, 0],
          [0, 1, 0, 0, 0],
          [0, 0, 0, 0, 0],
        ];
      case '8':
        return [
          [0, 1, 1, 1, 0],
          [1, 0, 0, 0, 1],
          [0, 1, 1, 1, 0],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [0, 1, 1, 1, 0],
          [0, 0, 0, 0, 0],
        ];
      case '9':
        return [
          [0, 1, 1, 1, 0],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [0, 1, 1, 1, 1],
          [0, 0, 0, 0, 1],
          [0, 1, 1, 1, 0],
          [0, 0, 0, 0, 0],
        ];
      case ' ':
        return [
          [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
        ];
      case '.':
        return [
          [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 1, 0, 0],
          [0, 0, 0, 0, 0],
        ];
      case ',':
        return [
          [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 1, 0, 0],
          [0, 1, 0, 0, 0],
          [0, 0, 0, 0, 0],
        ];
      case '!':
        return [
          [0, 0, 1, 0, 0],
          [0, 0, 1, 0, 0],
          [0, 0, 1, 0, 0],
          [0, 0, 1, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 1, 0, 0],
          [0, 0, 0, 0, 0],
        ];
      case '?':
        return [
          [0, 1, 1, 1, 0],
          [1, 0, 0, 0, 1],
          [0, 0, 0, 1, 0],
          [0, 0, 1, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 1, 0, 0],
          [0, 0, 0, 0, 0],
        ];
      default:
        // Return a simple pattern for unknown characters
        return [
          [1, 1, 1, 1, 1],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [1, 0, 0, 0, 1],
          [1, 1, 1, 1, 1],
          [0, 0, 0, 0, 0],
        ];
    }
  }
}
