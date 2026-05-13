import 'package:devboder/controller/side_nav_controller.dart';
import 'package:devboder/views/home/home_page.dart';
import 'package:devboder/views/report/reports_page.dart';
import 'package:devboder/views/riders/riders_page.dart';
import 'package:devboder/views/roles/roles_page.dart';
import 'package:devboder/views/trips/trips_page.dart';
import 'package:devboder/views/user/users_page.dart';
import 'package:devboder/views/wallets/wallets_page.dart';
import 'package:devboder/constants/utils/colors.dart';
import 'package:devboder/controller/side_nav_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'side_nav.dart';

class MainLayout extends StatelessWidget {
  MainLayout({super.key});
  final SideNavController sidebarController = Get.put(SideNavController());
  final List<Widget> pages = [
    HomePage(),
    RidersPage(),
    UsersPage(),
    TripsPage(),
    WalletsPage(),
    ReportsPage(),
    RolesPage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: Row(
        children: [
          Obx(() => SideNav(
            selectedIndex: sidebarController.selectedIndex.value,
            onItemSelected: sidebarController.setIndex,
            isCollapsed: sidebarController.isCollapsed.value,
            onProfileTap: () { },
           )
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
              ),
              child: Obx(() => pages[sidebarController.selectedIndex.value]),
            ),
          ),
        ],
      ),
    );
  }
}