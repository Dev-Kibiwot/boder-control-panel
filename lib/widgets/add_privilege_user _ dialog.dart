import 'package:boder/constants/button.dart';
import 'package:boder/widgets/text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:boder/controller/auth_controller.dart';

class AddPrivilegeUserDialog {
  final AuthController authController = Get.find<AuthController>();

  static void show(BuildContext context) {
    final instance = AddPrivilegeUserDialog();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return instance._buildDialog(context);
      },
    );
  }

  Widget _buildDialog(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title with close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add Privilege User',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    authController.clearPrivilegeUserForm();
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Form content
            Form(
              key: authController.privilegeUserFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextFormField(
                    darkTheme: false,
                    controller: authController.privilegefirstnameController,
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'First name is required';
                      }
                      return null;
                    },
                    label: "Enter first name address",
                  ),
                  const SizedBox(height: 20),
                  CustomTextFormField(
                    darkTheme: false,
                    controller: authController.privilegelastnameController,
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Last name is required';
                      }
                      return null;
                    },
                    label: "Enter last name address",
                  ),
                  const SizedBox(height: 20),
                  CustomTextFormField(
                    darkTheme: false,
                    controller: authController.privilegeEmailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      }
                      if (!GetUtils.isEmail(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    label: "Enter email address",
                  ),
                  const SizedBox(height: 20),
                  CustomTextFormField(
                    darkTheme: false,
                    controller: authController.privilegePhoneController,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.length < 10) {
                        return 'Please enter a valid phone number';
                      }
                      return null;
                    },
                    label: 'Phone Number',
                  ),
                  const SizedBox(height: 20),
                  Obx(() => CustomTextFormField(
                    darkTheme: false,
                    controller: authController.privilegePasswordController,
                    keyboardType: TextInputType.visiblePassword,
                    obsecureText: !authController.privilegePasswordVisible.value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                    suffixIcon: IconButton(
                      onPressed: authController.togglePrivilegePassword,
                      icon: Icon(
                        authController.privilegePasswordVisible.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                    label: "Create password",
                  )),                  
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    onTap: () {
                      authController.clearPrivilegeUserForm();
                      Navigator.of(context).pop();
                    },
                    label: 'Cancel',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(() => AppButton(
                    onTap: authController.creatingPrivilegeUser.value
                        ? null
                        : () => authController.createPrivilegeUser(context),
                    label: 'Create User',
                  )),
                ),
              ],
            ),
          ],
        ),
      ),

    );
  }
}