import 'dart:async';

import 'package:flutter/services.dart';
import 'package:focus_game/constants/main.dart';
import 'package:focus_game/models/main.dart';

class RouterService {
  static MethodChannel _channel = MethodChannel(RouterConstants.channelName);

  static StreamController<RouterInfo> _routerController =
      StreamController.broadcast();

  static Stream<RouterInfo> get stream => _routerController.stream;

  static navigate(String path, Map<dynamic, dynamic> args) {
    _channel.invokeMethod(RouterConstants.method, args);
  }

  static init() {
    print('RouterService init');
    _channel.setMethodCallHandler(_handler);
  }

  static Future _handler(MethodCall call) async {
    print('RouterService _handler ${call.method}');
    switch (call.method) {
      case RouterConstants.method:
        SystemChrome.setPreferredOrientations(
            [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
        _routerController.add(RouterInfo.fromMap(call.arguments));
        break;
      default:
        return MissingPluginException();
    }
    return true;
  }
}
