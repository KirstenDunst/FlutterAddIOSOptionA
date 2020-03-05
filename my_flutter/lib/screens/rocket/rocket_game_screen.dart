import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_lottie_brainco/lottie_view.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:focus_game/constants/main.dart';
import 'package:focus_game/redux/main.dart';
import 'package:focus_game/redux/rocket_actions.dart';
import 'package:focus_game/redux/rocket_reducer.dart';
import 'package:focus_game/screens/rocket/rocket_anim_helper.dart';
import 'package:focus_game/screens/rocket/rocket_background.dart';
import 'package:focus_game/utils/main.dart';
import 'package:focus_game/widgets/main.dart';
import 'package:redux/redux.dart';

class RocketScreen extends StatelessWidget {
  static const routeName = RouterConstants.pathRocketGame;
  static const audioUrl =
      'https://focus-resource.oss-cn-beijing.aliyuncs.com/ToB/audio/training_rocket_bg_music.mp3';

  static const _duration = 20;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, RocketViewModel>(
      distinct: true,
      onInit: (store) => store.dispatch(_buildPrepareAction(context)),
      onDispose: (store) => store.dispatch(DisposeAction()),
      converter: RocketViewModel.fromStore,
      builder: (BuildContext context, RocketViewModel vm) =>
          RocketPadPresentation(vm: vm),
    );
  }

  PrepareAction _buildPrepareAction(BuildContext context) {
    Map<dynamic, dynamic> args = ModalRoute.of(context).settings.arguments;
    int duration = _duration;
    if (args != null) {
      duration = args[RouterConstants.argDuration];
    }
    return PrepareAction(
        duration: duration,
        audioUrl: audioUrl,
        backgroundAsset: ImageConstants.rocketBg);
  }
}

class RocketPadPresentation extends StatefulWidget {
  final RocketViewModel vm;

  const RocketPadPresentation({Key key, this.vm}) : super(key: key);

  @override
  _RocketPadPresentationState createState() => _RocketPadPresentationState();
}

