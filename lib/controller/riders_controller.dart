import 'package:boder/constants/show_dialog.dart';
import 'package:boder/constants/utils/enums.dart';
import 'package:boder/models/riders_model.dart';
import 'package:boder/services/riders_services.dart';
import 'package:boder/services/toast_service.dart';
import 'package:boder/views/riders/vehicle_images_carousel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RidersController extends GetxController {
  final RidersServices ridersService = RidersServices();
  final ToastService toastService = ToastService();
  final PageController smallCarouselController = PageController();
  final PageController dialogCarouselController = PageController();
  final dialogCurrentIndex = 0.obs;
  final RxList<Rider> _allRiders = <Rider>[].obs;
  final RxList<Rider> filteredRiders = <Rider>[].obs;
  final RxString searchQuery = ''.obs;
  final Rx<ApprovalFilter> selectedFilter = ApprovalFilter.all.obs;
  final Rx<VehecleType> selectedvehecle = VehecleType.all.obs;
  final RxBool isLoading = false.obs;
  final Rxn<Rider> selectedRider = Rxn<Rider>();

  Future<void> fetchRiders(BuildContext context) async {
    try {
      isLoading.value = true;
      await ridersService.getRiders(context);
      final List<Rider> fetchedRiders =(ridersService.riders).map((r) => Rider.fromMap(r)).toList();
      _allRiders.assignAll(fetchedRiders);
      filteredRiders.assignAll(fetchedRiders);
    } catch (e) {
      return;
    } finally {
      isLoading.value = false;
    }
  }

  void searchRiders(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void filterByApproval(ApprovalFilter filter) {
    selectedFilter.value = filter;
    _applyFilters();
  }
  void filterByType(VehecleType filter) {
    selectedvehecle.value = filter;
    _applyFilters();
  }

  void _applyFilters() {
  final filtered = _allRiders.where((rider) {
    bool matchesSearch = searchQuery.value.isEmpty ||
        rider.fullnames.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
        rider.email.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
        rider.phone.contains(searchQuery.value) ||
        rider.city.toLowerCase().contains(searchQuery.value.toLowerCase());
    bool matchesFilter = selectedFilter.value == ApprovalFilter.all ||
        (selectedFilter.value == ApprovalFilter.approved && rider.approved) ||
        (selectedFilter.value == ApprovalFilter.pending && !rider.approved);
    bool matchesVehicleType = selectedvehecle.value == VehecleType.all ||
        (selectedvehecle.value == VehecleType.electric && rider.vehicleCategory == 'electric') ||
        (selectedvehecle.value == VehecleType.petroleum && rider.vehicleCategory == 'petroleum');
    return matchesSearch && matchesFilter && matchesVehicleType;
  }).toList();
  filteredRiders.assignAll(filtered);
}

  void clearSelection() {
    selectedRider.value = null;
  }

  Future<void> deleteRider(Rider rider, BuildContext context) async {
    showActionDialog(
      context,
      'Delete Rider',
      'Are you sure you want to delete rider "${rider.fullnames}"? This action cannot be undone.',
      'Cancel',
      'Delete',
      Colors.red,
      () async {
        try {
          isLoading.value = true;
          print('🔍 Controller deleteUser called for rider:');
          
          final success = await ridersService.deleteUser(
            riderId: rider.id,
            context: context,
          );
          
          print('   Delete result: $success');
          
          if (success) {
            print('   ✅ Delete successful, updating local lists');
            _allRiders.removeWhere((r) => r.id == rider.id);
            _applyFilters();
            if (selectedRider.value?.id ==  rider.id) {
              clearSelection();
            }
            toastService.showSuccess(
              context: context,
              message: "${ rider.fullnames} deleted successfully",
            );
          } else {
            print('   ❌ Delete failed');
          }
        } catch (e) {
          print('   ❌ Exception in deleteUser: $e');
        } finally {
          isLoading.value = false;
        }
      },
    );
  }

  Future<void> approveRider(Rider rider, BuildContext context, {VoidCallback? onSuccess}) async {
  try {
    isLoading.value = true;
    await ridersService.approveRider(rider.id, context);
    final index = _allRiders.indexWhere((r) => r.id == rider.id);
    if (index != -1) {
      final updatedVerification = rider.verification.copyWith(isApproved: true);
      final updatedRider = rider.copyWith(verification: updatedVerification);
      _allRiders[index] = updatedRider;
      _applyFilters();
      if (selectedRider.value?.id == rider.id) {
        selectedRider.value = updatedRider;
      }
      toastService.showSuccess(
        context: context, 
        message: 'Rider ${rider.fullnames} has been approved'
      );
      onSuccess?.call();
    }
  } catch (e) {
    toastService.showError(
      context: context, 
      message: 'Failed to approve rider: $e'
    );
  } finally {
    isLoading.value = false;
  }
}

Future<void> disapproveRider(Rider rider, BuildContext context, {VoidCallback? onSuccess}) async {
  try {
    isLoading.value = true;
    await ridersService.disapproveRider(rider.id, context);
    final index = _allRiders.indexWhere((r) => r.id == rider.id);
    if (index != -1) {
      final updatedVerification = rider.verification.copyWith(isApproved: false);
      final updatedRider = rider.copyWith(verification: updatedVerification);
      _allRiders[index] = updatedRider;
      _applyFilters();
      if (selectedRider.value?.id == rider.id) {
        selectedRider.value = updatedRider;
      }
      toastService.showSuccess(
        context: context, 
        message: 'Rider ${rider.fullnames} has been disapproved'
      );
      onSuccess?.call();
    }
  } catch (e) {
    toastService.showError(
      context: context, 
      message: 'Failed to disapprove rider: $e'
    );
  } finally {
    isLoading.value = false;
  }
}

  void showVehicleImagesDialog(Rider rider) {
    dialogCurrentIndex.value = 0;
    dialogCarouselController.addListener(() {
      if (dialogCarouselController.hasClients) {
        dialogCurrentIndex.value = dialogCarouselController.page?.round() ?? 0;
      }
    });
    Get.dialog(
      VehicleImagesDialog(rider: rider),
      barrierDismissible: true,
    );
  }

  void updateDialogIndex(int index) {
    dialogCurrentIndex.value = index;
  }

  void previousImage() {
    if (dialogCurrentIndex.value > 0) {
      dialogCarouselController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void nextImage() {
    dialogCarouselController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void goToImage(int index) {
    dialogCarouselController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  String getFiterText(ApprovalFilter filter) {
    switch (filter) {
      case ApprovalFilter.approved:
        return 'Approved';
      case ApprovalFilter.pending:
        return 'Pending';
      case ApprovalFilter.all:
        return 'All';
    }
  }
  String getFiterType(VehecleType filter) {
  switch (filter) {
    case VehecleType.electric:
      return 'Electric';
    case VehecleType.petroleum:
      return 'Petroleum';
    case VehecleType.all:
      return 'All';
  }
}

  int get totalRiders => _allRiders.length;
  int get approvedRiders => _allRiders.where((r) => r.approved).length;
  int get pendingRiders => _allRiders.where((r) => !r.approved).length;

  @override
  void onClose() {
    smallCarouselController.dispose();
    dialogCarouselController.dispose();
    super.onClose();
  }
}