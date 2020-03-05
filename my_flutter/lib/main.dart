import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:focus_game/platform/headband_service.dart';
import 'package:focus_game/platform/router_service.dart';
import 'package:focus_game/redux/main.dart';
import 'package:focus_game/screens/rocket/rocket_game_screen.dart';
import 'package:focus_game/utils/main.dart';

import 'constants/main.dart';
import 'models/main.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreProvider(
      store: StoreContainer.global,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: FontConstants.defFont,
        ),
        routes: routes,
        home: MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

Map<String, WidgetBuilder> routes = {
  RocketScreen.routeName: (context) => RocketScreen(),
};

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    RouterService.init();
    RouterService.stream.listen(_route);
    HeadbandService.init();
    HeadbandService.mock();
    PaintingBinding.instance.imageCache.maximumSizeBytes = 150 << 20;
  }

  @override
  Widget build(BuildContext context) {
    ScreenAdapterUtil.init(context, width: 1280, height: 800);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('HomePage!'),
            OutlineButton(
              child: Text(RocketScreen.routeName),
              onPressed: () =>
                  Navigator.pushNamed(context, RocketScreen.routeName),
            ),
            OutlineButton(
              child: Text('Audio start'),
              onPressed: _playAudio,
            ),
            OutlineButton(
              child: Text('Audio stop'),
              onPressed: _stopAudio,
            ),
            OutlineButton(
              child: Text('Audio pause'),
              onPressed: _pauseAudio,
            ),
            OutlineButton(
              child: Text('Asset Audio start'),
              onPressed: _playAssetAudio,
            ),
            OutlineButton(
              child: Text('Asset Audio stop'),
              onPressed: _stopAssetAudio,
            ),
            OutlineButton(
              child: Text('Asset Audio loop'),
              onPressed: _loopAssetAudio,
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onFabClicked,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  void _onFabClicked() {}

  void _route(RouterInfo event) {
    print('Jike route ${event.path}');
    Navigator.pushReplacementNamed(context, event.path, arguments: event.data);
  }

  AudioUtil _audioUtil;

  void _playAudio() async {
    final file = await AudioUtil.loadFile(RocketScreen.audioUrl);
    print('loadedFile=$file');
    if (_audioUtil == null) {
      _audioUtil = AudioUtil(isLoop: true);
    }
    final suc = await _audioUtil.play(file);
    print('play suc=$suc');
  }

  void _stopAudio() {
    _audioUtil?.stop();
  }

  void _pauseAudio() {
    _audioUtil?.pause();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
    _audioUtil?.dispose();
    _audioAssetUtil?.dispose();
  }

  AudioAssetUtil _audioAssetUtil;

  void _playAssetAudio() {
    if (_audioAssetUtil == null) {
      _audioAssetUtil = AudioAssetUtil();
    }
    _audioAssetUtil.play(AudioConstants.rocketWingExpand);
  }

  void _stopAssetAudio() {
    _audioAssetUtil?.stop();
  }

  void _loopAssetAudio() {
    _audioAssetUtil.loop(AudioConstants.rocketWingExpand);
  }
}
