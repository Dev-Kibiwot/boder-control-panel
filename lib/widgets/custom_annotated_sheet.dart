import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:boder/widgets/colors.dart';

class CustomAnnotatedSheet extends StatelessWidget {
  final Widget child;
  const CustomAnnotatedSheet({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnnotatedRegion(
        value: SystemUiOverlayStyle(
          statusBarColor: AppColors.blue,
          systemNavigationBarColor: Colors.white,
          statusBarBrightness: Brightness.light,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: child,
      ),
    );
  }
}