import 'package:flutter/widgets.dart';
import 'package:flutter_lottie_brainco/lottie_controller.dart';
import 'package:flutter_lottie_brainco/lottie_view.dart';
import 'package:focus_game/constants/main.dart';
import 'package:focus_game/utils/main.dart';
import 'package:focus_game/widgets/focus_chip.dart';

class RocketView extends StatelessWidget {
  final double focus;
  final LottieController fireLottieController;
  final LottieController wingLottieController;

  const RocketView({Key key, this.focus, this.fireLottieController, this.wingLottieController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200.size(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          FocusChip(focusValue: focus),
          SizedBox(height: 10.size()),
          Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 18.0),
                child: SizedBox(
                  width: 180.size(),
                  height: 80.size(),
                  child: LottieView(
                    filePath: AnimConstants.rocketExpandWings,
                    controller: wingLottieController,
                  ),
                ),
              ),
              Image.asset(
                ImageConstants.rocket,
                width: 47.size(),
                height: 72.size(),
              ),
              Padding(
                padding: EdgeInsets.only(top: 66.size()),
                child: SizedBox(
                  width: 38.size(),
                  height: 76.size(),
                  child: LottieView(
                    filePath: AnimConstants.rocketFire,
                    controller: fireLottieController,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}