import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:focus_game/widgets/main.dart';

class RocketBackground extends StatefulWidget {
  final Widget child;
  final ui.Image image;
  final double focus;
  final bool isScroll;

  const RocketBackground(
      {Key key, this.image, this.focus, this.child, this.isScroll})
      : super(key: key);

  @override
  _RocketBackgroundState createState() => _RocketBackgroundState();
}

class _RocketBackgroundState extends State<RocketBackground>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  StreamSubscription _focusSubscription;
  ScrollableImageController _scrollableImageController;

  @override
  void initState() {
    super.initState();
    _scrollableImageController = RocketBackgroundController(
        image: widget.image,
        getSpeed: _getSpeed,
        isScroll: () => widget.isScroll);
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller?.dispose(); // called before super.dispose()
    super.dispose();
    _focusSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollableImage(
      scrollableImageController: _scrollableImageController,
      animationController: _controller,
      child: widget.child,
    );
  }

  double _getSpeed() {
    return widget.focus == 0 ? 0 : max(1, widget.focus / 10);
  }
}

class RocketBackgroundController extends ScrollableImageController {
  @override
  void paintDecoration(Canvas canvas, Size size) {
    // todo 绘制流星
  }

  RocketBackgroundController(
      {ui.Image image, double Function() getSpeed, bool Function() isScroll})
      : super(image: image, getSpeed: getSpeed, isScroll: isScroll);
}
