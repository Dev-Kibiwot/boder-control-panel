import 'package:boder/controller/privillage_user_controller.dart';
import 'package:boder/models/privillage_user.dart';
import 'package:boder/widgets/colors.dart';
import 'package:boder/widgets/custom_header.dart';
import 'package:boder/widgets/table/custom_data_table.dart';
import 'package:boder/widgets/table/table_colunm.dart';
import 'package:boder/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RolesPage extends StatelessWidget {
  final PrivilegedUserController privilegedUserController = Get.put(PrivilegedUserController());
  RolesPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      privilegedUserController.getAllPrivilegedUsers();
    });
    
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: Obx(() {
        return Stack(
          children: [
            Column(
              children: [
                CustomHeader(title: "Privileged Users"),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Statistics Row
                        buildStatsRow(),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Obx(() => CustomDataTable<Map<String, dynamic>>(
                            tag: 'privileged_users_table',
                            columns: buildTableColumns(context),
                            data: privilegedUserController.privilegedUsers.map((user) => user.toJson()).toList(),
                            onSearch: (query) {
                              privilegedUserController.searchPrivilegedUsers(query);
                            },
                            searchHint: 'Search privileged users by name, email, phone...',
                            isLoading: privilegedUserController.isLoading.value,
                            noDataMessage: privilegedUserController.searchQuery.value.isNotEmpty 
                              ? 'No privileged users found matching "${privilegedUserController.searchQuery.value}"'
                              : 'No privileged users found',
                          )),
                        ),
                        if (privilegedUserController.totalPages.value > 1)
                          buildPaginationControls(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget buildStatsRow() {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Total Users',
                value: '${privilegedUserController.totalPrivilegedUsers}',
                icon: Icons.people,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Confirmed',
                value: '${privilegedUserController.confirmedUsers}',
                icon: Icons.verified,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Pending',
                value: '${privilegedUserController.pendingUsers}',
                icon: Icons.pending,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Filtered Results',
                value: '${privilegedUserController.filteredPrivilegedUsers.length}',
                icon: Icons.filter_alt,
                color: AppColors.primaryBlue.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPaginationControls(BuildContext context) {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Search results info
            if (privilegedUserController.searchQuery.value.isNotEmpty)
              Text(
                'Showing ${privilegedUserController.filteredPrivilegedUsers.length} results for "${privilegedUserController.searchQuery.value}"',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              )
            else
              const SizedBox(),
            
            // Pagination controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: privilegedUserController.hasPreviousPage 
                      ? () => privilegedUserController.previousPage()
                      : null,
                  icon: const Icon(Icons.chevron_left),
                  tooltip: 'Previous Page',
                ),
                const SizedBox(width: 16),
                Text(
                  'Page ${privilegedUserController.currentPage.value} of ${privilegedUserController.totalPages.value}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: privilegedUserController.hasNextPage 
                      ? () => privilegedUserController.nextPage()
                      : null,
                  icon: const Icon(Icons.chevron_right),
                  tooltip: 'Next Page',
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget buildDefaultAvatar(String name) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.primaryBlue.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'P',
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  List<TableColumn> buildTableColumns(BuildContext context) {
    return [
      TableColumn(
        header: 'User',
        key: 'user',
        customWidget: (value, item) {
          final user = PrivilegedUser.fromJson(item);
          return Row(
            children: [
              buildDefaultAvatar(user.userName),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${user.firstname} ${user.lastname}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (user.firstname.isNotEmpty || user.lastname.isNotEmpty)
                      Text(
                        '${user.firstname} ${user.lastname}'.trim(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      TableColumn(
        header: "Email",
        key: "email",
        customWidget: (value, item) {
          final user = PrivilegedUser.fromJson(item);
          return CustomText(
            user.email,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            textColor: AppColors.textSecondary,
            overflow: TextOverflow.ellipsis,
          );
        },
      ),
      TableColumn(
        header: 'Phone',
        key: 'phone',
        customWidget: (value, item) {
          final user = PrivilegedUser.fromJson(item);
          return Text(
            user.phone.isEmpty ? 'Not provided' : user.phone,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: user.phone.isEmpty ? AppColors.textSecondary : AppColors.primaryBlue,
            ),
          );
        },
      ),
      TableColumn(
        header: 'Role',
        key: 'userType',
        customWidget: (value, item) {
          final user = PrivilegedUser.fromJson(item);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
            ),
            child: Text(
              user.userType,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBlue,
              ),
            ),
          );
        },
      ),
      TableColumn(
        header: 'Email Status',
        key: 'emailConfirmed',
        customWidget: (value, item) {
          final user = PrivilegedUser.fromJson(item);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: user.emailConfirmed ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: user.emailConfirmed ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
              ),
            ),
            child: Text(
              user.emailConfirmed ? 'Confirmed' : 'Pending',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: user.emailConfirmed ? Colors.green[700] : Colors.orange[700],
              ),
            ),
          );
        },
      ),
      TableColumn(
        header: 'Last Login',
        key: 'lastLoginTime',
        customWidget: (value, item) {
          final user = PrivilegedUser.fromJson(item);
          if (user.lastLoginTime == null) {
            return const Text(
              'Never',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            );
          }
          final now = DateTime.now();
          final difference = now.difference(user.lastLoginTime!);
          String timeAgo;
          if (difference.inDays > 0) {
            timeAgo = '${difference.inDays}d ago';
          } else if (difference.inHours > 0) {
            timeAgo = '${difference.inHours}h ago';
          } else if (difference.inMinutes > 0) {
            timeAgo = '${difference.inMinutes}m ago';
          } else {
            timeAgo = 'Just now';
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                timeAgo,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryBlue,
                ),
              ),
              Text(
                '${user.lastLoginTime!.day}/${user.lastLoginTime!.month}/${user.lastLoginTime!.year}',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          );
        },
      ),
      TableColumn(
        header: 'Actions',
        key: 'actions',
        flex: 1,
        customWidget: (value, item) {
          final user = PrivilegedUser.fromJson(item);
          return GestureDetector(
            onTap:privilegedUserController.isDeletingUser.value 
              ? null  
              : () {
                  privilegedUserController.deletePrivilegedUser(user, context);
                },
            child: Icon(
              Icons.delete,
              color: privilegedUserController.isDeletingUser.value 
                  ? Colors.grey 
                  : Colors.red,
              size: 18,
            ),
          );
        },
      ),
    ];
  }
}