import 'package:boder/constants/utils/enums.dart';
import 'package:boder/controller/trip_controller.dart';
import 'package:boder/models/trip_model.dart';
import 'package:boder/views/trips/trip_details.dart';
import 'package:boder/constants/utils/colors.dart';
import 'package:boder/widgets/custom_header.dart';
import 'package:boder/widgets/space.dart';
import 'package:boder/widgets/table/custom_data_table.dart';
import 'package:boder/widgets/table/table_colunm.dart';
import 'package:boder/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class TripsPage extends StatelessWidget {
  final TripsController tripsController = Get.put(TripsController());
  TripsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: Obx(() {
        return Stack(
          children: [
            Column(
              children: [
                CustomHeader(title: "Trips"),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        buildStatsSection(),
                        const SizedBox(height: 24),
                        Expanded(
                          child: CustomDataTable<Map<String, dynamic>>(
                            tag: 'trip_table',
                            columns: buildTableColumns(),
                            data: tripsController.filteredTrips.map((trip) => trip.toMap()).toList(),
                            onRowTap: (tripMap) {
                              final trip = Trip.fromMap(tripMap);
                              tripsController.selectedTrips(trip);
                            },
                            onSearch: tripsController.searchTrips,
                            searchHint: 'Search riders by name, email, phone, or city...',
                            actionBar: buildFilterBar(),
                            isLoading: tripsController.isLoading.value,
                            noDataMessage: 'No trips found come back later',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          if (tripsController.selectedTrips.value != null)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: TripDetailsDrawer(
                  trip: tripsController.selectedTrips.value!,
                  onClose: tripsController.clearSelection,
                ),
              ),
            ),
            if (tripsController.selectedTrips.value != null)
              Positioned(
                child: GestureDetector(
                  onTap: tripsController.clearSelection,
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
        Expanded(child: buildStatCard('Total Trips', tripsController.totalTrips.toString(), Icons.motorcycle, AppColors.blue)),
        const SizedBox(width: 16),
        Expanded(child: buildStatCard('Complited trips', tripsController.complitedTrips.toString(), Icons.check_circle, AppColors.success)),
        const SizedBox(width: 16),
        Expanded(child: buildStatCard('In progress', tripsController.pendingTrips.toString(), Icons.hourglass_empty, AppColors.warning)),
        const SizedBox(width: 16),
        Expanded(child: buildStatCard('Cancieled', tripsController.cancieledTrips.toString(), Icons.block, AppColors.red)),
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
                child: Icon(
                  icon, 
                  color: color, 
                  size: 20
                ),
              ),
              const Spacer(),
              Icon(
                Icons.trending_up, 
                color: AppColors.lightGrey, 
                size: 16
              ),
            ],
          ),
          CustomText(
            value, 
            fontSize: 28, 
            textColor: AppColors.primaryBlue
          ),
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
      // Status Filter
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
              constraints: const BoxConstraints(minWidth: 100),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.lightGrey.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(6),
                color: AppColors.white,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<TripStatus>(
                  value: tripsController.selectedStatus.value,
                  isDense: true,
                  menuMaxHeight: 200,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryBlue,
                  ),
                  items: TripStatus.values.map((status) {
                    return DropdownMenuItem<TripStatus>(
                      value: status,
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: tripsController.getStatusColor(status),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            tripsController.getStatusText(status),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) tripsController.filterByStatus(value);
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
                  value: tripsController.selectedVehicleType.value,
                  isDense: true,
                  menuMaxHeight: 200,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryBlue,
                  ),
                  items: VehecleType.values.map((type) {
                    return DropdownMenuItem<VehecleType>(
                      value: type,
                      child: Text(
                        tripsController.getVehicleTypeText(type),
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) tripsController.filterByVehicleType(value);
                  },
                  icon: const Icon(Icons.arrow_drop_down, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
      
      // Results Counter
      if (tripsController.selectedStatus.value != TripStatus.all ||
          tripsController.selectedVehicleType.value != VehecleType.all)
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: CustomText(
              '${tripsController.filteredTrips.length}',
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
      header: "Trip ID",
      key: "id",
      flex: 1,
      customWidget: (value, item) {
        final trip = Trip.fromMap(item);
        return CustomText(
          trip.id.substring(0, 8) + '...', 
          fontSize: 12, 
          fontWeight: FontWeight.w600, 
          textColor: AppColors.textSecondary,
          overflow: TextOverflow.ellipsis,
        );
      },
    ),
    TableColumn(
      header: "User",
      key: "passenger",
      flex: 2,
      customWidget: (value, item) {
        final trip = Trip.fromMap(item);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(
              trip.passenger.userName, 
              fontSize: 12, 
              fontWeight: FontWeight.w600, 
              textColor: AppColors.primaryBlue,
              overflow: TextOverflow.ellipsis,
            ),
            CustomText(
              trip.passenger.phone, 
              fontSize: 10, 
              textColor: AppColors.textSecondary,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      },
    ),
    TableColumn(
      header: 'Driver',
      key: 'driver',
      flex: 2,
      customWidget: (value, item) {
        final trip = Trip.fromMap(item);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              trip.rider.fullnames, 
              style: const TextStyle(
                fontSize: 12, 
                fontWeight: FontWeight.w600, 
                color: AppColors.primaryBlue
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              trip.rider.phone, 
              style: const TextStyle(
                fontSize: 10, 
                color: AppColors.textSecondary
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      },
    ),
    TableColumn(
      header: 'Price',
      key: 'price',
      flex: 1,
      customWidget: (value, item) {
        final trip = Trip.fromMap(item);
        return Text(
          'KSh ${trip.price.toStringAsFixed(0)}', 
          style: const TextStyle(
            fontSize: 13, 
            fontWeight: FontWeight.bold, 
            color: AppColors.success
          )
        );
      },
    ),
    TableColumn(
      header: 'Route',
      key: 'route',
      flex: 2,
      customWidget: (value, item) {
        final trip = Trip.fromMap(item);
        return Text(
          trip.shortRoute, 
          style: const TextStyle(
            fontSize: 11, 
            fontWeight: FontWeight.w500, 
            color: AppColors.textSecondary
          ),
          overflow: TextOverflow.ellipsis,
        );
      },
    ),
    TableColumn(
      header: 'Date',
      key: 'created_at',
      flex: 1,
      customWidget: (value, item) {
        final trip = Trip.fromMap(item);
        return CustomText(
          trip.formattedCreatedAt, 
          fontSize: 12, 
          textColor: AppColors.textSecondary,
        );
      },
    ),
    TableColumn(
      header: 'Status',
      key: 'status',
      flex: 1,
      customWidget: (value, item) {
        final trip = Trip.fromMap(item);
        final color = tripsController.getStatusColor(trip.status);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: CustomText(
            trip.statusText, 
            fontSize: 10, 
            fontWeight: FontWeight.w600, 
            textColor: color,
          ),
        );
      },
    ),
  ];
}
}