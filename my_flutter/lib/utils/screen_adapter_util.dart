import 'package:flutter/material.dart';

class ScreenAdapterUtil {
  static ScreenAdapterUtil _instance;
  static const int defaultWidth = 375;
  static const int defaultHeight = 667;

  /// UI设计尺寸
  num designWidth;
  num designHeight;

  /// 按宽还是高缩放
  bool scaleByWidth;

  /// 控制字体是否要根据系统的“字体大小”辅助选项来进行缩放。默认值为false。
  bool allowFontScaling;

  static MediaQueryData _mediaQueryData;
  static double _screenWidth;
  static double _screenHeight;
  static double _pixelRatio;
  static double _statusBarHeight;
  static double _bottomBarHeight;
  static double _textScaleFactor;

  ScreenAdapterUtil._();

  factory ScreenAdapterUtil() {
    return _instance;
  }

  static void init(BuildContext context,
      {num width = defaultWidth,
      num height = defaultHeight,
      bool scaleByWidth = true,
      bool allowFontScaling = false}) {
    if (_instance == null) {
      _instance = ScreenAdapterUtil._();
    }
    _instance.designWidth = width;
    _instance.designHeight = height;
    _instance.scaleByWidth = scaleByWidth;
    _instance.allowFontScaling = allowFontScaling;

    MediaQueryData mediaQuery = MediaQuery.of(context);
    _mediaQueryData = mediaQuery;
    _pixelRatio = mediaQuery.devicePixelRatio;
    _screenWidth = mediaQuery.size.width;
    _screenHeight = mediaQuery.size.height;
    _statusBarHeight = mediaQuery.padding.top;
    _bottomBarHeight = _mediaQueryData.padding.bottom;
    _textScaleFactor = mediaQuery.textScaleFactor;
    print('_pixelRatio=$_pixelRatio');
    print('_screenWidth=$_screenWidth');
    print('_screenHeight=$_screenHeight');
  }

  static MediaQueryData get mediaQueryData => _mediaQueryData;

  /// 每个逻辑像素的字体像素数，字体的缩放比例
  /// The number of font pixels for each logical pixel.
  static double get textScaleFactor => _textScaleFactor;

  /// 设备的像素密度
  static double get pixelRatio => _pixelRatio;

  /// 当前设备宽度 dp
  static double get screenWidthDp => _screenWidth;

  ///当前设备高度 dp
  static double get screenHeightDp => _screenHeight;

  /// 当前设备宽度 px
  static double get screenWidth => _screenWidth * _pixelRatio;

  /// 当前设备高度 px
  static double get screenHeight => _screenHeight * _pixelRatio;

  /// 状态栏高度 dp 刘海屏会更高
  static double get statusBarHeight => _statusBarHeight;

  /// 底部安全区距离 dp
  static double get bottomBarHeight => _bottomBarHeight;

  /// 实际的dp与UI设计px的比例
  double get scaleWidth => _screenWidth / designWidth;
  double get scaleHeight => _screenHeight / designHeight;
}

extension ScreenAdapter on num {
  num size({bool scaleByWidth = true}) {
    bool byWidth = scaleByWidth ?? ScreenAdapterUtil().scaleByWidth;
    return this *
        (byWidth
            ? ScreenAdapterUtil().scaleWidth
            : ScreenAdapterUtil().scaleHeight);
  }

  num font({bool scaleByWidth = true}) {
    bool byWidth = scaleByWidth ?? ScreenAdapterUtil().scaleByWidth;
    return this *
        (byWidth
            ? ScreenAdapterUtil().scaleWidth
            : ScreenAdapterUtil().scaleHeight);
  }

  num dp2px() {
    return this * ScreenAdapterUtil.pixelRatio;
  }

  num px2dp() {
    return this / ScreenAdapterUtil.pixelRatio;
  }
}
