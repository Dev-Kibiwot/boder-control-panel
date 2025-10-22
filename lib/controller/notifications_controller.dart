import 'package:boder/constants/utils/enums.dart';
import 'package:boder/controller/users_controller.dart';
import 'package:boder/controller/riders_controller.dart';
import 'package:boder/services/notification_service.dart';
import 'package:boder/services/toast_service.dart';
import 'package:boder/views/notification/notification_model.dart';
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
  
  // Form fields
  final titleController = TextEditingController();
  final messageController = TextEditingController();
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

  void selectRecipientType(RecipientType type) {
    selectedRecipientType.value = type;
    selectedUserIds.clear();
    selectedRiderIds.clear();
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
  }

  void toggleRiderSelection(String riderId) {
    if (selectedRiderIds.contains(riderId)) {
      selectedRiderIds.remove(riderId);
    } else {
      selectedRiderIds.add(riderId);
    }
  }

  void selectAllUsers() {
    selectedUserIds.clear();
    selectedUserIds.addAll(usersController.allUsers.map((u) => u.userId));
  }

  void deselectAllUsers() {
    selectedUserIds.clear();
  }

  void selectAllRiders() {
    selectedRiderIds.clear();
    selectedRiderIds.addAll(ridersController.filteredRiders.map((r) => r.id));
  }

  void deselectAllRiders() {
    selectedRiderIds.clear();
  }

  Future<void> sendNotification(BuildContext context) async {
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
          if (selectedUserIds.isNotEmpty) {
            success = await notificationService.sendToUsers(
              title: titleController.text.trim(),
              message: messageController.text.trim(),
              userIds: selectedUserIds.toList(),
              context: context,
            );
          }
          if (selectedRiderIds.isNotEmpty) {
            success = await notificationService.sendToRiders(
              title: titleController.text.trim(),
              message: messageController.text.trim(),
              riderIds: selectedRiderIds.toList(),
              context: context,
            );
          }
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
    selectedType.value = NotificationType.general;
    selectedRecipientType.value = RecipientType.all;
    selectedUserIds.clear();
    selectedRiderIds.clear();
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
    super.onClose();
  }
}