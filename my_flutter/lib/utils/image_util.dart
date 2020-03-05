import 'dart:ui';

import 'package:flutter/services.dart';
import 'dart:ui' as ui;

class ImageUtil {

  static double getWidth() {
    return  ui.window.physicalSize.width;
  }
  static double getPixelRatio () {
    return ui.window.devicePixelRatio;
  }
  static double getHeight() {
    return  ui.window.physicalSize.height;
  }

  static Future<ui.Image> getImage(String asset) async {
    ByteData data = await rootBundle.load(asset);
    Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

}