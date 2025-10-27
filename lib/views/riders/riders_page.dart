import 'package:boder/constants/utils/enums.dart';
import 'package:boder/controller/riders_controller.dart';
import 'package:boder/models/riders_model.dart';
import 'package:boder/views/riders/rider_details.dart';
import 'package:boder/constants/utils/colors.dart';
import 'package:boder/widgets/space.dart';
import 'package:boder/widgets/table/custom_data_table.dart';
import 'package:boder/widgets/custom_header.dart';
import 'package:boder/widgets/table/table_colunm.dart';
import 'package:boder/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RidersPage extends StatelessWidget {
  final RidersController ridersController = Get.put(RidersController());
  RidersPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: Obx(() {
        return Stack(
          children: [
            Column(
              children: [
                CustomHeader(title: "Riders"),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        buildStatsSection(),
                        const SizedBox(height: 24),
                        Expanded(
                          child: CustomDataTable<Map<String, dynamic>>(
                            tag: 'riders_table',
                            columns: buildTableColumns(),
                            data: ridersController.filteredRiders.toMapList(),
                            onRowTap: (riderMap) {
                              final rider = Rider.fromMap(riderMap);
                              ridersController.selectedRider.value = rider;
                            },
                            onSearch: ridersController.searchRiders,
                            searchHint: 'Search riders by name, email, phone, or city...',
                            actionBar: buildFilterBar(),
                            isLoading: ridersController.isLoading.value,
                            noDataMessage: 'No riders found',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (ridersController.selectedRider.value != null)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: RiderDetailsDrawer(
                    rider: ridersController.selectedRider.value!,
                    onClose: ridersController.clearSelection,
                  ),
                ),
              ),
            if (ridersController.selectedRider.value != null)
              Positioned(
                child: GestureDetector(
                  onTap: ridersController.clearSelection,
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

  Widget buildStatsSection() {
    return Obx(() => Row(
      children: [
        Expanded(child: buildStatCard('Total Riders', ridersController.totalRiders.toString(), Icons.motorcycle, AppColors.blue)),
        const SizedBox(width: 16),
        Expanded(child: buildStatCard('Approved', ridersController.approvedRiders.toString(), Icons.check_circle, AppColors.success)),
        const SizedBox(width: 16),
        Expanded(child: buildStatCard('Pending', ridersController.pendingRiders.toString(), Icons.hourglass_empty, AppColors.warning)),
      ],
    ));
  }

  Widget buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Icon(Icons.trending_up, color: AppColors.lightGrey, size: 16),
            ],
          ),
          CustomText(value, fontSize: 28, textColor: AppColors.primaryBlue),
          const SizedBox(height: 4),
          CustomText(
            title, 
            fontSize: 14, 
            textColor: AppColors.textSecondary,
            fontWeight: FontWeight.w500
          ),
        ],
      ),
    );
  }

  Widget buildFilterBar() {
  return Obx(() => Row(
    children: [
      // Approval Status Filter
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_list,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            CustomText(
              "Status:", 
              fontSize: 12, 
              fontWeight: FontWeight.w600,
              textColor: AppColors.textSecondary
            ),
            const SizedBox(width: 8),
            Container(
              height: 32,
              constraints: const BoxConstraints(minWidth: 90),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.lightGrey.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(6),
                color: AppColors.white,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<ApprovalFilter>(
                  value: ridersController.selectedFilter.value,
                  isDense: true,
                  menuMaxHeight: 200,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryBlue,
                  ),
                  items: ApprovalFilter.values.map((filter) {
                    return DropdownMenuItem<ApprovalFilter>(
                      value: filter,
                      child: Text(
                        ridersController.getFiterText(filter),
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) ridersController.filterByApproval(value);
                  },
                  icon: const Icon(Icons.arrow_drop_down, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
      
      const SizedBox(width: 12),
      
      // Vehicle Type Filter
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.directions_bike,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            CustomText(
              "Vehicle:", 
              fontSize: 12, 
              fontWeight: FontWeight.w600,
              textColor: AppColors.textSecondary
            ),
            const SizedBox(width: 8),
            Container(
              height: 32,
              constraints: const BoxConstraints(minWidth: 90),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.lightGrey.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(6),
                color: AppColors.white,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<VehecleType>(
                  value: ridersController.selectedvehecle.value,
                  isDense: true,
                  menuMaxHeight: 200,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryBlue,
                  ),
                  items: VehecleType.values.map((filter) {
                    return DropdownMenuItem<VehecleType>(
                      value: filter,
                      child: Text(
                        ridersController.getFiterType(filter),
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) ridersController.filterByType(value);
                  },
                  icon: const Icon(Icons.arrow_drop_down, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
      
      // Results Counter (Compact)
      if (ridersController.selectedFilter.value != ApprovalFilter.all ||
          ridersController.selectedvehecle.value != VehecleType.all)
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: CustomText(
              '${ridersController.filteredRiders.length}',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              textColor: AppColors.blue,
            ),
          ),
        ),
    ],
  ));
}

  buildTableColumns() {
    return [
      TableColumn(
        header: 'RIDER',
        key: 'rider',
        flex: 2,
        customWidget: (value, item) {
          final rider = Rider.fromMap(item);
          return Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: rider.image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      rider.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => buildDefaultAvatar(rider.fullnames),
                    ),
                  )
                : buildDefaultAvatar(rider.fullnames),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  rider.fullnames, 
                  style: const TextStyle(
                    fontSize: 14, 
                    fontWeight: FontWeight.w600, 
                    color: AppColors.primaryBlue
                  ), 
                overflow: TextOverflow.ellipsis),
              ),
            ],
          );
        },
      ),
      TableColumn(
        header: "Email",
         key: "email",
         flex: 2,
         customWidget: (value, item) {
          final rider = Rider.fromMap(item);
          return CustomText(
            rider.email, 
            fontSize: 12, 
            fontWeight: FontWeight.w600, 
            textColor:AppColors.textSecondary,
            overflow: TextOverflow.ellipsis,
          );
        },
      ),
      TableColumn(
        header: 'Phone',
        key: 'phone',
        flex: 2,
        customWidget: (value, item) {
          final rider = Rider.fromMap(item);
          return Text(
            rider.phone, 
            style: const TextStyle(
              fontSize: 13, 
              fontWeight: FontWeight.w500, 
              color: AppColors.primaryBlue
            )
          );
        },
      ),
      TableColumn(
        header: 'ID NUMBER',
        key: 'idNumber',
        flex: 2,
        customWidget: (value, item) {
          final rider = Rider.fromMap(item);
          return Text(
            rider.idNumber, 
            style: const TextStyle(
              fontSize: 13, 
              fontWeight: FontWeight.w500, 
              color: AppColors.primaryBlue
            )
          );
        },
      ),
      TableColumn(
        header: 'vehicle type',
        key: 'vehicle',
        flex: 2,
        customWidget: (value, item) {
          final rider = Rider.fromMap(item);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              rider.vehicleCategory!, 
              style: const TextStyle(
                fontSize: 12, 
                fontWeight: FontWeight.w500, 
                color: AppColors.black
              )
            ),
          );
        },
      ),
      TableColumn(
        header: 'CITY',
        key: 'city',
        flex: 1,
        customWidget: (value, item) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              value.toString(), 
              style: const TextStyle(
                fontSize: 12, 
                fontWeight: FontWeight.w500, 
                color: AppColors.black
              )
            ),
          );
        },
      ),
      TableColumn(
        header: 'STATUS',
        key: 'approved',
        flex: 1,
        customWidget: (value, item) {
          final rider = Rider.fromMap(item);
          final color = rider.verification.isApproved ? AppColors.success : AppColors.warning;
          final statusText = rider.approved ? 'Approved' : 'Pending';
          return Center(
            child: CustomText(
              statusText, 
              fontSize: 12, 
              fontWeight: FontWeight.w600, 
              textColor: color,
            ),
          );
        },
      ),
      TableColumn(
        header: 'DOB',
        key: 'formattedJoinedDate',
        flex: 1,
        customWidget: (value, item) {
          final rider = Rider.fromMap(item);
          return CustomText(
            '${rider.joinedDate.day}/${rider.joinedDate.month}/${rider.joinedDate.year}', 
            fontSize: 13, 
            textColor: AppColors.textSecondary,
          );
        },
      ),
    ];
  }

  Widget buildDefaultAvatar(String name) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: AppColors.blue, borderRadius: BorderRadius.circular(20)),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'R',
          style: const TextStyle(
            color: AppColors.white, 
            fontWeight: FontWeight.bold, 
            fontSize: 16
          ),
        ),
      ),
    );
  }
}