class _RocketPadPresentationState extends State<RocketPadPresentation>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
      
  // 创建一个给native的channel (类似iOS的通知）
  static const methodChannel = const MethodChannel('tech.brainco.focusgame/router');

  StreamSubscription<DialogType> _dialogSubscription;
  StreamSubscription<double> _focusSubscription;
  StreamSubscription<GameState> _gameStateSubscription;
  AudioUtil _audioUtil;
  AudioAssetUtil _audioAssetUtil;
  RocketAnimHelper _rocketAnimHelper;

  @override
  void initState() {
    _dialogSubscription = widget.vm.dialogStream.listen(_onDialogStream);
    _rocketAnimHelper = RocketAnimHelper()..init();
    _focusSubscription = widget.vm.focusStream.listen(_onFocusChange);
    _gameStateSubscription =
        widget.vm.gameStateStream.listen(_onGameStateChange);
    _audioUtil = AudioUtil(isLoop: true);
    _audioAssetUtil = AudioAssetUtil();

    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _resume();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        _pause();
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  void _resume() {
    widget.vm.dispatchResume();
  }

  void _pause() {
    widget.vm.dispatchPause();
  }

  @override
  void dispose() {
    _rocketAnimHelper.dispose();
    WidgetsBinding.instance.removeObserver(this);

    _dialogSubscription.cancel();
    _focusSubscription.cancel();
    _gameStateSubscription.cancel();
    _audioUtil.dispose();
    _audioAssetUtil.dispose();

    _shakeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: widget.vm.isLoading
          ? _buildLoading()
          : RocketBackground(
              image: widget.vm.background,
              focus: widget.vm.focus,
              isScroll: widget.vm.isGameRunning && _hasRocketLaunched,
              child: Material(
                type: MaterialType.transparency,
                child: Column(
                  children: <Widget>[
                    _buildGameToolbar(),
                    _buildBody(),
                  ],
                ),
              ),
            ),
    );
  }

  GameToolbar _buildGameToolbar() {
    return GameToolbar(
      title: widget.vm.timeText,
      leftIconOnTap: _onBackPressed,
    );
  }

  Widget _buildLoading() {
    return Container(
      color: Colors.white,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Expanded _buildBody() {
    return Expanded(
      child: Stack(
        children: <Widget>[
          _buildPlanet(),
          _buildSmoke(),
          _buildRocket(),
        ],
      ),
    );
  }

  AnimatedAlign _buildRocket() {
    return AnimatedAlign(
      alignment: _rocketAlignment(),
      duration: _hasRocketLaunched
          ? Duration(seconds: 1)
          : Duration(milliseconds: 100),
      child: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          RocketView(
            focus: widget.vm.focus,
            fireLottieController: _rocketAnimHelper.fireController,
            wingLottieController: _rocketAnimHelper.wingController,
          ),
          AnimatedOpacity(
            opacity: _sonicBarrierOpacity,
            duration: Duration(milliseconds: 300),
            child: Padding(
              padding: const EdgeInsets.only(top: 26.0),
              child: Image.asset(
                ImageConstants.rocketSonicBarrier,
                width: 90.size(),
                height: 90.size(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Alignment _rocketAlignment() {
    return (_hasRocketLaunched || _isRocketReset)
        ? _resetRocketAlign()
        : _nextShakeAlign;
  }

  Align _buildSmoke() {
    return Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
            width: 360.size(),
            height: 120.size(),
            child: LottieView(
                filePath: AnimConstants.rocketLaunchSmoke,
                controller: _rocketAnimHelper.smokeController)));
  }

  AnimatedAlign _buildPlanet() {
    return AnimatedAlign(
      alignment: Alignment(0, _hasRocketLaunched ? widget.vm.planetAlignY : 1),
      duration: Duration(seconds: 1),
      child: Image.asset(ImageConstants.rocketPlanet,
          width: 382.size(), height: 124.size()),
    );
  }

  Future<bool> _onWillPop() {
    return showExitDialog() ?? false;
  }

  Future<bool> showExitDialog() {
    _pause();
    return showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              content: Text('确认要退出专注力训练吗？坚持训练才能提升你的专注力！'),
              actions: <Widget>[
                RoundCornerButton(
                    '继续完成', () => Navigator.of(context).pop(false)),
                RoundCornerButton(
                    '确认退出', () => Navigator.of(context).pop(true)),
              ],
            )).then((value) {
      if (!value) {
        _resume();
      }
      return value;
    });
  }

  _onBackPressed() {
    showExitDialog().then((isPop) => {
          if (isPop) {Navigator.of(context).pop()}
        });
  }

  void _onDialogStream(DialogType type) {
    if (type == DialogType.WaitingForUser) {
      Future.delayed(Duration(seconds: 1), () {
        showDialog<bool>(
            barrierDismissible: false,
            context: context,
            builder: (context) => AlertDialog(
                  content: SizedBox(
                      width: 460.size(),
                      child: Text(
                          '试着用你的注意力来操控一下小火箭吧！你的专注力越高，小火箭飞得越快，专注力越低，小火箭飞得越慢。')),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () => {
                        methodChannel.invokeMethod('csx Test begain','123456'),
                        Navigator.of(context).pop(false)
                      },
                      child: Text('取消'),
                    ),
                    FlatButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text('确认'),
                    ),
                  ],
                )).then((value) {
          if (value) {
            widget.vm.dispatchCountDown();
          } else {
            Navigator.of(context).pop();
          }
        });
      });
    } else if (type == DialogType.CountDown) {
      showDialog(
              context: context,
              barrierDismissible: false,
              builder: _buildCountDown)
          .then((value) {
        widget.vm.dispatchStart();
        _audioAssetUtil.play(AudioConstants.rocketLaunch);
        _rocketAnimHelper.playLaunch();
        _shakeRocket();
        _showSonicBarrier();
        Timer(Duration(seconds: 5), () {
          setState(() {
            _hasRocketLaunched = true;
          });
        });
        _audioUtil.play(widget.vm.audioFile);
      });
    } else if (type == DialogType.Ended) {
      showDialog(
              context: context,
              barrierDismissible: false,
              builder: _buildFinishDialog)
          .then((value) {
        Navigator.of(context).pop();
      });
    }
  }

  Widget _buildCountDown(BuildContext context) {
    return CountDownAnimation();
  }

  FocusLevel _lastFocusLevel = FocusLevel.None;

  void _onFocusChange(double event) {
    FocusLevel level = event.toFocusLevel();

    switch (level) {
      case FocusLevel.None:
      case FocusLevel.Low:
        _onFocusLow();
        break;
      case FocusLevel.Middle:
        _onFocusMid();
        break;
      case FocusLevel.High:
        _onFocusHigh();
        break;
    }
    _lastFocusLevel = level;
  }

  void _onFocusLow() {
    switch (_lastFocusLevel) {
      case FocusLevel.None:
      case FocusLevel.Low:
        break;
      case FocusLevel.Middle:
        _cancelShake();
        _hideSonicBarrier();
        _rocketAnimHelper.playFireNormalToSmall();
        break;
      case FocusLevel.High:
        _cancelShake();
        _hideSonicBarrier();
        _wingBack();
        _rocketAnimHelper.playFireBigToSmall();
        break;
    }
  }

  void _onFocusMid() {
    switch (_lastFocusLevel) {
      case FocusLevel.None:
      case FocusLevel.Low:
        _shakeRocket();
        _showSonicBarrier();
        _rocketAnimHelper.playFireSmallToNormal();
        break;
      case FocusLevel.Middle:
        break;
      case FocusLevel.High:
        _cancelShake();
        _hideSonicBarrier();
        _wingBack();
        _rocketAnimHelper.playFireBigToNormal();
        break;
    }
  }

  void _onFocusHigh() {
    switch (_lastFocusLevel) {
      case FocusLevel.None:
      case FocusLevel.Low:
        _wingExpand();
        _shakeRocket();
        _showSonicBarrier();
        _rocketAnimHelper.playFireSmallToBig();
        break;
      case FocusLevel.Middle:
        _wingExpand();
        _shakeRocket();
        _showSonicBarrier();
        _rocketAnimHelper.playFireNormalToBig();
        break;
      case FocusLevel.High:
        break;
    }
  }

  Widget _buildFinishDialog(BuildContext context) {
    return AlertDialog(
      title: Text('恭喜！训练完成'),
      content: Text('您专注力最佳值xxx'),
      actions: <Widget>[
        FlatButton(
            onPressed: () => {
              methodChannel.invokeMethod('csx Test archive','123456'),
              Navigator.of(context).pop(false)
            },
            child: Text('取消')),
        FlatButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('确定')),
      ],
    );
  }

  bool _hasRocketLaunched = false;
  List<Alignment> shakeRanges = [
    Alignment(-0.005, 0),
    Alignment(0.005, 0),
    Alignment(0, -0.005),
  ];
  int _currentShakeIndex = -1;
  bool _isRocketReset = true;
  Alignment _nextShakeAlign = Alignment(0, 1);

  void _onGameStateChange(GameState gameState) {
    switch (gameState) {
      case GameState.Ended:
        _audioUtil.stop();
        break;
      case GameState.Preparing:
        break;
      case GameState.WaitingForUser:
        break;
      case GameState.CountDownBeforeStart:
        _audioAssetUtil.play(AudioConstants.countdown);
        break;
      case GameState.Started:
        _audioUtil.play(widget.vm.audioFile);
        break;
      case GameState.Paused:
        _audioUtil.pause();
        break;
    }
  }

  Timer _shakeTimer;

  void _shakeRocket() {
    _shakeTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _isRocketReset = !_isRocketReset;

        if (_isRocketReset) return;

        var random = Random().nextInt(shakeRanges.length);
        _currentShakeIndex = random == _currentShakeIndex
            ? (random + 1) % shakeRanges.length
            : random;
        var shakeRange = shakeRanges[_currentShakeIndex];
        _nextShakeAlign =
            Alignment(shakeRange.x, _resetRocketAlign().y + shakeRange.y);
      });
    });
    Timer(Duration(seconds: 3), () {
      setState(() {
        _shakeTimer?.cancel();
      });
    });
  }

  Alignment _resetRocketAlign() => _nextShakeAlign =
      Alignment(0, _hasRocketLaunched ? widget.vm.rocketAlignY : 1);

  double _sonicBarrierOpacity = 0;

  void _showSonicBarrier() {
    setState(() {
      _sonicBarrierOpacity = 1;
    });
    Timer(Duration(seconds: 3), () {
      setState(() {
        _sonicBarrierOpacity = 0;
      });
    });
  }

  void _hideSonicBarrier() {
    if (_sonicBarrierOpacity == 0) return;
    setState(() {
      _sonicBarrierOpacity = 0;
    });
  }

  void _cancelShake() {
    _shakeTimer?.cancel();
    setState(() {
      _resetRocketAlign();
    });
  }

  void _wingBack() {
    _rocketAnimHelper.playWingBack();
  }

  void _wingExpand() {
    _audioAssetUtil.play(AudioConstants.rocketWingExpand);
    _rocketAnimHelper.playWingExpand();
  }
}

