import 'package:flutter/material.dart';
import 'package:boder/constants/utils/colors.dart';

ThemeData appTheme = ThemeData(
  appBarTheme: AppBarTheme(
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 30,
      fontFamily: 'Josefin'
    ),
    iconTheme: IconThemeData(
      size: 25,
      color: Colors.grey.shade900,
    ),
    centerTitle: true,
    surfaceTintColor: Colors.white
  ),
  colorScheme: ColorScheme.light(
    background: AppColors.white
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: AppColors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(6),
    ),
  ),
);