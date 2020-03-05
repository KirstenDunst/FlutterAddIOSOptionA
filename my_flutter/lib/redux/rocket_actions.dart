import 'dart:ui' as ui;

class PrepareAction {
  final int duration;
  final String audioUrl;
  final String backgroundAsset;

  PrepareAction({this.duration, this.audioUrl, this.backgroundAsset});
}

class HavePreparedAction {
  final ui.Image background;
  final String audioFile;

  HavePreparedAction(this.background, this.audioFile);
}

class CountDownAction {}

class StartAction {}

class RunAction {}

class PauseAction {}

class ResumeAction {}

class EndAction {}

class FocusChangeAction {
  final double focus;

  FocusChangeAction(this.focus);
}

class UsedTimeChangeAction {
  final int usedTime;

  UsedTimeChangeAction(this.usedTime);
}

class DisposeAction {}