class RocketViewModel {
  final int duration;
  final int usedTime;
  final GameState gameState;
  final double focus;
  final ui.Image background;
  final String audioFile;
  final Function() dispatchRun;
  final Function() dispatchCountDown;
  final Function() dispatchStart;
  final Function() dispatchPause;
  final Function() dispatchResume;
  final Stream<GameState> gameStateStream;
  final Stream<DialogType> dialogStream;
  final Stream<double> focusStream;

  double get planetAlignY => gameState.index >= GameState.Started.index ? 2 : 1;

  double get rocketAlignY {
    return gameState == GameState.Ended
        ? -3
        : (gameState.index >= GameState.Started.index
            ? ((50 - focus) / 50)
            : 1);
  }

  bool get isLoading => gameState == GameState.Preparing;

  String get timeText =>
      Duration(seconds: duration - usedTime).toString().substring(2, 7);

  bool get isGameRunning => gameState == GameState.Started;

  RocketViewModel({
    this.duration,
    this.usedTime,
    this.gameState,
    this.focus,
    this.background,
    this.audioFile,
    this.dispatchRun,
    this.dispatchCountDown,
    this.dispatchStart,
    this.dispatchPause,
    this.dispatchResume,
    this.gameStateStream,
    this.dialogStream,
    this.focusStream,
  });

