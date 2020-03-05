import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:focus_game/constants/main.dart';

/// 通用按钮组件，可设置主题颜色，布局方式及圆弧角度等
///
/// ## Sample code
/// ```dart
///            RoundCornerButton(
///             'disable',
///             null,
///            ),
///
///            RoundCornerButton(
///              'primary',
///              () {},
///              colorStyle: ButtonColorStyle.primary(),
///            ),
///
///            RoundCornerButton(
///              'white',
///              () {},
///              colorStyle: ButtonColorStyle.white(),
///            ),
///
///            RoundCornerButton(
///              'match_parent',
///              () {},
///              colorStyle: ButtonColorStyle.primary(),
///              measureType: MeasureType.matchParent,
///            ),
/// ```
///
///
class RoundCornerButton extends StatelessWidget {
  final String title;
  final double width;
  final double height;
  final double fontSize;
  final EdgeInsets padding;
  final double radius;
  final MeasureType measureType;
  final VoidCallback onPressed;
  final ButtonColorStyle colorStyle;

  final String eventName;
  final Map<String, dynamic> properties;

  RoundCornerButton(
    this.title,
    this.onPressed, {
    this.width,
    this.eventName,
    this.properties,
    this.measureType = MeasureType.wrapContent,
    this.height = 50,
    this.fontSize = 18,
    colorStyle,
    padding,
    radius,
    Key key,
  })  : radius = radius ?? height / 2,
        colorStyle = onPressed == null
            ? ButtonColorStyle.grey()
            : (colorStyle ?? ButtonColorStyle.primary()),
        padding =
            padding ?? EdgeInsets.only(left: height / 2, right: height / 2),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return measureType == MeasureType.wrapContent
        ? Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(radius)),
              border: Border.all(
                color: colorStyle.color,
                width: 0.5,
              ),
            ),
            child: _buildButton())
        : SizedBox(
            width: double.infinity,
            child: Material(
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: colorStyle.color,
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(radius),
              ),
              child: _buildButton(),
            ),
          );
  }

  Widget _buildButton() {
    return CupertinoButton(
      padding: padding,
      onPressed: onPressed,
      color: colorStyle.backgroundColor,
      disabledColor: colorStyle.backgroundColor,
      borderRadius: BorderRadius.all(Radius.circular(radius)),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: fontSize, color: colorStyle.color),
      ),
    );
  }
}

enum MeasureType {
  /// 宽度自适应或者指定 width
  wrapContent,

  /// 宽度充满父组件剩余空间
  matchParent,
}


class ButtonColorStyle {
  Color color;
  Color borderColor;
  Color backgroundColor;

  ButtonColorStyle(this.color, this.borderColor, this.backgroundColor);

  factory ButtonColorStyle.grey() =>
      ButtonColorStyle(ColorConstants.mediumGrey, ColorConstants.mediumGrey, Colors.white);

  factory ButtonColorStyle.white() =>
      ButtonColorStyle(Colors.white, Colors.white, ColorConstants.primary);

  factory ButtonColorStyle.primary() =>
      ButtonColorStyle(ColorConstants.primary, ColorConstants.primary, Colors.white);
}