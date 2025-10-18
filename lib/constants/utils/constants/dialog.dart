// ignore_for_file: unnecessary_import

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:boder/widgets/space.dart';

void showLoadingDialog(BuildContext context) {
  Get.dialog(
    Center(
      child: Transform.scale(
      scale: 1.5,
      child: SizedBox(
        height: verticalSpace(context, .225),
        width: horizontalSpace(context, .5),
        child: Transform.scale(
          scale: .75,
          child: Image.asset(
            "assets/images/gifs/hour_loading.gif",
          ),
        ),
      ),
    )),
    barrierDismissible: false,
  );
}
