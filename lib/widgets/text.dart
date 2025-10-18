import "package:flutter/material.dart";

class CustomText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight? fontWeight;
  final Color textColor;
  final Color? backgroundColor;
  final bool? centerText;
  final TextDecoration? textDecoration;
  final String? fontFamily;
  final double? letterSpacing;
  final TextOverflow? overflow;
  const CustomText(this.text, {
    super.key,
    required this.fontSize,
    this.fontWeight,
    required this.textColor,
    this.backgroundColor,
    this.centerText,
    this.textDecoration,
    this.fontFamily,
    this.letterSpacing,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        color: textColor,
        fontWeight: fontWeight ?? FontWeight.normal,
        backgroundColor: backgroundColor ?? Colors.transparent,
        decoration: textDecoration ?? TextDecoration.none,
        fontFamily: 'Josefin',
        letterSpacing: letterSpacing ?? 0,
      ),
      textAlign: centerText == true ? TextAlign.center : TextAlign.left,
      overflow: overflow ?? TextOverflow.visible,
    );
  }
}
