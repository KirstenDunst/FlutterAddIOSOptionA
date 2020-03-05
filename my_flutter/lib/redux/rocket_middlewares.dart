import 'dart:async';

import 'package:focus_game/platform/headband_service.dart';
import 'package:focus_game/redux/main.dart';
import 'package:focus_game/redux/redux.dart';
import 'package:focus_game/redux/rocket_actions.dart';
import 'package:focus_game/repository/repositories.dart';
import 'package:focus_game/utils/image_util.dart';
import 'package:focus_game/utils/main.dart';
import 'package:redux/redux.dart';

class RocketMiddlewareFactory extends MiddlewareFactory {
  RocketMiddlewareFactory(AppRepository repository) : super(repository);
  StreamSubscription _focusSubscription;
  Timer _timer;
  int _usedTime = 0;
  int _duration = 0;

  @override
  List<Middleware<AppState>> generate() {
    return [
      TypedMiddleware<AppState, PrepareAction>(_onPrepare),
      TypedMiddleware<AppState, StartAction>(_onStart),
      TypedMiddleware<AppState, PauseAction>(_onPause),
      TypedMiddleware<AppState, ResumeAction>(_onResume),
      TypedMiddleware<AppState, EndAction>(_onEnd),
      TypedMiddleware<AppState, DisposeAction>(_onDispose),
    ];
  }

  void _onPrepare(Store<AppState> store, PrepareAction action, next) async {
    next(action);
    _duration = action.duration;
    var image = await ImageUtil.getImage(action.backgroundAsset);
    String audioFile = await AudioUtil.loadFile(action.audioUrl);

    next(HavePreparedAction(image, audioFile));
  }

  void _onStart(Store<AppState> store, StartAction action, next) {
    _listenFocus(next);
    _timerTick(next);
    next(action);
  }

  void _listenFocus(next) {
    _focusSubscription = HeadbandService.focusValueStream
        .listen((focus) => next(FocusChangeAction(focus)));
  }

  void _timerTick(next) {
    _timer = Timer.periodic(Duration(seconds: 1), (timer){
      _usedTime ++;
      next(UsedTimeChangeAction(_usedTime));
      if (_usedTime == _duration) {
        next(EndAction());
        timer.cancel();
      }
    });
  }

  void _onDispose(Store<AppState> store, DisposeAction action, next) {
    _focusSubscription?.cancel();
    _timer?.cancel();
    _usedTime = 0;
    next(action);
  }

  void _onPause(Store<AppState> store, PauseAction action,  next) {
    _timer?.cancel();
    _focusSubscription?.cancel();
    next(action);
  }

  void _onResume(Store<AppState> store, ResumeAction action,  next) {
    if (store.state.rocket.gameState == GameState.Paused) {
      _listenFocus(next);
      _timerTick(next);
    }
    next(action);
  }

  void _onEnd(Store<AppState> store, EndAction action,  next) {
    _focusSubscription?.cancel();
    next(action);
  }
}
