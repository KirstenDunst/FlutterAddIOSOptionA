import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:focus_game/constants/focus_constants.dart';
import 'package:focus_game/constants/headband_constants.dart';

class HeadbandService {
  static final MethodChannel _channel =
      MethodChannel(HeadbandConstants.channelName);

  static StreamController<bool> _isContactController =
      StreamController.broadcast();
  static StreamController<double> _focusValueController =
      StreamController.broadcast();

  static Stream<bool> get isContactStream => _isContactController.stream;

  static Stream<double> get focusValueStream => _focusValueController.stream;

  static init() {
    _channel.setMethodCallHandler(_handler);
  }

  static double _focusMock = 30;

  static mock() {
    _isContactController.add(true);
    Timer.periodic(FocusConstants.refreshInterval, (timer) {
      _focusMock = (_focusMock +
              Random().nextDouble() * (Random().nextBool() ? 10 : -15)) %
          100;
      return _focusValueController.add(_focusMock);
    });
  }

  static Future _handler(MethodCall call) async {
    switch (call.method) {
      case HeadbandConstants.methodIsHeadbandContact:
        _isContactController.add(call.arguments);
        break;
      case HeadbandConstants.methodFocusValue:
        _focusValueController.add(call.arguments);
        break;
      default:
        return MissingPluginException();
    }
    return true;
  }
}
