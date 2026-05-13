import 'package:devboder/constants/utils/enums.dart';
import 'package:devboder/controller/users_controller.dart';
import 'package:devboder/controller/riders_controller.dart';
import 'package:devboder/services/notification_service.dart';
import 'package:devboder/services/toast_service.dart';
import 'package:devboder/views/notification/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationsController extends GetxController {
  final NotificationService notificationService = NotificationService();
  final ToastService toastService = ToastService();
  
  late UsersController usersController;
  late RidersController ridersController;

  // Observables
  final RxList<NotificationModel> notificationHistory = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;
  final RxString userSearchQuery = ''.obs;
  final RxString riderSearchQuery = ''.obs;
  
  // Form fields
  final titleController = TextEditingController();
  final messageController = TextEditingController();
  final userSearchController = TextEditingController();
  final riderSearchController = TextEditingController();
  
  final Rx<NotificationType> selectedType = NotificationType.general.obs;
  final Rx<RecipientType> selectedRecipientType = RecipientType.all.obs;
  final RxList<String> selectedUserIds = <String>[].obs;
  final RxList<String> selectedRiderIds = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
  }

  void _initializeControllers() {
    if (Get.isRegistered<UsersController>()) {
      usersController = Get.find<UsersController>();
    } else {
      usersController = Get.put(UsersController());
    }
    
    if (Get.isRegistered<RidersController>()) {
      ridersController = Get.find<RidersController>();
    } else {
      ridersController = Get.put(RidersController());
    }
  }

  // FIX: Properly typed filtered lists
  List get filteredUsers {
    final users = usersController.allUsers;
    if (userSearchQuery.value.isEmpty) return users;
    
    return users.where((user) {
      final query = userSearchQuery.value.toLowerCase();
      return user.userName.toLowerCase().contains(query) ||
             user.email.toLowerCase().contains(query) ||
             user.phone.toLowerCase().contains(query);
    }).toList();
  }
  
  List get filteredRiders {
    final riders = ridersController.filteredRiders;
    if (riderSearchQuery.value.isEmpty) return riders;
    
    return riders.where((rider) {
      final query = riderSearchQuery.value.toLowerCase();
      return rider.fullnames.toLowerCase().contains(query) ||
             rider.email.toLowerCase().contains(query) ||
             rider.phone.toLowerCase().contains(query);
    }).toList();
  }

  // Search methods
  void searchUsers(String query) {
    userSearchQuery.value = query;
  }
  
  void searchRiders(String query) {
    riderSearchQuery.value = query;
  }

  void selectRecipientType(RecipientType type) {
    selectedRecipientType.value = type;
    if (type != RecipientType.specific) {
      selectedUserIds.clear();
      selectedRiderIds.clear();
      userSearchQuery.value = '';
      riderSearchQuery.value = '';
      userSearchController.clear();
      riderSearchController.clear();
    }
  }

  void selectNotificationType(NotificationType type) {
    selectedType.value = type;
  }

  void toggleUserSelection(String userId) {
    if (selectedUserIds.contains(userId)) {
      selectedUserIds.remove(userId);
    } else {
      selectedUserIds.add(userId);
    }
    selectedUserIds.refresh();
  }

  void toggleRiderSelection(String riderId) {
    if (selectedRiderIds.contains(riderId)) {
      selectedRiderIds.remove(riderId);
    } else {
      selectedRiderIds.add(riderId);
    }
    selectedRiderIds.refresh();
  }
  void selectAllUsers() {
    selectedUserIds.clear();
    selectedUserIds.addAll(
      filteredUsers.map((u) => u.userId as String)
    );
    selectedUserIds.refresh();
  }

  void deselectAllUsers() {
    selectedUserIds.clear();
    selectedUserIds.refresh();
  }

  void selectAllRiders() {
    selectedRiderIds.clear();
    selectedRiderIds.addAll(
      filteredRiders.map((r) => r.id as String)
    );
    selectedRiderIds.refresh();
  }

  void deselectAllRiders() {
    selectedRiderIds.clear();
    selectedRiderIds.refresh();
  }

  Future<void> sendNotification(BuildContext context) async {
    // Validation
    if (titleController.text.trim().isEmpty) {
      toastService.showError(
        context: context,
        message: 'Please enter a notification title',
      );
      return;
    }
    
    if (messageController.text.trim().isEmpty) {
      toastService.showError(
        context: context,
        message: 'Please enter a notification message',
      );
      return;
    }
    
    if (selectedRecipientType.value == RecipientType.specific) {
      if (selectedUserIds.isEmpty && selectedRiderIds.isEmpty) {
        toastService.showError(
          context: context,
          message: 'Please select at least one recipient',
        );
        return;
      }
    }

    try {
      isSending.value = true;
      bool success = false;
      int recipientCount = 0;

      switch (selectedRecipientType.value) {
        case RecipientType.all:
          success = await notificationService.sendToAllRegistered(
            title: titleController.text.trim(),
            message: messageController.text.trim(),
            context: context,
          );
          recipientCount = usersController.totalUsers + ridersController.totalRiders;
          break;

        case RecipientType.users:
          success = await notificationService.sendToUsers(
            title: titleController.text.trim(),
            message: messageController.text.trim(),
            userIds: usersController.allUsers.map((u) => u.userId).toList(),
            context: context,
          );
          recipientCount = usersController.totalUsers;
          break;

        case RecipientType.riders:
          success = await notificationService.sendToRiders(
            title: titleController.text.trim(),
            message: messageController.text.trim(),
            riderIds: ridersController.filteredRiders.map((r) => r.id).toList(),
            context: context,
          );
          recipientCount = ridersController.totalRiders;
          break;

        case RecipientType.specific:
          bool userSuccess = true;
          bool riderSuccess = true;
          
          if (selectedUserIds.isNotEmpty) {
            userSuccess = await notificationService.sendToUsers(
              title: titleController.text.trim(),
              message: messageController.text.trim(),
              userIds: selectedUserIds.toList(),
              context: context,
            );
          }
          
          if (selectedRiderIds.isNotEmpty) {
            riderSuccess = await notificationService.sendToRiders(
              title: titleController.text.trim(),
              message: messageController.text.trim(),
              riderIds: selectedRiderIds.toList(),
              context: context,
            );
          }
          
          success = userSuccess && riderSuccess;
          recipientCount = selectedUserIds.length + selectedRiderIds.length;
          break;
      }

      if (success) {
        // Add to history
        final notification = NotificationModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: titleController.text.trim(),
          message: messageController.text.trim(),
          sentAt: DateTime.now(),
          recipientCount: recipientCount,
          type: selectedType.value,
          status: NotificationStatus.sent,
        );
        notificationHistory.insert(0, notification);

        toastService.showSuccess(
          context: context,
          message: 'Notification sent successfully to $recipientCount recipient(s)',
        );

        // Clear form
        clearForm();
        
        // Close dialog
        Get.back();
      } else {
        toastService.showError(
          context: context,
          message: 'Failed to send notification',
        );
      }
    } catch (e) {
      toastService.showError(
        context: context,
        message: 'Error sending notification: $e',
      );
    } finally {
      isSending.value = false;
    }
  }

  void clearForm() {
    titleController.clear();
    messageController.clear();
    userSearchController.clear();
    riderSearchController.clear();
    selectedType.value = NotificationType.general;
    selectedRecipientType.value = RecipientType.all;
    selectedUserIds.clear();
    selectedRiderIds.clear();
    userSearchQuery.value = '';
    riderSearchQuery.value = '';
  }

  String getRecipientTypeText(RecipientType type) {
    switch (type) {
      case RecipientType.all:
        return 'All Users & Riders';
      case RecipientType.users:
        return 'All Users';
      case RecipientType.riders:
        return 'All Riders';
      case RecipientType.specific:
        return 'Specific Recipients';
    }
  }

  int get totalRecipients {
    switch (selectedRecipientType.value) {
      case RecipientType.all:
        return usersController.totalUsers + ridersController.totalRiders;
      case RecipientType.users:
        return usersController.totalUsers;
      case RecipientType.riders:
        return ridersController.totalRiders;
      case RecipientType.specific:
        return selectedUserIds.length + selectedRiderIds.length;
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    messageController.dispose();
    userSearchController.dispose();
    riderSearchController.dispose();
    super.onClose();
  }
}