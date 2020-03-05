import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

class AudioUtil {
  static Future<String> loadFile(String url) async {
    String fileName = url.split('/').last ?? 'audio.mp3';
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    if (await file.exists()) {
      return file.path;
    }
    final bytes = await readBytes(url);
    await file.writeAsBytes(bytes);
    return file.path;
  }

  AudioUtil({bool isShort = false, @required bool isLoop}) {
    _initAudioPlayer(isShort, isLoop);
  }

  AudioPlayer _audioPlayer;
  AudioPlayerState _audioPlayerState;
  Duration _position;
  Duration _duration;

  StreamSubscription _durationSubscription;
  StreamSubscription _positionSubscription;
  StreamSubscription _playerCompleteSubscription;
  StreamSubscription _playerErrorSubscription;
  StreamSubscription _playerStateSubscription;

  get _isPlaying => _audioPlayerState == AudioPlayerState.PLAYING;

  get _isPaused => _audioPlayerState == AudioPlayerState.PAUSED;

  void dispose() {
    _audioPlayer.stop();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerErrorSubscription?.cancel();
    _playerStateSubscription?.cancel();
  }

  void _initAudioPlayer(bool isShort, bool isLoop) {
    _audioPlayer = AudioPlayer(
        mode: isShort ? PlayerMode.LOW_LATENCY : PlayerMode.MEDIA_PLAYER)
      ..setReleaseMode(isLoop ? ReleaseMode.LOOP : ReleaseMode.STOP);

    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      _duration = duration;

      if (Platform.isIOS) {
        // (Optional) listen for notification updates in the background
        _audioPlayer.startHeadlessService();

        // set at least title to see the notification bar on ios.
        _audioPlayer.setNotification(
            title: 'App Name',
            artist: 'Artist or blank',
            albumTitle: 'Name or blank',
            imageUrl: 'url or blank',
            forwardSkipInterval: const Duration(seconds: 30),
            // default is 30s
            backwardSkipInterval: const Duration(seconds: 30),
            // default is 30s
            duration: duration,
            elapsedTime: Duration(seconds: 0));
      }
    });

    _positionSubscription = _audioPlayer.onAudioPositionChanged.listen((p) {
      _position = p;
    });

    _playerCompleteSubscription =
        _audioPlayer.onPlayerCompletion.listen((event) {
      _position = _duration;
    });

    _playerErrorSubscription = _audioPlayer.onPlayerError.listen((msg) {
      print('audioPlayer error : $msg');
      _duration = Duration(seconds: 0);
      _position = Duration(seconds: 0);
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      _audioPlayerState = state;
    });

    _audioPlayer.onNotificationPlayerStateChanged.listen((state) {
      _audioPlayerState = state;
    });
  }

  Future<bool> play(String url) async {
    final playPosition = (_position != null &&
            _duration != null &&
            _position.inMilliseconds > 0 &&
            _position.inMilliseconds < _duration.inMilliseconds)
        ? _position
        : null;
    final result = await _audioPlayer.play(url, position: playPosition);

    // default playback rate is 1.0
    // this should be called after _audioPlayer.play() or _audioPlayer.resume()
    // this can also be called everytime the user wants to change playback rate in the UI
    _audioPlayer.setPlaybackRate(playbackRate: 1.0);

    return 1 == result;
  }

  Future<bool> pause() async {
    return 1 == await _audioPlayer.pause();
  }

  Future<bool> stop() async {
    final isSuc = 1 == await _audioPlayer.stop();
    if (isSuc) {
      _position = Duration();
    }
    return isSuc;
  }
}

class AudioAssetUtil {
  AudioCache _audioCache;
  AudioPlayer _fixePlayer;

  AudioAssetUtil() {
    _fixePlayer = AudioPlayer(mode: PlayerMode.LOW_LATENCY);
    _audioCache = AudioCache(prefix: '', fixedPlayer: _fixePlayer);
  }

  Future<List<File>> loadAll(List<String> fileNames) async {
    return _audioCache.loadAll(fileNames);
  }

  Future<File> load(String fileName) async {
    return _audioCache.load(fileName);
  }

  void clear(String fileName) {
    _audioCache.clear(fileName);
  }

  void clearAll() {
    _audioCache.clearCache();
  }

  Future play(String assetName) async {
    return _audioCache.play(assetName, mode: PlayerMode.LOW_LATENCY);
  }

  Future<bool> pause() async {
    return 1 == await _fixePlayer?.pause();
  }

  Future<bool> stop() async {
    return 1 == await _fixePlayer?.stop();
  }

  void dispose() {
    _fixePlayer.release();
  }

  void loop(String fileName) {
    _audioCache.loop(fileName);
  }
}
