import 'package:boder/controller/side_nav_controller.dart';
import 'package:boder/controller/dashboard_controller.dart';
import 'package:boder/controller/wallets_controller.dart';
import 'package:boder/widgets/charts/completed_vs_cancelled_chart.dart';
import 'package:boder/widgets/charts/new_users_chart.dart';
import 'package:boder/widgets/charts/traffic_pattern_chart.dart';
import 'package:boder/constants/utils/colors.dart';
import 'package:boder/widgets/custom_header.dart';
import 'package:boder/widgets/space.dart';
import 'package:boder/widgets/spacing.dart';
import 'package:boder/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  final sidebarController = Get.find<SideNavController>();
  final dashboardController = Get.put(DashboardController());
  final wallets = Get.put(WalletsController());

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      dashboardController.refreshAllData(context);
    });
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: Obx(() {
        return Stack(
          children: [
            Column(
              children: [
                CustomHeader(
                  title: "Dashboard",
                  onMenuTap: () => sidebarController.toggleSidebar(),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: buildMetricCard(
                                title: "Riders",
                                value:dashboardController.totalRiders.toString(),
                                subtitle: dashboardController.ridersGrowth,
                                color: AppColors.lightBlue,
                                icon: Icons.pedal_bike_rounded,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: buildMetricCard(
                                title: "Users",
                                value:
                                    dashboardController.totalUsers.toString(),
                                subtitle: dashboardController.usersGrowth,
                                color: AppColors.warning,
                                icon: Icons.people_alt_outlined,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: buildMetricCard(
                                title: "Total Trips",
                                value:
                                    dashboardController.totalTrips.toString(),
                                subtitle: dashboardController.tripsGrowth,
                                color: AppColors.success,
                                icon: Icons.verified,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: buildMetricCard(
                                title: "Active Trips",
                                value:
                                    dashboardController.activeTrips.toString(),
                                subtitle: dashboardController.activeTripsGrowth,
                                color: AppColors.primaryBlue,
                                icon: Icons.local_taxi,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: buildMetricCard(
                                title: "Total Wages",
                                value: wallets.totalBalance.toString(),
                                subtitle: "+12.5%",
                                color: AppColors.success,
                                icon: Icons.account_balance_wallet,
                              ),
                            ),
                          ],
                        ),
                        CustomSpacing(height: 0.03),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  buildChartCard(
                                    title:
                                        "Completed Trips vs. Cancelled Trips",
                                    subtitle:
                                        "${dashboardController.completedTrips - dashboardController.cancelledTrips} more completed",
                                    child: SizedBox(
                                      height: verticalSpace(context, 0.3),
                                      child: const CompletedVsCancelledChart(),
                                    ),
                                  ),
                                  CustomSpacing(height: 0.02),
                                  Column(
                                    children: [
                                      buildChartCard(
                                        title: "New Users and Riders",
                                        subtitle:
                                            "${dashboardController.totalUsers + dashboardController.totalRiders} total registrations",
                                        child: SizedBox(
                                          height: verticalSpace(context, 0.3),
                                          child: const NewUsersChart(),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          buildLegend(
                                            color: Colors.blue,
                                            label: 'Users',
                                          ),
                                          const SizedBox(width: 16),
                                          buildLegend(
                                            color: Colors.green,
                                            label: 'Riders',
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                  ),
                                  CustomSpacing(height: 0.02),
                                  buildChartCard(
                                    title: "Traffic Patterns",
                                    subtitle:
                                        "${dashboardController.totalTrips} Total Trips",
                                    child: SizedBox(
                                      height: verticalSpace(context, 0.3),
                                      child: const TrafficPatternChart(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  buildListCard(
                                    title: "Recent Users and Riders",
                                    items:
                                        dashboardController
                                                .recentUsersAndRiders
                                                .isEmpty
                                            ? [
                                              buildCardItem(
                                                "No recent activity",
                                                "",
                                              ),
                                            ]
                                            : dashboardController
                                                .recentUsersAndRiders
                                                .map(
                                                  (item) => buildCardItem(
                                                    item['name']!,
                                                    item['type']!,
                                                  ),
                                                )
                                                .toList(),
                                  ),
                                  CustomSpacing(height: 0.02),
                                  buildListCard(
                                    title: "Active Locations",
                                    items:dashboardController.activeLocations.isEmpty
                                      ? [
                                        buildCardItem(
                                          "No active locations",
                                          "",
                                        ),
                                      ]
                                      : dashboardController.activeLocations
                                          .map(
                                            (item) => buildCardItem(
                                              item['location']!,
                                              item['requests']!,
                                            ),
                                          ).toList(),
                                  ),
                                  CustomSpacing(height: 0.02),
                                  buildListCard(
                                    title: "Leading Riders",
                                    items:dashboardController.leadingRiders.isEmpty
                                      ? [
                                        buildCardItem(
                                          "No trips completed",
                                          "",
                                        ),
                                      ]
                                      : dashboardController.leadingRiders.map(
                                        (item) => buildCardItem(
                                          item['name']!,
                                          item['trips']!,
                                        ),
                                      ).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (dashboardController.isAnyLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ],
        );
      }),
    );
  }

  Widget buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomText(
                  subtitle,
                  fontSize: 10,
                  textColor: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          CustomSpacing(height: 0.015),
          CustomText(
            title,
            fontSize: 14,
            textColor: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
          CustomSpacing(height: 0.005),
          CustomText(
            value,
            fontSize: 16,
            textColor: AppColors.black,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }

  Widget buildChartCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
              Expanded(
                child: CustomText(
                  title,
                  fontSize: 16,
                  textColor: AppColors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // IconButton(
              //   // onPressed: (conte) => dashboardController.refreshAllData(context),
              //   icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
              // ),
            ],
          ),
          CustomSpacing(height: 0.005),
          CustomText(
            subtitle,
            fontSize: 14,
            textColor: AppColors.success,
            fontWeight: FontWeight.w500,
          ),
          CustomSpacing(height: 0.02),
          child,
        ],
      ),
    );
  }

  Widget buildListCard({required String title, required List<Widget> items}) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          CustomText(
            title,
            fontSize: 16,
            textColor: AppColors.black,
            fontWeight: FontWeight.w600,
          ),
          CustomSpacing(height: 0.02),
          ...items,
        ],
      ),
    );
  }

  Widget buildCardItem(String name, String total) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: CustomText(
              name,
              fontSize: 14,
              textColor: AppColors.black,
              fontWeight: FontWeight.w500,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (total.isNotEmpty) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: CustomText(
                total,
                fontSize: 10,
                textColor: AppColors.warning,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildLegend({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
