import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:focus_game/constants/image_constants.dart';
import 'package:focus_game/utils/main.dart';

class CountDownAnimation extends StatefulWidget {
  final List<String> images = [
    ImageConstants.countDown1,
    ImageConstants.countDown2,
    ImageConstants.countDown3,
  ];
  final double size = 138.size();

  @override
  _CountDownAnimationState createState() => _CountDownAnimationState();
}

class _CountDownAnimationState extends State<CountDownAnimation>
    with TickerProviderStateMixin {
  AnimationController _scaleController;
  Animation<double> _scaleAnimation;
  int _index = 2;

  @override
  void initState() {
    super.initState();
    _scaleController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _scaleAnimation = Tween<double>(begin: 1, end: 0).animate(_scaleController);
    _scaleController
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (_index == 0) {
            _scaleController.stop();
            Navigator.of(context).pop();
          } else {
            setState(() {
              _index = _index-1;
            });
            _scaleController
              ..reset()
              ..forward();
          }
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: SvgPicture.asset(
        widget.images[_index],
        width: 138.size(),
        height: 138.size(),
        fit: BoxFit.scaleDown,
      ),
    );
  }
}
