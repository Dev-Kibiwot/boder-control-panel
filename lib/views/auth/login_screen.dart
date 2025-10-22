import 'package:boder/constants/button.dart';
import 'package:boder/controller/auth_controller.dart';
import 'package:boder/constants/utils/colors.dart';
import 'package:boder/widgets/space.dart';
import 'package:boder/widgets/spacing.dart';
import 'package:boder/widgets/text.dart';
import 'package:boder/widgets/text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final authController = Get.put(AuthController());
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryBlue,
                    AppColors.lightBlue,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Lottie.asset(
                    "assets/images/bike.json",
                    height: double.infinity,
                    width: double.infinity,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: verticalSpace(context, 0.08)
                    ),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: CustomText(
                        "Ride Green. Ride BodEr.", 
                        fontSize: 24, 
                        textColor: AppColors.white
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              color: AppColors.white,
              padding: EdgeInsets.symmetric(
                horizontal: horizontalSpace(context, 0.05),
                vertical: verticalSpace(context, 0.1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.lightBlue,
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: AssetImage(
                              "assets/icons/logo.png"
                            )
                          )
                        ),
                      ),
                      CustomSpacing(width: 0.015),
                      CustomText(
                        "BODER",
                        fontSize: 24,
                        textColor: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                  CustomSpacing(height: 0.06),
                  CustomText(
                    "Sign in to access your account",
                    fontSize: 28,
                    textColor: AppColors.black,
                    fontWeight: FontWeight.w600,
                  ),
                  CustomSpacing(height: 0.04),
                  Form(
                    key: authController.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomText(
                          "Email Address",
                          fontSize: 14,
                          textColor: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        CustomSpacing(height: 0.01),
                        CustomTextFormField(
                          darkTheme: false,
                          controller: authController.emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            return value == "" ? "Enter valid email to proceed" : null;
                          },
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: AppColors.textSecondary,
                          ),
                          label: "Enter your email",
                        ),
                        CustomSpacing(height: 0.03),
                        CustomText(
                          "Password",
                          fontSize: 14,
                          textColor: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        CustomSpacing(height: 0.01),
                        Obx(() => CustomTextFormField(
                          darkTheme: false,
                          controller: authController.passwordController,
                          validator: (value) {
                            return value == "" ? "Enter Password to proceed" : null;
                          },
                          obsecureText: authController.visible.value,
                          keyboardType: TextInputType.visiblePassword,
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: AppColors.textSecondary,
                          ),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              authController.togglePassword();
                            },
                            child: Icon(
                              authController.visible.value ? Icons.visibility_off_outlined: Icons.visibility_outlined,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          label: "Enter your password",
                        )),
                        CustomSpacing(height: 0.02),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {},
                            child: CustomText(
                              "Forgot Password?",
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              textColor: AppColors.lightBlue,
                            ),
                          ),
                        ),
                        CustomSpacing(height: 0.04),
                        Obx(()=>authController.loading.value == false ? AppButton(
                          onTap: () {
                            if (authController.formKey.currentState!.validate()) {
                              authController.loginAdmin(context);
                            }
                          },
                          label: "Sign In",
                        ): Center(
                          child: CircularProgressIndicator(),
                        )
                       ),
                        CustomSpacing(height: 0.03),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}