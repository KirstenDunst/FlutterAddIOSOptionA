import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:focus_game/constants/color_constants.dart';
import 'package:focus_game/constants/focus_constants.dart';
import 'package:focus_game/utils/main.dart';

class FocusChip extends StatelessWidget {
  final num focusValue;

  const FocusChip({Key key, this.focusValue}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70.size(),
      height: 30.size(),
      child: Center(
        child: Text(
          double.parse(focusValue.toStringAsFixed(1)).toString(),
          style: TextStyle(color: Colors.white, fontSize: 24.font()),
        ),
      ),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.all(Radius.circular(16.size())),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _gradientColors(),
        ),
      ),
    );
  }

  List<Color> _gradientColors() {
    if (focusValue == FocusConstants.none) {
      return [ColorConstants.noneGradientBegin, ColorConstants.noneGradientEnd];
    } else if (focusValue < FocusConstants.low) {
      return [ColorConstants.lowGradientBegin, ColorConstants.lowGradientEnd];
    } else if (focusValue > FocusConstants.high) {
      return [ColorConstants.highGradientBegin, ColorConstants.highGradientEnd];
    } else {
      return [ColorConstants.midGradientBegin, ColorConstants.midGradientEnd];
    }
  }
}
