import 'package:boder/controller/auth_controller.dart';
import 'package:boder/controller/users_controller.dart';
import 'package:boder/constants/utils/colors.dart';
import 'package:boder/views/notification/send_notification_dialog.dart';
import 'package:boder/widgets/spacing.dart';
import 'package:boder/widgets/text.dart';
import 'package:boder/widgets/wallets_ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'add_privilege_user _ dialog.dart';

class CustomHeader extends StatelessWidget {
  final user = Get.find<UsersController>();
  final auth = Get.find<AuthController>();
  final String title;
  final VoidCallback? onMenuTap;  
  final VoidCallback? payRiders; 
  
  CustomHeader({
    super.key, 
    required this.title,
    this.onMenuTap,
    this.payRiders,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentUser = user.currentUser.value;
      if (currentUser == null) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border(
              bottom: BorderSide(
                color: AppColors.borderColor,
                width: 1,
              ),
            ),
          ),
          child: Text("Please log in"),
        );
      }

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border(
            bottom: BorderSide(
              color: AppColors.borderColor,
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  title,
                  fontSize: 24,
                  textColor: AppColors.black,
                  fontWeight: FontWeight.w600,
                ),
                CustomSpacing(height: 0.005),
                CustomText(
                  "Welcome back! Here's what's happening today.",
                  fontSize: 14,
                  textColor: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ],
            ),          
            Row(
              children: [                          
                CustomSpacing(width: 0.02),
                Visibility(
                  visible: title == "Wallets" && currentUser.userType == 0,
                  child: GestureDetector(
                    onTap: payRiders,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.blue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CustomText(
                          "Pay riders", 
                          fontSize: 16, 
                          textColor: AppColors.white
                        ),
                      ),
                    ),
                  ),
                ),        
                SizedBox(width: 12),      
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.lightBlue,
                        child: (currentUser.image?.isNotEmpty == true)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            currentUser.image!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => 
                            WalletUIUtils.buildDefaultAvatar(currentUser.userName),
                          ),
                         )
                      : WalletUIUtils.buildDefaultAvatar(currentUser.userName),
                      ),
                      CustomSpacing(width: 0.015),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            currentUser.userName,
                            fontSize: 14,
                            textColor: AppColors.black,
                            fontWeight: FontWeight.w500,
                          ),
                          CustomText(
                            currentUser.email,
                            fontSize: 12,
                            textColor: AppColors.textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ],
                      ),
                      CustomSpacing(width: 0.01),
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.textSecondary,
                        ),
                        offset: Offset(0, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 8,
                        onSelected: (value) {
                          if (value == 'send_notification') {
                            Get.dialog(
                              SendNotificationDialog(),
                              barrierDismissible: false,
                            );
                          } else if (value == 'add_privileged') {
                            AddPrivilegeUserDialog.show(context);
                          } else if (value == 'logout') {
                            auth.logout(context);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'profile',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                                CustomSpacing(width: 0.02),
                                CustomText(
                                  "Profile",
                                  fontSize: 14,
                                  textColor: AppColors.black,
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'settings',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.settings_outlined,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                                CustomSpacing(width: 0.02),
                                CustomText(
                                  "Settings",
                                  fontSize: 14,
                                  textColor: AppColors.black,
                                ),
                              ],
                            ),
                          ),
                          if (currentUser.userType == 0) ...[
                            // Send Notification - NEW
                            PopupMenuItem(
                              value: 'send_notification',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.notifications_active,
                                    size: 18,
                                    color: AppColors.textSecondary,
                                  ),
                                  CustomSpacing(width: 0.02),
                                  CustomText(
                                    "Send Notification", 
                                    fontSize: 14,
                                    textColor: AppColors.black,
                                  ),
                                ],
                              ),
                            ),
                            // Add Privileged User
                            PopupMenuItem(
                              value: 'add_privileged',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.security_sharp,
                                    size: 18,
                                    color: AppColors.textSecondary,
                                  ),
                                  CustomSpacing(width: 0.02),
                                  CustomText(
                                    "Add Privileged user", 
                                    fontSize: 14,
                                    textColor: AppColors.black,
                                  ),
                                ],
                              ),
                            ),
                          ],
                          PopupMenuItem(
                            value: 'logout',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.logout_outlined,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                                CustomSpacing(width: 0.02),
                                CustomText(
                                  "Logout",
                                  fontSize: 14,
                                  textColor: AppColors.black,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}