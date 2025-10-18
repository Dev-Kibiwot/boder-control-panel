import 'package:boder/constants/utils/errors_widget.dart';
import 'package:boder/models/privillage_user.dart';
import 'package:boder/services/privilage_user_service.dart';
import 'package:boder/services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PrivilegedUserController extends GetxController {
  final PrivilegedUserService _privilegedUserService = Get.put(PrivilegedUserService());
  final ToastService _toastService = ToastService();

  // Observable variables
  final RxList<PrivilegedUser> _allPrivilegedUsers = <PrivilegedUser>[].obs;
  final RxList<PrivilegedUser> filteredPrivilegedUsers = <PrivilegedUser>[].obs;
  final RxString searchQuery = ''.obs;
  
  RxBool isLoading = false.obs;
  RxBool isCreatingUser = false.obs;
  RxBool isUpdatingUser = false.obs;
  RxBool isDeletingUser = false.obs;
  RxString errorMessage = ''.obs;
  
  // Pagination
  RxInt currentPage = 1.obs;
  RxInt pageSize = 20.obs;
  RxInt totalPages = 1.obs;
  RxInt totalUsers = 0.obs;

  // Form controllers for creating privileged user
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  RxBool passwordVisible = true.obs;

  // Form controllers for updating privileged user
  final updateEmailController = TextEditingController();
  final updatePhoneController = TextEditingController();
  final updateFirstnameController = TextEditingController();
  final updateLastnameController = TextEditingController();
  final updateFormKey = GlobalKey<FormState>();

  // Getters for accessing filtered data
  List<PrivilegedUser> get privilegedUsers => filteredPrivilegedUsers;

  @override
  void onInit() {
    super.onInit();
    getAllPrivilegedUsers();
  }

  void togglePasswordVisibility() {
    passwordVisible.value = !passwordVisible.value;
  }

  void clearCreateForm() {
    emailController.clear();
    passwordController.clear();
    phoneController.clear();
    firstnameController.clear();
    lastnameController.clear();
    passwordVisible.value = true;
  }

  void clearUpdateForm() {
    updateEmailController.clear();
    updatePhoneController.clear();
    updateFirstnameController.clear();
    updateLastnameController.clear();
  }

  // Search functionality
  void searchPrivilegedUsers(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void _applyFilters() {
    final filtered = _allPrivilegedUsers.where((user) {
      if (searchQuery.value.isEmpty) return true;
      
      final query = searchQuery.value.toLowerCase();
      
      return user.userName.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          user.firstname.toLowerCase().contains(query) ||
          user.lastname.toLowerCase().contains(query) ||
          user.phone.contains(searchQuery.value) ||
          user.userType.toLowerCase().contains(query) ||
          '${user.firstname} ${user.lastname}'.trim().toLowerCase().contains(query);
    }).toList();
    
    filteredPrivilegedUsers.assignAll(filtered);
  }

  Future<void> getAllPrivilegedUsers({int? page}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      int targetPage = page ?? currentPage.value;
      
      final response = await _privilegedUserService.getAllPrivilegedUsers(
        page: targetPage,
        pageSize: pageSize.value,
      );

      _allPrivilegedUsers.assignAll(response.privilegedUsers);
      currentPage.value = response.page;
      totalPages.value = response.totalPages;
      totalUsers.value = response.totalPrivilegedUsers;
      
      // Apply current filters after loading data
      _applyFilters();
      
    } catch (e) {
      errorMessage.value = extractErrorMessage(
        e,
        fallback: "Failed to load privileged users",
      );
      print('Error loading privileged users: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createPrivilegedUser(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isCreatingUser.value = true;

    try {
      print('Creating privileged user: ${emailController.text}');
      
      final response = await _privilegedUserService.createPrivilegeUser(
        email: emailController.text.trim(),
        password: passwordController.text,
        phoneNumber: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
        firstname: firstnameController.text.trim().isEmpty ? null : firstnameController.text.trim(),
        lastname: lastnameController.text.trim().isEmpty ? null : lastnameController.text.trim(),
      );

      print('Create user response status: ${response.statusCode}');
      print('Create user response data: ${response.body}');

      // Success - clear form, close dialog, refresh list
      clearCreateForm();
      Get.back();
      await getAllPrivilegedUsers(); // This will also apply current filters
      
      _toastService.showSuccess(
        context: context,
        message: "Privileged user created successfully!",
      );
      
    } catch (e) {
      print('Create privileged user error: $e');
      
      final errorMessage = extractErrorMessage(
        e,
        fallback: "An unexpected error occurred while creating user",
      );
      
      _toastService.showError(
        context: context,
        message: errorMessage,
      );
    } finally {
      isCreatingUser.value = false;
    }
  }

  Future<void> deletePrivilegedUser(PrivilegedUser user, BuildContext context) async {
  showActionDialog(
    context,
    'Delete Privileged User',
    'Are you sure you want to delete "${user.userName}"? This action cannot be undone.',
    'Cancel',
    'Delete',
    Colors.red,
    () async {
      try {
        isDeletingUser.value = true;
        final success = await _privilegedUserService.deletePrivillageUser(user.userId, context);
        if (success) {
          _allPrivilegedUsers.removeWhere((u) => u.userId == user.userId);
          filteredPrivilegedUsers.removeWhere((u) => u.userId == user.userId);
          _toastService.showSuccess(
            context: context,
            message: "${user.userName} deleted successfully",
          );
        }
      } finally {
        isDeletingUser.value = false;
      }
    },
  );
}

  void showActionDialog(
    BuildContext context,
    String title,
    String message,
    String cancelText,
    String actionText,
    Color actionColor,
    VoidCallback onAction,
  ) {
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              onAction();
            },
            style: TextButton.styleFrom(
              foregroundColor: actionColor,
            ),
            child: Text(actionText),
          ),
        ],
      ),
    );
  }

  void populateUpdateForm(PrivilegedUser user) {
    updateEmailController.text = user.email;
    updatePhoneController.text = user.phone;
    updateFirstnameController.text = user.firstname;
    updateLastnameController.text = user.lastname;
  }

  Future<void> refreshData() async {
    await getAllPrivilegedUsers();
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      getAllPrivilegedUsers(page: page);
    }
  }

  void nextPage() {
    if (currentPage.value < totalPages.value) {
      getAllPrivilegedUsers(page: currentPage.value + 1);
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      getAllPrivilegedUsers(page: currentPage.value - 1);
    }
  }

  PrivilegedUser? getUserById(String userId) {
    try {
      return _allPrivilegedUsers.firstWhere((user) => user.userId == userId);
    } catch (e) {
      return null;
    }
  }

  // Clear search
  void clearSearch() {
    searchQuery.value = '';
    _applyFilters();
  }

  bool get hasNextPage => currentPage.value < totalPages.value;
  bool get hasPreviousPage => currentPage.value > 1;
  
  // Statistics getters (based on all users, not filtered)
  int get totalPrivilegedUsers => _allPrivilegedUsers.length;
  int get confirmedUsers => _allPrivilegedUsers.where((u) => u.emailConfirmed).length;
  int get pendingUsers => _allPrivilegedUsers.where((u) => !u.emailConfirmed).length;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    firstnameController.dispose();
    lastnameController.dispose();
    updateEmailController.dispose();
    updatePhoneController.dispose();
    updateFirstnameController.dispose();
    updateLastnameController.dispose();
    super.onClose();
  }
}