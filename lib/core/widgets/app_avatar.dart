import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppAvatar extends StatelessWidget {
  final int avatarIndex;
  final double size;
  final bool isSelected;
  final VoidCallback? onTap;

  const AppAvatar({
    super.key,
    required this.avatarIndex,
    this.size = 64,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Elegant theme-matching color gradients for the 8 avatar options
    final List<List<Color>> gradients = [
      [const Color(0xFF1E3A8A), const Color(0xFF3B82F6)], // Alexander: Deep Blue to Royal Blue
      [const Color(0xFFDB2777), const Color(0xFF8B5CF6)], // Sophia: Rose Pink to Violet Purple
      [const Color(0xFF00F2FE), const Color(0xFF4FACFE)], // Pixel-1: Neon Cyan to Electric Blue
      [const Color(0xFFF59E0B), const Color(0xFFEF4444)], // Felix: Orange to Amber Red
      [const Color(0xFF10B981), const Color(0xFF059669)], // Koko: Soft Mint to Emerald Green
      [const Color(0xFFEC4899), const Color(0xFFF43F5E)], // Leo: Pink to Rose Red
      [const Color(0xFF84CC16), const Color(0xFF10B981)], // Rex: Lime to Emerald Green
      [const Color(0xFF8B5CF6), const Color(0xFFEC4899)], // Nova: Cosmic Purple to Magenta
    ];

    final List<String> emojis = ['👨‍🎓', '👩‍🎓', '🤖', '🦊', '🐨', '🦁', '🦖', '🦄'];

    final index = (avatarIndex >= 0 && avatarIndex < emojis.length) ? avatarIndex : 0;
    final gradient = gradients[index];
    final emoji = emojis[index];

    Widget avatarContent = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.35),
            blurRadius: size * 0.25,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          emoji,
          style: TextStyle(
            fontSize: size * 0.52,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(1, 2),
              ),
            ],
          ),
        ),
      ),
    );

    if (onTap != null || isSelected) {
      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? AppColors.brightGreen : Colors.transparent,
              width: 3,
            ),
          ),
          child: avatarContent,
        ),
      );
    }

    return avatarContent;
  }
}
