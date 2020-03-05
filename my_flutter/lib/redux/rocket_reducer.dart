import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:focus_game/models/main.dart';
import 'package:focus_game/redux/rocket_actions.dart';
import 'package:redux/redux.dart';

enum GameState {
  Preparing, //加载音频/图片
  WaitingForUser, //弹框等用户确认
  CountDownBeforeStart, //321倒计时
  Started, //已开始，专注值显示
//  PreRunning, //启动动画，火箭发射前抖动动画
//  Running, //正式开始，根据专注值改变位置
  Paused,
  Ended
}

enum DialogType { WaitingForUser, CountDown, Ended }

@immutable
class RocketState {
  final double focus;
  final int duration;
  final int usedTime;
  final GameState gameState;
  final ui.Image background;
  final String audioFile;
  final StreamController<GameState> gameStateController;
  final StreamController<DialogType> dialogController;
  final StreamController<double> focusController;
  final RequestFailureInfo errorInfo;

  RocketState(
      {this.focus,
      this.duration,
      this.usedTime,
      this.gameState,
      this.background,
      this.audioFile,
        this.gameStateController,
      this.dialogController,
      this.focusController,
      this.errorInfo});

  RocketState copyWith({
    double focus,
    int duration,
    int usedTime,
    StreamController<GameState> gameStateController,
    StreamController<DialogType> dialogController,
    StreamController<double> focusController,
    GameState gameState,
    ui.Image background,
    String audioFile,
    RequestFailureInfo errorInfo,
  }) {
    return RocketState(
        focus: focus ?? this.focus,
        duration: duration ?? this.duration,
        usedTime: usedTime ?? this.usedTime,
        gameState: gameState ?? this.gameState,
        gameStateController: gameStateController?? this.gameStateController,
        dialogController: dialogController ?? this.dialogController,
        focusController: focusController ?? this.focusController,
        background: background ?? this.background,
        audioFile: audioFile ?? this.audioFile,
        errorInfo: errorInfo ?? this.errorInfo);
  }

  RocketState.initialState()
      : focus = 0,
        duration = 0,
        usedTime = 0,
        gameState = GameState.Preparing,
        background = null,
        audioFile = null,
        gameStateController = StreamController.broadcast(),
        dialogController = StreamController.broadcast(),
        focusController = StreamController.broadcast(),
        errorInfo = RequestFailureInfo.initialState();
}

final loginReducer = combineReducers<RocketState>([
  TypedReducer<RocketState, PrepareAction>(_onPrepare),
  TypedReducer<RocketState, HavePreparedAction>(_onHavePrepared),
  TypedReducer<RocketState, CountDownAction>(_onCountDown),
  TypedReducer<RocketState, StartAction>(_onStart),
  TypedReducer<RocketState, PauseAction>(_onPause),
  TypedReducer<RocketState, ResumeAction>(_onResume),
  TypedReducer<RocketState, EndAction>(_onEnd),
  TypedReducer<RocketState, FocusChangeAction>(_onFocusChange),
  TypedReducer<RocketState, UsedTimeChangeAction>(_onUsedTimeChanged),
  TypedReducer<RocketState, DisposeAction>(_onDispose),
]);

RocketState _onPrepare(RocketState state, PrepareAction action) =>
    state.copyWith(duration: action.duration);

RocketState _onHavePrepared(RocketState state, HavePreparedAction action) {
  state.dialogController.add(DialogType.WaitingForUser);
  state.gameStateController.add(GameState.WaitingForUser);
  return state.copyWith(
      gameState: GameState.WaitingForUser,
      background: action.background,
      audioFile: action.audioFile);
}

RocketState _onStart(RocketState state, StartAction action){
  state.gameStateController.add(GameState.Started);
  return state.copyWith(gameState: GameState.Started);
}

RocketState _onPause(RocketState state, PauseAction action) {
  if (state.gameState == GameState.Started) {
    state.gameStateController.add(GameState.Paused);
    return state.copyWith(gameState: GameState.Paused);
  } else return state;
}

RocketState _onResume(RocketState state, ResumeAction action) {
  if (state.gameState == GameState.Paused) {
    state.gameStateController.add(GameState.Started);
    return state.copyWith(gameState: GameState.Started);
  } else {
    return state;
  }
}

RocketState _onEnd(RocketState state, EndAction action) {
  state.dialogController.add(DialogType.Ended);
  state.gameStateController.add(GameState.Ended);
  return state.copyWith(gameState: GameState.Ended);
}

RocketState _onFocusChange(RocketState state, FocusChangeAction action) {
  state.focusController.add(action.focus);
  return state.copyWith(focus: action.focus);
}

RocketState _onCountDown(RocketState state, CountDownAction action) {
  state.dialogController.add(DialogType.CountDown);
  state.gameStateController.add(GameState.CountDownBeforeStart);
  return state.copyWith(gameState: GameState.CountDownBeforeStart);
}

RocketState _onDispose(RocketState state, DisposeAction action) =>
    RocketState.initialState();

RocketState _onUsedTimeChanged(
        RocketState state, UsedTimeChangeAction action) =>
    state.copyWith(usedTime: action.usedTime);
