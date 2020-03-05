import 'package:flutter/widgets.dart';
import 'package:focus_game/constants/main.dart';
import 'package:focus_game/utils/main.dart';
import 'dart:ui' as ui;

class TimerText extends StatelessWidget {
  final String text;

  const TimerText({Key key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.size()),
      child: Text(
        text,
        style: TextStyle(
          color: ColorConstants.countDownText,
          fontSize: 80.font(),
          fontFamily: FontConstants.teko,
          shadows: [
            ui.Shadow(
                color: ColorConstants.textShadow,
                offset: Offset(0, 4.size()),
                blurRadius: 3.size()),
          ],
        ),
      ),
    );
  }
}
