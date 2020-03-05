import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:focus_game/utils/main.dart';

class ScrollableImage extends StatelessWidget {
  final ScrollableImageController scrollableImageController;
  final Widget child;
  final AnimationController animationController;

  ScrollableImage(
      {@required this.scrollableImageController, @required this.animationController, this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: animationController,
        child: child,
        builder: (context, child) {
          return CustomPaint(
            painter: ScrollableImagePainter(controller: scrollableImageController),
            child: child,
          );
        });
  }
}

class ScrollableImagePainter extends CustomPainter {
  final ScrollableImageController controller;

  ScrollableImagePainter({@required this.controller});

  @override
  void paint(Canvas canvas, Size size) {
    controller.paint(canvas, size);
  }

  @override
  bool shouldRepaint(ScrollableImagePainter oldDelegate) {
    return controller.isScroll();
  }
}

class ScrollableImageController {
  final String tag = 'ScrollableImageController';
  final Paint backgroundPaint = Paint();

  /// 加载的背景图片
  final ui.Image image;

  /// 画布滚动的速度
  final double Function() getSpeed;

  /// 是否滚动
  final bool Function() isScroll;

  final double _imageWidth;
  final double _imageHeight;

  /// 背景图的右下角纵坐标点
  double _yBottom = 0.0;

  ScrollableImageController(
      {@required this.image, this.getSpeed, this.isScroll})
      : _imageWidth = image.width.toDouble(),
        _imageHeight = image.height.toDouble(),
        _yBottom = image.height.toDouble();

  void paint(Canvas canvas, Size size) {
    paintDecoration(canvas, size);

    double yTop = _yBottom - size.height.dp2px(); // 假设图片比屏幕高
    if (yTop >= 0) {
      canvas.drawImageRect(
          image,
          Rect.fromPoints(Offset(0, yTop), Offset(_imageWidth, _yBottom)),
          Rect.fromPoints(Offset(0, 0), Offset(size.width, size.height)),
          backgroundPaint);
    } else {
      // 2张图拼接
      canvas.drawImageRect(
          image,
          Rect.fromPoints(Offset(0, 0), Offset(_imageWidth, _yBottom)),
          Rect.fromPoints(Offset(0, size.height - _yBottom.px2dp()),
              Offset(size.width, size.height)),
          backgroundPaint);
      double gap = size.height.dp2px() - _yBottom;
      canvas.drawImageRect(
          image,
          Rect.fromPoints(
              Offset(0, _imageHeight - gap), Offset(_imageWidth, _imageHeight)),
          Rect.fromPoints(Offset(0, 0), Offset(size.width, gap.px2dp())),
          backgroundPaint);
    }

    if (isScroll()) {
      _yBottom -= getSpeed();
    }
    if (_yBottom <= 0) {
      _yBottom = _imageHeight;
    }
  }

  void paintDecoration(Canvas canvas, Size size) {}
}
