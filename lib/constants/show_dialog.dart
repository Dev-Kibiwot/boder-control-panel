import 'package:boder/constants/utils/colors.dart';
import 'package:boder/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showActionDialog(BuildContext context, String title, String message,String back,String proceed, Color color, VoidCallback onConfirm) {
    Get.dialog(
      AlertDialog(
        title: CustomText(
          title, 
          fontSize: 13, 
          textColor: AppColors.textSecondary,
        ),
        content: CustomText(
          message, 
          fontSize: 13, 
          textColor: AppColors.textSecondary,
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text(back),
              ),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  onConfirm();
                },
                style: ElevatedButton.styleFrom(backgroundColor: color),
                child: CustomText(
                  proceed, 
                  fontSize: 14, 
                  textColor: AppColors.white
                )
              ),
            ],
          )
        ],
      ),
    );
  }