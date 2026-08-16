import 'package:flutter/material.dart';

class AnimatedPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double pressScale;

  const AnimatedPressable({
    super.key,
    required this.child,
    this.onPressed,
    this.pressScale = 0.97,
  });

  @override
  State<AnimatedPressable> createState() => _AnimatedPressableState();
}

class _AnimatedPressableState extends State<AnimatedPressable> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (widget.onPressed != null) setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        if (widget.onPressed != null) setState(() => _isPressed = false);
      },
      onTapCancel: () {
        if (widget.onPressed != null) setState(() => _isPressed = false);
      },
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _isPressed ? widget.pressScale : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.decelerate,
        child: widget.child,
      ),
    );
  }
}
