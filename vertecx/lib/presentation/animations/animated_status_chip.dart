// lib/presentation/animations/animated_status_chip.dart
import 'package:flutter/material.dart';

class AnimatedStatusChip extends StatefulWidget {
  final String label;
  final Color bgColor;
  final Color textColor;
  final VoidCallback onPressed;

  const AnimatedStatusChip({
    super.key,
    required this.label,
    required this.bgColor,
    required this.textColor,
    required this.onPressed,
  });

  @override
  State<AnimatedStatusChip> createState() => _AnimatedStatusChipState();
}

class _AnimatedStatusChipState extends State<AnimatedStatusChip> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() => _scale = 0.7);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _scale = 1.0);
    widget.onPressed();
  }

  void _onTapCancel() {
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: _onTapUp,
      onTapDown: _onTapDown,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 50),
        curve: Curves.easeInOut,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: widget.bgColor,
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.textColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
