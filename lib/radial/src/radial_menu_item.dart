import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const double _defaultButtonSize = 48.0;

/// An item in a [RadialMenu].
///
/// The type `T` is the type of the value the entry represents. All the entries
/// in a given menu must represent values with consistent types.
class RadialMenuItem<T> extends StatelessWidget {
  /// Creates a circular action button for an item in a [RadialMenu].
  ///
  /// The [child] argument is required.
  const RadialMenuItem({
    Key? key,
    required this.child,
    required this.value,
    required this.tooltip,
    this.size = _defaultButtonSize,
    required this.backgroundColor,
    required this.iconColor,
    this.iconSize = 24.0,
  }) : super(key: key);

  /// The widget below this widget in the tree.
  ///
  /// Typically an [Icon] widget.
  final Widget child;

  /// The value to return if the user selects this menu item.
  ///
  /// Eventually returned in a call to [RadialMenu.onSelected].
  final T value;

  /// Text that describes the action that will occur when the button is pressed.
  ///
  /// This text is displayed when the user long-presses on the button and is
  /// used for accessibility.
  final String tooltip;

  /// The color to use when filling the button.
  ///
  /// Defaults to the primary color of the current theme.
  final Color backgroundColor;

  /// The size of the button.
  ///
  /// Defaults to 48.0.
  final double size;

  /// The color to use when painting the child icon.
  ///
  /// Defaults to the primary icon theme color.
  final Color? iconColor;

  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final Color? _iconColor =
        iconColor ?? Theme.of(context).primaryIconTheme.color;

    late Widget result;

    result = Center(
      child: IconTheme.merge(
        data: IconThemeData(
          color: _iconColor,
          size: iconSize,
        ),
        child: child,
      ),
    );

    result = Tooltip(
      message: tooltip,
      child: result,
    );

    result = SizedBox(
      width: size,
      height: size,
      child: result,
    );

    return result;
  }
}
