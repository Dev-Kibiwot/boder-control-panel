import 'package:devboder/constants/utils/enums.dart';
import 'package:devboder/controller/notifications_controller.dart';
import 'package:devboder/constants/utils/colors.dart';
import 'package:devboder/views/notification/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SendNotificationDialog extends StatelessWidget {
  SendNotificationDialog({super.key});
  final NotificationsController controller = Get.put(NotificationsController());
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        constraints: const BoxConstraints(maxWidth: 800),
        padding: const EdgeInsets.all(32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildNotificationTypeSelector(),
              const SizedBox(height: 24),
              _buildTitleField(),
              const SizedBox(height: 16),
              _buildMessageField(),
              const SizedBox(height: 24),
              _buildRecipientTypeSelector(),
              const SizedBox(height: 16),
              Obx(() => _buildRecipientsList()),
              const SizedBox(height: 24),
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Send Notification',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A202C),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Compose and send notifications to users',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF718096),
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () {
            controller.clearForm();
            Get.back();
          },
          icon: const Icon(Icons.close, color: Color(0xFF718096)),
        ),
      ],
    );
  }

  Widget _buildNotificationTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notification Type',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A202C),
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: NotificationType.values.map((type) {
              final isSelected = controller.selectedType.value == type;
              return InkWell(
                onTap: () => controller.selectNotificationType(type),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? type.color.withOpacity(0.1) : const Color(0xFFF7FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? type.color : const Color(0xFFE2E8F0),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        type.icon,
                        size: 18,
                        color: isSelected ? type.color : const Color(0xFF718096),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        type.displayName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? type.color : const Color(0xFF1A202C),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Title',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A202C),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.titleController,
          decoration: InputDecoration(
            hintText: 'Enter notification title',
            hintStyle: const TextStyle(color: Color(0xFFA0AEC0)),
            filled: true,
            fillColor: const Color(0xFFF7FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.blue, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildMessageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Message',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A202C),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.messageController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Enter notification message',
            hintStyle: const TextStyle(color: Color(0xFFA0AEC0)),
            filled: true,
            fillColor: const Color(0xFFF7FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.blue, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildRecipientTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recipients',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A202C),
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: RecipientType.values.map((type) {
              final isSelected = controller.selectedRecipientType.value == type;
              return InkWell(
                onTap: () => controller.selectRecipientType(type),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.blue.withOpacity(0.1) : const Color(0xFFF7FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppColors.blue : const Color(0xFFE2E8F0),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    controller.getRecipientTypeText(type),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? AppColors.blue : const Color(0xFF1A202C),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildRecipientsList() {
    if (controller.selectedRecipientType.value != RecipientType.specific) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select Recipients',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A202C),
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      controller.selectAllUsers();
                      controller.selectAllRiders();
                    },
                    child: Text('Select All', style: TextStyle(color: AppColors.blue)),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      controller.deselectAllUsers();
                      controller.deselectAllRiders();
                    },
                    child: Text('Deselect All', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  child: _buildUsersList(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildRidersList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Text(
            'Users',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF718096),
            ),
          ),
          const SizedBox(width: 8),
          Obx(() {
            final selectedCount = controller.selectedUserIds.length;
            if (selectedCount > 0) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$selectedCount',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blue,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      const SizedBox(height: 8),
      // NEW: Search box for users
      Container(
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: TextField(
          controller: controller.userSearchController,
          onChanged: controller.searchUsers,
          decoration: InputDecoration(
            hintText: 'Search users...',
            hintStyle: const TextStyle(
              color: Color(0xFFA0AEC0),
              fontSize: 12,
            ),
            prefixIcon: const Icon(
              Icons.search,
              size: 16,
              color: Color(0xFF718096),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            isDense: true,
          ),
          style: const TextStyle(fontSize: 12),
        ),
      ),
      const SizedBox(height: 8),
      Expanded(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Obx(() {
            final users = controller.filteredUsers;
            final selectedIds = controller.selectedUserIds.toList();
            
            if (users.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      controller.userSearchQuery.value.isNotEmpty
                          ? Icons.search_off
                          : Icons.people_outline,
                      size: 32,
                      color: const Color(0xFFCBD5E0),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      controller.userSearchQuery.value.isNotEmpty
                          ? 'No users found'
                          : 'No users available',
                      style: const TextStyle(
                        color: Color(0xFF718096),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final isSelected = selectedIds.contains(user.userId);
                
                return CheckboxListTile(
                  value: isSelected,
                  onChanged: (value) {
                    controller.toggleUserSelection(user.userId);
                  },
                  title: Text(
                    user.userName,
                    style: const TextStyle(fontSize: 13),
                  ),
                  subtitle: Text(
                    user.email,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF718096)),
                  ),
                  dense: true,
                  activeColor: AppColors.blue,
                  checkColor: AppColors.white,
                  controlAffinity: ListTileControlAffinity.leading,
                );
              },
            );
          }),
        ),
      ),
    ],
  );
}

Widget _buildRidersList() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Text(
            'Riders',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF718096),
            ),
          ),
          const SizedBox(width: 8),
          Obx(() {
            final selectedCount = controller.selectedRiderIds.length;
            if (selectedCount > 0) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$selectedCount',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blue,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      const SizedBox(height: 8),
      // NEW: Search box for riders
      Container(
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: TextField(
          controller: controller.riderSearchController,
          onChanged: controller.searchRiders,
          decoration: InputDecoration(
            hintText: 'Search riders...',
            hintStyle: const TextStyle(
              color: Color(0xFFA0AEC0),
              fontSize: 12,
            ),
            prefixIcon: const Icon(
              Icons.search,
              size: 16,
              color: Color(0xFF718096),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            isDense: true,
          ),
          style: const TextStyle(fontSize: 12),
        ),
      ),
      const SizedBox(height: 8),
      Expanded(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Obx(() {
            final riders = controller.filteredRiders;
            final selectedIds = controller.selectedRiderIds.toList();
            if (riders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      controller.riderSearchQuery.value.isNotEmpty
                          ? Icons.search_off
                          : Icons.motorcycle_outlined,
                      size: 32,
                      color: const Color(0xFFCBD5E0),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      controller.riderSearchQuery.value.isNotEmpty
                          ? 'No riders found'
                          : 'No riders available',
                      style: const TextStyle(
                        color: Color(0xFF718096),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              itemCount: riders.length,
              itemBuilder: (context, index) {
                final rider = riders[index];
                final isSelected = selectedIds.contains(rider.id);
                
                return CheckboxListTile(
                  value: isSelected,
                  onChanged: (value) {
                    controller.toggleRiderSelection(rider.id);
                  },
                  title: Text(
                    rider.fullnames,
                    style: const TextStyle(fontSize: 13),
                  ),
                  subtitle: Text(
                    rider.email,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF718096)),
                  ),
                  dense: true,
                  activeColor: AppColors.blue,
                  checkColor: AppColors.white,
                  controlAffinity: ListTileControlAffinity.leading,
                );
              },
            );
          }),
        ),
      ),
    ],
  );
}

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () {
            controller.clearForm();
            Get.back();
          },
          child: const Text(
            'Cancel',
            style: TextStyle(color: Color(0xFF718096)),
          ),
        ),
        const SizedBox(width: 12),
        Obx(() {
          return ElevatedButton.icon(
            onPressed: controller.isSending.value
                ? null
                : () => controller.sendNotification(context),
            icon: controller.isSending.value
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.send, size: 18),
            label: Text(
              controller.isSending.value ? 'Sending...' : 'Send Notification',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
          );
        }),
      ],
    );
  }
}