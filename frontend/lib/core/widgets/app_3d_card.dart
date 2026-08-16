import 'package:flutter/material.dart';

class App3DCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? color;
  final VoidCallback? onTap;
  final double scaleOnHover;
  final double elevation;

  const App3DCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.color,
    this.onTap,
    this.scaleOnHover = 1.015,
    this.elevation = 4.0,
  });

  @override
  State<App3DCard> createState() => _App3DCardState();
}

class _App3DCardState extends State<App3DCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveRadius = widget.borderRadius ?? BorderRadius.circular(16);
    final effectiveColor = widget.color ?? (isDark ? const Color(0xFF1E293B) : Colors.white);

    double currentScale = 1.0;
    if (_isPressed) {
      currentScale = 0.985;
    } else if (_isHovered) {
      currentScale = widget.scaleOnHover;
    }

    final double shadowBlur = _isHovered ? (widget.elevation * 3) : (widget.elevation * 2);
    final double shadowOffsetY = _isHovered ? (widget.elevation * 1.5) : (widget.elevation * 0.8);
    final double shadowOpacity = _isHovered
        ? (isDark ? 0.35 : 0.08)
        : (isDark ? 0.20 : 0.04);

    return Container(
      margin: widget.margin,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: currentScale,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              padding: widget.padding ?? const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: effectiveColor,
                borderRadius: effectiveRadius,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: shadowOpacity),
                    blurRadius: shadowBlur,
                    offset: Offset(0, shadowOffsetY),
                  ),
                ],
                border: Border.all(
                  color: _isHovered
                      ? const Color(0xFF2563EB).withValues(alpha: 0.3)
                      : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                  width: 1,
                ),
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
