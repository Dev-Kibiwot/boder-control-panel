import 'package:boder/controller/users_controller.dart';
import 'package:boder/models/users_model.dart';
import 'package:boder/services/auth_service.dart';
import 'package:boder/services/toast_service.dart';
import 'package:boder/constants/utils/errors_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final AuthService authService = Get.put(AuthService());
  ToastService toastService = ToastService();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  RxBool visible = true.obs;
  RxBool loading = false.obs;
  UsersController get usersController => Get.find<UsersController>();
  final privilegeEmailController = TextEditingController();
  final privilegefirstnameController = TextEditingController();
  final privilegelastnameController = TextEditingController();
  final privilegePasswordController = TextEditingController();
  final privilegePhoneController = TextEditingController();
  final privilegeUserFormKey = GlobalKey<FormState>();
  RxBool privilegePasswordVisible = true.obs;
  RxBool creatingPrivilegeUser = false.obs;

  void togglePrivilegePassword() {
    privilegePasswordVisible.value = !privilegePasswordVisible.value;
  }

  void clearPrivilegeUserForm() {
    privilegeEmailController.clear();
    privilegePasswordController.clear();
    privilegePhoneController.clear();
    privilegePasswordVisible.value = true;
    creatingPrivilegeUser.value = false;
  }

  void togglePassword() {
    visible.value = !visible.value;
  }

  Future<void> loginAdmin(BuildContext context) async {
    try {
      loading.value = true;
      final response = await authService.adminLogin(
        emailController.text, 
        passwordController.text,
        context
      );
      if (response.statusCode == 200) {
        await _handleSuccessfulLogin(response, context);
      } else {
        loading.value = false;
        final errorMessage = extractErrorMessage(
          response,
          fallback: "Login failed",
        );
        toastService.showError(
          context: context,
          message: errorMessage,
        );
      }
    } catch (e) {
      loading.value = false;
      final errorMessage = extractErrorMessage(
        e,
        fallback: "An unexpected error occurred",
      );
      toastService.showError(
        context: context,
        message: errorMessage,
      );
    }
  }

  Future<void> _handleSuccessfulLogin(dynamic response, BuildContext context) async {
    try {
      Map<String, dynamic> responseData = response.body['data'];
      if (!responseData.containsKey('user')) {
        throw Exception('User data not found in response');
      }
      Map<String, dynamic> userData = responseData['user'];
      Map<String, dynamic> transformedUserData = {
        'userId': userData['id'],
        'userName': userData['userName'],
        'email': userData['email'],
        'phone': userData['phoneNumber'] ?? userData['phone'] ?? '', 
        'userType': userData['userType'] == 'Admin' ? 0 : 1,
        'image': userData['image'] ?? '',
      };
      final loggedInUser = Users.fromMap(transformedUserData);
      usersController.setCurrentUser(loggedInUser);
      loading.value = false;
      Get.offNamed('/layout');
      Future.delayed(const Duration(milliseconds: 300), () {
        toastService.showSuccess(
          context: context,
          message: "Welcome back, ${loggedInUser.userName}!"
        );
      });
    } catch (e) {
      loading.value = false;
      toastService.showError(
        context: context,
        message: "Login successful but failed to load user data. Please try again.",
      );
    }
  }

Future<void> createPrivilegeUser(BuildContext context) async {
  if (!privilegeUserFormKey.currentState!.validate()) {
    return;
  }
  creatingPrivilegeUser.value = true;
  try {
    print('Creating privilege user: ${privilegeEmailController.text}');
    final response = await authService.createPrivilegeUser(
      firstName: privilegefirstnameController.text.trim(),
      lastNmae: privilegelastnameController.text.trim(),
      email: privilegeEmailController.text.trim(),
      password: privilegePasswordController.text,
      phoneNumber: privilegePhoneController.text.trim(),
    );
    print('Create user response status: ${response.statusCode}');
    print('Create user response data: ${response.body}');

    // Success - clean up and show success
    clearPrivilegeUserForm();
    Get.back();
    
    toastService.showSuccess(
      context: context,
      message: "Privilege user created successfully!",
    );
    
  } catch (e) {
    print('Create privilege user error: $e');
    
    final errorMessage = extractErrorMessage(
      e,
      fallback: "An unexpected error occurred while creating user",
    );
    
    toastService.showError(
      context: context,
      message: errorMessage,
    );
  } finally {
    // Always reset loading state
    creatingPrivilegeUser.value = false;
  }
}

  void logout(BuildContext context) {
    try {
      usersController.clearCurrentUser();
      emailController.clear();
      passwordController.clear();
      loading.value = false;
      visible.value = true;
      Get.offAllNamed('/');
      toastService.showSuccess(
        context: context,
        message: "Logged out successfully"
      );
    } catch (e) {
      toastService.showError(
        context: context,
        message: "Error during logout"
      );
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}