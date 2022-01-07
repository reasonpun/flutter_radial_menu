import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_radial_menu/radial/src/arc_progress_indicator.dart';
import 'package:flutter_radial_menu/radial/src/radial_menu_button.dart';
import 'package:flutter_radial_menu/radial/src/radial_menu_center_button.dart';
import 'package:flutter_radial_menu/radial/src/radial_menu_item.dart';

const double _radiansPerDegree = math.pi / 180;
const double _startAngle = -150.0 * _radiansPerDegree;

typedef ItemAngleCalculator = double Function(int index);

/// A radial menu for selecting from a list of items.
///
/// A radial menu lets the user select from a number of items. It displays a
/// button that opens the menu, showing its items arranged in an arc. Selecting
/// an item triggers the animation of a progress bar drawn at the specified
/// [radius] around the central menu button.
///
/// The type `T` is the type of the values the radial menu represents. All the
/// entries in a given menu must represent values with consistent types.
/// Typically, an enum is used. Each [RadialMenuItem] in [items] must be
/// specialized with that same type argument.
///
/// Requires one of its ancestors to be a [Material] widget.
///
/// See also:
///
///  * [RadialMenuItem], the widget used to represent the [items].
///  * [RadialMenuCenterButton], the button used to open and close the menu.
class RadialMenu<T> extends StatefulWidget {
  /// Creates a dropdown button.
  ///
  /// The [items] must have distinct values.
  ///
  /// The [radius], [menuAnimationDuration], and [progressAnimationDuration]
  /// arguments must not be null (they all have defaults, so do not need to be
  /// specified).
  const RadialMenu({
    Key? key,
    required this.items,
    required this.onSelected,
    this.radius = 100.0,
    this.menuAnimationDuration = const Duration(milliseconds: 1000),
    this.progressAnimationDuration = const Duration(milliseconds: 1000),
  }) : super(key: key);

  /// The list of possible items to select among.
  final List<RadialMenuItem<T>> items;

  /// Called when the user selects an item.
  final ValueChanged<T> onSelected;

  /// The radius of the arc used to lay out the items and draw the progress bar.
  ///
  /// Defaults to 100.0.
  final double radius;

  /// Duration of the menu opening/closing animation.
  ///
  /// Defaults to 1000 milliseconds.
  final Duration menuAnimationDuration;

  /// Duration of the action activation progress arc animation.
  ///
  /// Defaults to 1000 milliseconds.
  final Duration progressAnimationDuration;

  @override
  RadialMenuState createState() => RadialMenuState();
}

class RadialMenuState extends State<RadialMenu> with TickerProviderStateMixin {
  late AnimationController _menuAnimationController;
  late AnimationController _progressAnimationController;
  bool _isOpen = false;
  int _activeItemIndex = -1;

  // todo: xqwzts: allow users to pass in their own calculator as a param.
  // and change this to the default: radialItemAngleCalculator.
  double calculateItemAngle(int index) {
    double _itemSpacing = 360.0 / widget.items.length;
    return _startAngle + index * _itemSpacing * _radiansPerDegree;
  }

