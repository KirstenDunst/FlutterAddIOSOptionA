import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:focus_game/constants/main.dart';
import 'package:focus_game/utils/main.dart';
import 'package:focus_game/widgets/main.dart';

class GameToolbar extends StatelessWidget {
  final Function() leftIconOnTap;
  final String title;

  const GameToolbar({Key key, this.leftIconOnTap, this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120.size(),
      child: Stack(
        fit: StackFit.passthrough,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(30.size()),
            child: SvgIconButton(
              assets: ImageConstants.closeCircle,
              onTap: leftIconOnTap,
            ),
          ),
          Align(
            child: TimerText(text: title),
          ),
        ],
      ),
    );
  }
}
