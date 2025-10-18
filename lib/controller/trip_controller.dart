import 'package:boder/constants/utils/enums.dart';
import 'package:boder/models/trip_model.dart';
import 'package:boder/services/toast_service.dart';
import 'package:boder/services/trip_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TripsController extends GetxController {
  ToastService toastService = ToastService();
  final RxList<Trip> allTrips = <Trip>[].obs;
  final RxList<Trip> filteredTrips = <Trip>[].obs;
  final RxString searchQuery = ''.obs;
  final Rx<TripStatus> selectedStatus = TripStatus.all.obs;
  final RxBool isLoading = false.obs;
  final Rxn<Trip> selectedTrips = Rxn<Trip>();
  final TripService tripService = TripService();

  Future<void> fetchTrips(BuildContext context) async {
    try {
      isLoading.value = true;
      if (!tripService.isAuthenticated) {
        toastService.showError(
          context: context,
          message: 'Please login to continue',
        );
        return;
      }
      final List<Trip> fetchedTrips = await tripService.getParsedTrips(context);
      
      if (fetchedTrips.isNotEmpty) {
        allTrips.assignAll(fetchedTrips);
        filteredTrips.assignAll(fetchedTrips);
        _applyFilters();
      } else {
        allTrips.clear();
        filteredTrips.clear();
        toastService.showInfo(
          context: context,
          message: 'No trips found',
        );
      }
    } catch (e) {
      toastService.showError(
        context: context,
        message: 'Failed to fetch trips: ${e.toString()}',
      );
      allTrips.clear();
      filteredTrips.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshTrips(BuildContext context) async {
    await fetchTrips(context);
  }

  searchTrips(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void filterByStatus(TripStatus status) {
    selectedStatus.value = status;
    _applyFilters();
  }

  void _applyFilters() {
    List<Trip> filtered = List.from(allTrips);
    if (selectedStatus.value != TripStatus.all) {
      switch (selectedStatus.value) {
        case TripStatus.completed:
          filtered = filtered.where((trip) => trip.isCompleted).toList();
          break;
        case TripStatus.active:
          filtered = filtered.where((trip) => trip.isActive && !trip.isCompleted && !trip.isCancelled).toList();
          break;
        case TripStatus.cancelled_by_user:
          filtered = filtered.where((trip) => trip.isCancelled).toList();
          break;
        case TripStatus.rejected:
          filtered = filtered.where((trip) => trip.isRejected).toList();
          break;
        default:
          filtered = filtered.where((trip) => trip.status == selectedStatus.value).toList();
      }
    }
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((trip) {
        return trip.passenger.userName.toLowerCase().contains(query) ||
          trip.rider.fullnames.toLowerCase().contains(query) ||
          trip.passenger.email.toLowerCase().contains(query) ||
          trip.passenger.phone.contains(searchQuery.value) ||
          trip.id.toLowerCase().contains(query) ||
          trip.pickupLocation.toLowerCase().contains(query) ||
          trip.destinationLocation.toLowerCase().contains(query);
      }).toList();
    }
    filteredTrips.assignAll(filtered);
  }

  void selectTrip(Trip trip) {
    selectedTrips.value = trip;
  }

  void clearSelection() {
    selectedTrips.value = null;
  }

  String getStatusText(TripStatus status) {
    switch (status) {
      case TripStatus.completed:
        return 'Completed';
      case TripStatus.active:
        return 'Active';
      case TripStatus.cancelled_by_user:
        return 'Cancelled';
      case TripStatus.rejected:
        return 'Rejected';
      case TripStatus.all:
        return 'All';
    }
  }

  Color getStatusColor(TripStatus status) {
    switch (status) {
      case TripStatus.completed:
        return Colors.green;
      case TripStatus.active:
        return Colors.orange;
      case TripStatus.cancelled_by_user:
      case TripStatus.rejected:
        return Colors.red;
      case TripStatus.all:
        return Colors.blue;
    }
  }

  int get totalTrips => allTrips.length;
  int get pendingTrips => allTrips.where((t) => t.isPending).length;
  int get activeTrips => allTrips.where((t) => t.isInProgress).length;
  int get completedTrips => allTrips.where((t) => t.isCompleted).length;
  int get cancelledTrips => allTrips.where((t) => t.isCancelled).length;
  int get rejectedTrips => allTrips.where((t) => t.isRejected).length;
  int get complitedTrips => completedTrips; 
  int get cancieledTrips => cancelledTrips;
}