import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RadialMenuButton extends StatelessWidget {
  const RadialMenuButton({
    Key? key,
    required this.child,
    required this.backgroundColor,
    required this.onPressed,
  }) : super(key: key);

  final Widget child;
  final Color backgroundColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final Color color = backgroundColor;

    return Semantics(
      button: true,
      enabled: true,
      child: Material(
        type: MaterialType.circle,
        color: color,
        child: InkWell(
          onTap: onPressed,
          child: child,
        ),
      ),
    );
  }
}
