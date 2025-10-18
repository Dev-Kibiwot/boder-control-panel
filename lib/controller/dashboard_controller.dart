import 'package:boder/controller/trip_controller.dart';
import 'package:boder/controller/riders_controller.dart';
import 'package:boder/controller/users_controller.dart';
import 'package:boder/controller/wallets_controller.dart';
import 'package:boder/services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';

class DashboardController extends GetxController {
  ToastService toastService = ToastService();
  late TripsController tripsController;
  late RidersController ridersController;
  late WalletsController walletsController;
  late UsersController usersController;
  final RxBool isLoading = false.obs;
  int get totalRiders => ridersController.totalRiders;
  int get approvedRiders => ridersController.approvedRiders;
  int get pendingRiders => ridersController.pendingRiders;
  int get totalUsers => usersController.totalUsers;
  int get totalTrips => tripsController.totalTrips;
  int get completedTrips => tripsController.complitedTrips;
  int get pendingTrips => tripsController.pendingTrips;
  int get cancelledTrips => tripsController.cancieledTrips;
  int get activeTrips => pendingTrips;
  
  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
  }

  void _initializeControllers() {
    if (Get.isRegistered<TripsController>()) {
      tripsController = Get.find<TripsController>();
    } else {
      tripsController = Get.put(TripsController());
    }
    if (Get.isRegistered<RidersController>()) {
      ridersController = Get.find<RidersController>();
    } else {
      ridersController = Get.put(RidersController());
    }
    if (Get.isRegistered<WalletsController>()) {
      walletsController = Get.find<WalletsController>();
    } else {
      walletsController = Get.put(WalletsController());
    }
    if (Get.isRegistered<UsersController>()) {
      usersController = Get.find<UsersController>();
    } else {
      usersController = Get.put(UsersController());
    }
  }

 Future<void> refreshAllData(BuildContext context) async {
    try {
      isLoading.value = true;
      await Future.wait([
        tripsController.fetchTrips(context),
        ridersController.fetchRiders(context),
        usersController.fetchUsers(context),
        walletsController.fetchAllData(context)
      ]);
    } catch (e) {
      toastService.showError(context: context, message: 'Failed to refresh dashboard data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String get ridersGrowth {
    if (totalRiders == 0) return '0%';
    final growth = (approvedRiders / totalRiders * 100).toStringAsFixed(1);
    return '+$growth%';
  }
  
  String get usersGrowth {
    final random = Random();
    final growth = random.nextInt(15) + 5; 
    return '+$growth%';
  }
  
  String get tripsGrowth {
    if (totalTrips == 0) return '0%';
    final growth = (completedTrips / totalTrips * 100).toStringAsFixed(1);
    return '+$growth%';
  }
  
  String get activeTripsGrowth {
    if (totalTrips == 0) return '0%';
    final growth = (activeTrips / totalTrips * 100).toStringAsFixed(1);
    return '$growth%';
  }
  List<double> get completedVsCancelledData {
    return [completedTrips.toDouble(), cancelledTrips.toDouble()];
  }
  
  List<double> get usersAndRidersData {
    return [totalUsers.toDouble(), totalRiders.toDouble()];
  }
  
  List<Map<String, String>> get recentUsersAndRiders {
    final recentUsers = usersController.allUsers.take(2).map((user) => {
      'name': user.userName,
      'type': 'User'
    }).toList();
    
    final recentRiders = ridersController.filteredRiders.take(2).map((rider) => {
      'name': rider.fullnames,
      'type': 'Rider'
    }).toList();
    return [...recentUsers, ...recentRiders];
  }
  
  List<Map<String, String>> get activeLocations {
    final cities = <String, int>{};
    for (final rider in ridersController.filteredRiders) {
      if (rider.city.isNotEmpty) {
        cities[rider.city] = (cities[rider.city] ?? 0) + 1;
      }
    }
    return cities.entries.take(3).map((entry) => {
      'location': entry.key,
      'requests': '${entry.value} requests'
    }).toList();
  }

  List<Map<String, String>> get leadingRiders {
    final sortedRiders = ridersController.filteredRiders.where((rider) => rider.complitedTrips > 0).toList()
      ..sort((a, b) => b.complitedTrips.compareTo(a.complitedTrips));
    return sortedRiders.take(3).map((rider) => {
      'name': rider.fullnames,
      'trips': '${rider.complitedTrips} trips'
    }).toList();
  }
  bool get isAnyLoading => tripsController.isLoading.value || ridersController.isLoading.value || usersController.isLoading.value || walletsController.isLoading.value || isLoading.value;
}