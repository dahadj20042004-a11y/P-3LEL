// lib/widgets/direction_button.dart
import 'package:flutter/material.dart';
import 'dart:ui';

class DirectionButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final VoidCallback onReleased;
  final double size;

  const DirectionButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    required this.onReleased,
    this.size = 72,
  });

  @override
  State<DirectionButton> createState() => _DirectionButtonState();
}

class _DirectionButtonState extends State<DirectionButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDown() {
    setState(() => _isPressed = true);
    _controller.forward();
    widget.onPressed();
  }

  void _handleUp() {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onReleased();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _handleDown(),
      onTapUp: (_) => _handleUp(),
      onTapCancel: _handleUp,
      onPanEnd: (_) => _handleUp(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: _isPressed
                    ? const Color(0xCC2D7A3A)
                    : const Color(0xAA1A2E1A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isPressed
                      ? const Color(0xFF4CAF50)
                      : const Color(0x554CAF50),
                  width: _isPressed ? 2 : 1.2,
                ),
                boxShadow: _isPressed
                    ? [
                        BoxShadow(
                          color: const Color(0xFF4CAF50).withAlpha(80),
                          blurRadius: 16,
                          spreadRadius: 2,
                        )
                      ]
                    : [],
              ),
              child: Icon(
                widget.icon,
                color: _isPressed
                    ? Colors.white
                    : const Color(0xCC90D490),
                size: widget.size * 0.45,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
