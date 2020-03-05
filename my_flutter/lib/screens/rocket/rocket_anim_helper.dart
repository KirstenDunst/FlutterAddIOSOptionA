import 'package:flutter_lottie_brainco/main.dart';

class RocketAnimHelper {
  LottieController _fireLottieController;
  LottieController _launchSmokeLottieController;
  LottieController _wingController;

  LottieController get fireController => _fireLottieController;

  LottieController get smokeController => _launchSmokeLottieController;

  LottieController get wingController => _wingController;

  static const List<int> fireLaunch = [0, 44];
  static const List<int> fireSmall = [45, 50];
  static const List<int> fireNormal = [57, 62];
  static const List<int> fireBig = [69, 74];
  static const List<int> fireBigToSmall = [75, 80];

  static const List<int> wingExpand = [0, 15];
  static const List<int> wingFire = [15, 19];
  static const List<int> wingBack = [20, 0];

  void init() {
    _fireLottieController = LottieController(
      listener: AnimationListener(
        onEnd: () {
          print('fire onEnd $_fireNextFrames');
          if (_fireNextFrames != null) {
            _fireLottieController.playWithFrames(
                _fireNextFrames[0], _fireNextFrames[1], LottieLoopMode.playOnce);
          }
        },
      ),
    );
    _launchSmokeLottieController =
        LottieController(listener: AnimationListener(onEnd: () {}));
    _wingController = LottieController(listener: AnimationListener(onEnd: () {
      if (_wingNextFrames != null) {
        _wingController.playWithFrames(
            _wingNextFrames[0], _wingNextFrames[1], LottieLoopMode.playOnce);
      }
    }));
  }

  void dispose() {
    _fireLottieController?.dispose();
    _launchSmokeLottieController?.dispose();
    _wingController?.dispose();
  }

  List<int> _fireNextFrames;

  void playLaunch() {
    _launchSmokeLottieController.play();
    _fireSmallLoop();
    _fireLottieController.playWithFrames(
        fireLaunch[0], fireLaunch[1], LottieLoopMode.playOnce);
  }

  void _fireSmallLoop() {
    _fireNextFrames = fireSmall;
  }

  void _fireNormalLoop() {
    _fireNextFrames = fireNormal;
  }

  void _fireBigLoop() {
    _fireNextFrames = fireBig;
  }

  void playFireNormalToSmall() {
    _fireSmallLoop();
    _fireLottieController.playWithFrames(
        fireNormal[0] - 1, fireSmall[1] + 1, LottieLoopMode.playOnce);
  }

  void playFireBigToSmall() {
    _fireSmallLoop();
    _fireLottieController.playWithFrames(
        fireBigToSmall[0], fireBigToSmall[1], LottieLoopMode.playOnce);
  }

  void playFireSmallToNormal() {
    _fireNormalLoop();
    _fireLottieController.playWithFrames(
        fireSmall[1] + 1, fireNormal[0] - 1, LottieLoopMode.playOnce);
  }

  void playFireBigToNormal() {
    _fireNormalLoop();
    _fireLottieController.playWithFrames(
        fireBig[0] - 1, fireNormal[1] + 1, LottieLoopMode.playOnce);
  }

  void playFireSmallToBig() {
    _fireBigLoop();
    _fireLottieController.playWithFrames(
        fireSmall[1] + 1, fireBig[0] - 1, LottieLoopMode.playOnce);
  }

  void playFireNormalToBig() {
    _fireBigLoop();
    _fireLottieController.playWithFrames(
        fireNormal[1] + 1, fireBig[0] - 1, LottieLoopMode.playOnce);
  }

  List<int> _wingNextFrames;

  void playWingExpand() {
    _wingNextFrames = wingFire;
    _wingController.playWithFrames(
        wingExpand[0], wingExpand[1], LottieLoopMode.playOnce);
  }

  void playWingBack() {
    _wingNextFrames = null;
    _wingController.playWithFrames(
        wingBack[0], wingBack[1], LottieLoopMode.playOnce);
  }
}
