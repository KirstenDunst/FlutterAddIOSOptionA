
import 'dart:async';
import 'dart:convert' as convert;
import 'package:flutter/services.dart';
import 'package:focus_game/constants/main.dart';
import 'package:focus_game/models/main.dart';

class RouterService {
  static MethodChannel _channel = MethodChannel(RouterConstants.channelName);
  // 注册一个通知,监听原生传给自己的值
  static EventChannel _eventChannel = EventChannel(RouterConstants.channelName);

  static StreamController<RouterInfo> _routerController =
      StreamController.broadcast();

  static Stream<RouterInfo> get stream => _routerController.stream;

  static navigate(String path, Map<dynamic, dynamic> args) {
    _channel.invokeMethod(RouterConstants.method, args);
  }

  static init() {
    print("实例化channel：" + _channel.name);
    _channel.setMethodCallHandler(_handler);
     // 监听事件，同时发送参数：启动监听
    _eventChannel.receiveBroadcastStream('启动监听').listen(_onEvent,onError: _onError);
  }

  // 回调事件
  static void _onEvent(Object event){
    print('eventChannel回掉：' + event);
    Map<String, dynamic> map = convert.jsonDecode(event) as Map<String, dynamic> ;
    // print('channel回掉添加参数：' + map.toString());
    _routerController.add(RouterInfo.fromMap(map[RouterConstants.method]));
  }

  // 错误返回
  static void _onError(Object error) {

  }

  static Future _handler(MethodCall call) async {
    print('收到的method：' + call.method + "arguments:" + call.arguments);
    switch (call.method) {
      case RouterConstants.method:
        _routerController.add(RouterInfo.fromMap(call.arguments));
        break;
      default:
        return MissingPluginException();
    }
    return true;
  }
}
