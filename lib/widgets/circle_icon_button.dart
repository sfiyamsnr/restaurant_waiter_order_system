import 'package:flutter/material.dart';

/// A small circular icon button used for compact actions like edit/delete
/// on list cards, and the primary add action in an app bar.
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.background,
    required this.foreground,
    this.size = 36,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final Color background;
  final Color foreground;
  final double size;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: background,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: foreground, size: size * 0.5),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}
