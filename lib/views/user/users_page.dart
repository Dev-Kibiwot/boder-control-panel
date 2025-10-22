import 'package:boder/controller/users_controller.dart';
import 'package:boder/models/users_model.dart';
import 'package:boder/constants/utils/colors.dart';
import 'package:boder/widgets/custom_header.dart';
import 'package:boder/widgets/space.dart';
import 'package:boder/widgets/table/custom_data_table.dart';
import 'package:boder/widgets/table/table_colunm.dart';
import 'package:boder/widgets/text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UsersPage extends StatelessWidget {
  final UsersController usersController = Get.put(UsersController());
  UsersPage({super.key});
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      usersController.fetchUsers(context);
    });
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: Obx(() {
        return Stack(
          children: [
            Column(
              children: [
                CustomHeader(title: "Users"),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        buildStatsSection(context),
                        const SizedBox(height: 24),
                        Expanded(
                          child: Obx(() => CustomDataTable<Map<String, dynamic>>(
                            tag: 'users_table',
                            columns: buildTableColumns(context),
                            data: usersController.filteredUsers.map((user) => user.toMap()).toList(),
                            onSearch: usersController.searchUsers,
                            searchHint: 'Search users by name, email, phone...',
                            isLoading: usersController.isLoading.value,
                            noDataMessage: 'No users found',
                          )),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (usersController.selectedUser.value != null)
              Positioned(
                child: GestureDetector(
                  onTap: usersController.clearSelection,
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                    margin: EdgeInsets.only(right: horizontalSpace(context, 0.3)),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
  Widget buildStatsSection(BuildContext context) {
    return Obx(() {
      return Container(
        height: verticalSpace(context, 0.1),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: LineChart(
          LineChartData(
            lineTouchData: LineTouchData(enabled: false),
            titlesData: FlTitlesData(show: false),
            gridData: FlGridData(show: false),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: usersController.userGrowthData.asMap()
                    .entries
                    .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
                    .toList(),
                isCurved: true,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppColors.blue,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
  Widget buildDefaultAvatar(String name) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.blue, AppColors.blue.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
  buildTableColumns(context) {
    return [
      TableColumn(
        header: 'User',
        key: 'user',
        customWidget: (value, item) {
          final user = Users.fromMap(item);
          return Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: user.image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          user.image!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => 
                          buildDefaultAvatar(user.userName),
                        ),
                      )
                    :buildDefaultAvatar(user.userName),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  user.userName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue
                  ),
                  overflow: TextOverflow.ellipsis,
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
          final user = Users.fromMap(item);
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
        key: 'phoneNumber',
        customWidget: (value, item) {
          final user = Users.fromMap(item);
          return Text(
            user.phone,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryBlue
            ),
          );
        },
      ),
      TableColumn(
        header: 'User Type',
        key: 'userType',
        customWidget: (value, item) {
          final user = Users.fromMap(item);
          return Text(
            user.userTypeDisplay,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: user.userType == 1 
                  ? AppColors.blue
                  : AppColors.textSecondary,
            ),
          );
        },
      ),
      TableColumn(
        header: 'Email Status',
        key: 'emailConfirmed',
        customWidget: (value, item) {
          final user = Users.fromMap(item);
          return Text(
            user.emailConfirmed ? 'Confirmed' : 'Pending',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: user.emailConfirmed 
                  ? Colors.green[700]
                  : Colors.orange[700],
            ),
          );
        },
      ),
      TableColumn(
        header: 'Last Logout',
        key: 'lastLogoutTime',
        customWidget: (value, item) {
          final user = Users.fromMap(item);
          if (user.lastLogoutTime == null) {
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
          final difference = now.difference(user.lastLogoutTime!);
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
                '${user.lastLogoutTime!.day}/${user.lastLogoutTime!.month}/${user.lastLogoutTime!.year}',
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
          final user = Users.fromMap(item);
          return Obx(() => IconButton(
            onPressed: usersController.isDeleting.value ? null  : () => usersController.deleteUser(user, context),
            icon: Icon(
              Icons.delete,
              color: usersController.isDeleting.value 
                  ? Colors.grey 
                  : Colors.red,
              size: 18,
            ),
            tooltip: 'Delete User',
          )
        );
        },
      ),
    ];
  }
}