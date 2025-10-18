import 'package:boder/constants/show_dialog.dart';
import 'package:boder/models/users_model.dart';
import 'package:boder/services/toast_service.dart';
import 'package:boder/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UsersController extends GetxController {
  ToastService toastService = ToastService();
  final RxList<Users> allUsers = <Users>[].obs;
  final RxList<Users> filteredUsers = <Users>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isDeleting = false.obs;
  final UserService userService = UserService();
  final Rxn<Users> selectedUser = Rxn<Users>();
  var userGrowthData = <int>[12, 18, 24, 33, 45, 52].obs;
  final Rxn<Users> currentUser = Rxn<Users>();
  
  bool get isLoggedIn => currentUser.value != null;

  void setCurrentUser(Users user) {
    currentUser.value = user;
  }

  Users? getCurrentUser() {
    return currentUser.value;
  }

  void clearCurrentUser() {
    currentUser.value = null;
  }

  Future<void> deleteUser(Users user, BuildContext context) async {
    showActionDialog(
      context,
      'Delete User',
      'Are you sure you want to delete "${user.userName}"? This action cannot be undone.',
      'Cancel',
      'Delete',
      Colors.red,
      () async {
        try {
          isDeleting.value = true;
          final success = await userService.deleteUser(user.userId, context);
          if (success) {
            allUsers.removeWhere((u) => u.userId == user.userId);
            filteredUsers.removeWhere((u) => u.userId == user.userId);
            if (selectedUser.value?.userId == user.userId) {
              clearSelection();
            }
            toastService.showSuccess(
              context: context,
              message: "${user.userName} deleted successfully",
            );
          }
        } finally {
          isDeleting.value = false;
        }
      },
    );
  }

  Future<void> fetchUsers(BuildContext context) async {
    try {
      isLoading.value = true;
      await userService.getUsers(context);
      final List<Users> fetchedUsers = (userService.users).map((r) => Users.fromMap(r)).toList();
      allUsers.assignAll(fetchedUsers);
      filteredUsers.assignAll(fetchedUsers);
    } catch (e) {
      toastService.showError(context: context, message: 'Failed to fetch users: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void searchUsers(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void _applyFilters() {
    if (searchQuery.value.isEmpty) {
      filteredUsers.assignAll(allUsers);
    } else {
      final query = searchQuery.value.toLowerCase();
      filteredUsers.assignAll(
        allUsers.where((user) =>
          user.userName.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          user.phone.contains(searchQuery.value) ||
          (user.userName.toLowerCase().contains(query)) ||
          user.userName.trim().toLowerCase().contains(query)
        ).toList()
      );
    }
  }

  void selectUser(Users user) {
    selectedUser.value = user;
  }

  void clearSelection() {
    selectedUser.value = null;
  }

  void clearSearch() {
    searchQuery.value = '';
    _applyFilters();
  }

  int get totalUsers => allUsers.length;
  int get filteredUsersCount => filteredUsers.length;
}