  @override
  void initState() {
    super.initState();
    _menuAnimationController = AnimationController(
      duration: widget.menuAnimationDuration,
      vsync: this,
    );
    _progressAnimationController = AnimationController(
      duration: widget.progressAnimationDuration,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _menuAnimationController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  void _openMenu() {
    _menuAnimationController.forward();
    setState(() => _isOpen = true);
  }

  void _closeMenu() {
    _menuAnimationController.reverse();
    setState(() => _isOpen = false);
  }

  Future<void> _activate(int itemIndex) async {
    setState(() => _activeItemIndex = itemIndex);
    await _progressAnimationController.forward().orCancel;
    widget.onSelected(widget.items[itemIndex].value);
  }

  /// Resets the menu to its initial (closed) state.
  void reset() {
    _menuAnimationController.reset();
    _progressAnimationController.reverse();
    setState(() {
      _isOpen = false;
      _activeItemIndex = -1;
    });
  }

  Widget _buildActionButton(int index) {
    final RadialMenuItem item = widget.items[index];

    return LayoutId(
      id: '${_RadialMenuLayout.actionButton}$index',
      child: RadialMenuButton(
        child: item,
        backgroundColor: item.backgroundColor,
        onPressed: () => _activate(index),
      ),
    );
  }

  Widget _buildActiveAction(int index) {
    final RadialMenuItem item = widget.items[index];

    return LayoutId(
      id: '${_RadialMenuLayout.activeAction}$index',
      child: ArcProgressIndicator(
        controller: _progressAnimationController.view,
        radius: widget.radius,
        color: item.backgroundColor,
        icon: (item.child as Icon).icon!,
        iconColor: item.iconColor,
        startAngle: calculateItemAngle(index),
        width: double.infinity,
      ),
    );
  }

  Widget _buildCenterButton() {
    return LayoutId(
      id: _RadialMenuLayout.menuButton,
      child: RadialMenuCenterButton(
        openCloseAnimationController: _menuAnimationController.view,
        activateAnimationController: _progressAnimationController.view,
        isOpen: _isOpen,
        onPressed: _isOpen ? _closeMenu : _openMenu,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];

    for (int i = 0; i < widget.items.length; i++) {
      if (_activeItemIndex != i) {
        children.add(_buildActionButton(i));
      }
    }

    if (_activeItemIndex != -1) {
      children.add(_buildActiveAction(_activeItemIndex));
    }
    children.add(_buildCenterButton());

    return AnimatedBuilder(
      animation: _menuAnimationController,
      builder: (BuildContext context, Widget? child) {
        return CustomMultiChildLayout(
          delegate: _RadialMenuLayout(
            itemCount: widget.items.length,
            radius: widget.radius,
            calculateItemAngle: calculateItemAngle,
            controller: _menuAnimationController.view,
          ),
          children: children,
        );
      },
    );
  }
}

class _RadialMenuLayout extends MultiChildLayoutDelegate {
  static const String menuButton = 'menuButton';
  static const String actionButton = 'actionButton';
  static const String activeAction = 'activeAction';

  final int itemCount;
  final double radius;
  final ItemAngleCalculator calculateItemAngle;

  final Animation<double> controller;

  final Animation<double> _progress;

  _RadialMenuLayout({
    required this.itemCount,
    required this.radius,
    required this.calculateItemAngle,
    required this.controller,
  }) : _progress = Tween<double>(begin: 0.0, end: radius).animate(
          CurvedAnimation(
            curve: Curves.elasticOut,
            parent: controller,
          ),
        );

  late Offset center;

  @override
  void performLayout(Size size) {
    center = Offset(size.width / 2, size.height / 2);

    if (hasChild(menuButton)) {
      Size menuButtonSize;
      menuButtonSize = layoutChild(menuButton, BoxConstraints.loose(size));

      // place the menubutton in the center
      positionChild(
        menuButton,
        Offset(
          center.dx - menuButtonSize.width / 2,
          center.dy - menuButtonSize.height / 2,
        ),
      );
    }

    for (int i = 0; i < itemCount; i++) {
      final String actionButtonId = '$actionButton$i';
      final String actionArcId = '$activeAction$i';
      if (hasChild(actionArcId)) {
        final Size arcSize = layoutChild(
          actionArcId,
          BoxConstraints.expand(
            width: _progress.value * 2,
            height: _progress.value * 2,
          ),
        );

        positionChild(
          actionArcId,
          Offset(
            center.dx - arcSize.width / 2,
            center.dy - arcSize.height / 2,
          ),
        );
      }

      if (hasChild(actionButtonId)) {
        final Size buttonSize =
            layoutChild(actionButtonId, BoxConstraints.loose(size));

        final double itemAngle = calculateItemAngle(i);

        positionChild(
          actionButtonId,
          Offset(
            (center.dx - buttonSize.width / 2) +
                (_progress.value) * math.cos(itemAngle),
            (center.dy - buttonSize.height / 2) +
                (_progress.value) * math.sin(itemAngle),
          ),
        );
      }
    }
  }

  @override
  bool shouldRelayout(_RadialMenuLayout oldDelegate) =>
      itemCount != oldDelegate.itemCount ||
      radius != oldDelegate.radius ||
      calculateItemAngle != oldDelegate.calculateItemAngle ||
      controller != oldDelegate.controller ||
      _progress != oldDelegate._progress;
}