  static RocketViewModel fromStore(Store<AppState> store) {
    var rocket = store.state.rocket;
    return RocketViewModel(
      duration: rocket.duration,
      usedTime: rocket.usedTime,
      gameState: rocket.gameState,
      focus: rocket.focus,
      background: rocket.background,
      audioFile: rocket.audioFile,
      gameStateStream: rocket.gameStateController.stream,
      dialogStream: rocket.dialogController.stream,
      focusStream: rocket.focusController.stream,
      dispatchRun: () => store.dispatch(RunAction()),
      dispatchCountDown: () => store.dispatch(CountDownAction()),
      dispatchStart: () => store.dispatch(StartAction()),
      dispatchPause: () => store.dispatch(PauseAction()),
      dispatchResume: () => store.dispatch(ResumeAction()),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RocketViewModel &&
          runtimeType == other.runtimeType &&
          duration == other.duration &&
          usedTime == other.usedTime &&
          gameState == other.gameState &&
          focus == other.focus &&
          background == other.background &&
          dialogStream == other.dialogStream &&
          focusStream == other.focusStream;

  @override
  int get hashCode =>
      duration.hashCode ^
      usedTime.hashCode ^
      gameState.hashCode ^
      focus.hashCode ^
      background.hashCode ^
      dialogStream.hashCode ^
      focusStream.hashCode;
}

enum FocusLevel { None, Low, Middle, High }

extension on num {
  FocusLevel toFocusLevel() {
    if (this == 0) {
      return FocusLevel.None;
    } else if (this < 35) {
      return FocusLevel.Low;
    } else if (this < 65) {
      return FocusLevel.Middle;
    } else {
      return FocusLevel.High;
    }
  }
}
