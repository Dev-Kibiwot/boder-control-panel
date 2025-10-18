import 'package:boder/widgets/space.dart';
import 'package:flutter/material.dart';
import 'package:boder/widgets/colors.dart';
import 'package:boder/widgets/text.dart';

class AppButton extends StatelessWidget {
  final String label;
  final Color? buttonColor;
  final Color? textColor;
  final VoidCallback? onTap;

  const AppButton({
    super.key,
    required this.label,
    this.buttonColor,
    this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: (){
          onTap?.call();
        },
        onHover: (bool value){},
        child: Container(
          height: 50,
          width: horizontalSpace(context, .75),
          decoration: BoxDecoration(
            color:  AppColors.blue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: CustomText(
              label, 
              fontSize: 16,
              textColor: (textColor ?? AppColors.white),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}