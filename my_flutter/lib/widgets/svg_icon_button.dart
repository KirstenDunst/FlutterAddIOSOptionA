import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:focus_game/utils/main.dart';

class SvgIconButton extends StatelessWidget {
  final String assets;
  final Function() onTap;
  const SvgIconButton({Key key, this.assets, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      highlightShape: BoxShape.circle,
      highlightColor: Colors.transparent,
      child: SvgPicture.asset(
        assets,
        width: 50.size(),
        height: 50.size(),
      ),
      onTap: onTap,
    );
  }
}
