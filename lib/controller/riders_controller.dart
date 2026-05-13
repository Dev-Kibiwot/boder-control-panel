import 'package:devboder/constants/utils/enums.dart';
import 'package:devboder/models/riders_model.dart';
import 'package:devboder/services/riders_services.dart';
import 'package:devboder/services/toast_service.dart';
import 'package:devboder/views/riders/vehicle_images_carousel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RidersController extends GetxController {
  final RidersServices ridersService = RidersServices();
  final ToastService toastService = ToastService();
  final PageController smallCarouselController = PageController();
  final PageController dialogCarouselController = PageController();
  final dialogCurrentIndex = 0.obs;
  final RxList<Rider> _allRiders = <Rider>[].obs;
  // _filteredRiders holds all results after search/filter; pagedRiders is the current page slice
  final RxList<Rider> _filteredRiders = <Rider>[].obs;
  final RxList<Rider> filteredRiders = <Rider>[].obs; // current page slice shown in table
  final RxString searchQuery = ''.obs;
  final Rx<ApprovalFilter> selectedFilter = ApprovalFilter.all.obs;
  final Rx<VehecleType> selectedvehecle = VehecleType.all.obs;
  final RxBool isLoading = false.obs;
  final RxBool isActionLoading = false.obs;
  final Rxn<Rider> selectedRider = Rxn<Rider>();

  // Pagination state
  final RxInt currentPage = 1.obs;
  final RxInt pageSize = 20.obs;
  final List<int> pageSizeOptions = [10, 20, 50, 100];

  int get totalFilteredCount => _filteredRiders.length;
  int get totalPages => (totalFilteredCount / pageSize.value).ceil().clamp(1, 999999);

  Future<void> fetchRiders(BuildContext context) async {
    try {
      isLoading.value = true;
      await ridersService.getRiders(context);
      final List<Rider> fetchedRiders = (ridersService.riders).map((r) => Rider.fromMap(r)).toList();
      _allRiders.assignAll(fetchedRiders);
      _applyFilters();
    } catch (e) {
      return;
    } finally {
      isLoading.value = false;
    }
  }

  void searchRiders(String query) {
    searchQuery.value = query;
    currentPage.value = 1;
    _applyFilters();
  }

  void filterByApproval(ApprovalFilter filter) {
    selectedFilter.value = filter;
    currentPage.value = 1;
    _applyFilters();
  }

  void filterByType(VehecleType filter) {
    selectedvehecle.value = filter;
    currentPage.value = 1;
    _applyFilters();
  }

  void goToPage(int page) {
    if (page < 1 || page > totalPages) return;
    currentPage.value = page;
    _updatePageSlice();
  }

  void changePageSize(int size) {
    pageSize.value = size;
    currentPage.value = 1;
    _updatePageSlice();
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
    _filteredRiders.assignAll(filtered);
    _updatePageSlice();
  }

  void _updatePageSlice() {
    final start = (currentPage.value - 1) * pageSize.value;
    final end = (start + pageSize.value).clamp(0, _filteredRiders.length);
    if (start >= _filteredRiders.length) {
      currentPage.value = totalPages;
      final s = ((currentPage.value - 1) * pageSize.value).clamp(0, _filteredRiders.length);
      filteredRiders.assignAll(_filteredRiders.sublist(s, _filteredRiders.length));
    } else {
      filteredRiders.assignAll(_filteredRiders.sublist(start, end));
    }
  }

  void clearSelection() {
    selectedRider.value = null;
  }
  Future<void> approveRider(Rider rider, BuildContext context, {VoidCallback? onSuccess}) async {
    try {
      isActionLoading.value = true; 
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
      isActionLoading.value = false; // Changed from isLoading
    }
  }

  Future<void> disapproveRider(Rider rider, BuildContext context, {VoidCallback? onSuccess}) async {
    try {
      isActionLoading.value = true; // Changed from isLoading
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
      isActionLoading.value = false; // Changed from isLoading
    }
  }

  Future<void> deleteRider(Rider rider, BuildContext context) async {
    try {
      isActionLoading.value = true; 
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
        if (selectedRider.value?.id == rider.id) {
          clearSelection();
        }
        toastService.showSuccess(
          context: context,
          message: "${rider.fullnames} deleted successfully",
        );
      }
    } catch (e) {
      print('   ❌ Exception in deleteUser: $e');
    } finally {
      isActionLoading.value = false; 
    }
  }
 
  Future<void> refreshRiders(BuildContext context) async {
    try {
      isLoading.value = true;
      await fetchRiders(context); 
    } catch (e) {
      toastService.showError(
        context: context,
        message: 'Failed to reload data: ${e.toString()}'
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