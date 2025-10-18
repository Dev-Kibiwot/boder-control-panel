import 'package:flutter/material.dart';

class CustomSpacing extends StatelessWidget {
  final double? height;
  final double? width;
  final Widget? child;
  const CustomSpacing({
    super.key,
    this.height,
    this.width, this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * (height ?? 0),
      width: MediaQuery.of(context).size.height * (width ?? 0),
      child: child,
    );
  }
}