import 'package:boder/models/wallet_model.dart';
import 'package:boder/models/riders_model.dart';
import 'package:boder/models/users_model.dart';
import 'package:boder/controller/riders_controller.dart';
import 'package:boder/controller/users_controller.dart';
import 'package:boder/services/toast_service.dart';
import 'package:boder/services/wallets_service.dart';
import 'package:boder/views/wallets/wallet_helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WalletsController extends GetxController {
  ToastService toastService = ToastService();
  final WalletsService walletsService = WalletsService();
  final ridersController = Get.find<RidersController>();
  final usersController = Get.find<UsersController>();
  final RxInt selectedTabIndex = 0.obs;
  final Rx<Wallets?> walletsResponse = Rx<Wallets?>(null);
  final RxList<Wallet> allWallets = <Wallet>[].obs;
  final RxList<Wallet> filteredWallets = <Wallet>[].obs;
  final RxList<WalletTransaction> allTransactions = <WalletTransaction>[].obs;
  final RxList<WalletTransaction> filteredTransactions = <WalletTransaction>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingTransactions = false.obs;
  final RxInt walletDetailTabIndex = 0.obs;
  final Rx<Wallet?> selectedWallet = Rx<Wallet?>(null);
  final RxBool showOnlyActiveWallets = false.obs;
  final RxDouble minBalanceFilter = 0.0.obs;
  final RxDouble maxBalanceFilter = double.infinity.obs;
  final RxMap<String, dynamic> walletStats = <String, dynamic>{}.obs;
  // Getters
  int get totalWallets => enhancedStats['totalWallets'] ?? 0;
  double get totalBalance => enhancedStats['totalBalance'] ?? 0.0;
  int get activeWalletsCount => enhancedStats['activeWallets'] ?? 0;
  int get totalTransactionsCount => enhancedStats['totalTransactions'] ?? 0;
  String get formattedTotalBalance => 'KES ${totalBalance.toStringAsFixed(2)}';
  int get totalRidersCount => ridersController.totalRiders;
  int get totalUsersCount => usersController.totalUsers;
  double get averageWalletBalance => enhancedStats['averageBalance'] ?? 0.0;
  double get transactionSuccessRate => enhancedStats['successRate'] ?? 0.0;
  int get successfulTransactionsCount => enhancedStats['successfulTransactions'] ?? 0;
  int get failedTransactionsCount => enhancedStats['failedTransactions'] ?? 0;
  List<Wallet> get walletsWithPositiveBalance => allWallets.where((wallet) => (wallet.balance ?? 0.0) > 0).toList();
  double get totalPositiveBalances => walletsWithPositiveBalance.fold(0.0, (sum, wallet) => sum + (wallet.balance ?? 0.0));
  List<String> get activeWalletRiderIds => allWallets.where((wallet) => wallet.driverId != null && (wallet.balance ?? 0.0) > 0).map((wallet) => wallet.driverId!).toSet().toList();

  Future<void> fetchAllData(BuildContext context) async {
    try {
      isLoading.value = true;
      await Future.wait([
        ridersController.fetchRiders(context),
        usersController.fetchUsers(context),
      ]);
      await Future.wait([
        fetchWallets(context),
        fetchTransactions(context),
      ]);
    } catch (e) {
      toastService.showError(
        context: context,
        message: 'Failed to fetch data: ${e.toString()}'
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchWallets(BuildContext context) async {
    try {
      isLoading.value = true;
      final response = await walletsService.getWallets(context);
      if (response != null && response.data?.wallets != null) {
        final enrichedWallets = response.data!.wallets!.map((wallet) {
          return _enrichWalletWithData(wallet);
        }).toList();
        walletsResponse.value = response;
        allWallets.assignAll(enrichedWallets);
        _applyFilters();
        _updateStats();
      } else {
        allWallets.clear();
        filteredWallets.clear();
      }
    } catch (e) {
      toastService.showError(
        context: context, 
        message: 'Failed to fetch wallets: ${e.toString()}'
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchTransactions(BuildContext context) async {
    try {
      isLoadingTransactions.value = true;
      final transactions = await walletsService.getTransactions(context);
      final enrichedTransactions = transactions.map((transaction) {
        return _enrichTransactionWithData(transaction);
      }).toList();
      allTransactions.assignAll(enrichedTransactions);
      _applyTransactionFilters();
    } catch (e) {
      toastService.showError(
        context: context, 
        message: 'Failed to fetch transactions: ${e.toString()}'
      );
    } finally {
      isLoadingTransactions.value = false;
    }
  }

  Wallet _enrichWalletWithData(Wallet wallet) {
    final rider = wallet.driverId != null ? _getRiderById(wallet.driverId!) : null;
    final enrichedTransactions = wallet.transactions?.map((transaction) {
      return _enrichTransactionWithData(transaction, rider);
    }).toList();
    final associatedUsers = <String, Users>{};
    if (enrichedTransactions != null) {
      for (final transaction in enrichedTransactions) {
        if (transaction.userId != null && transaction.user != null) {
          associatedUsers[transaction.userId!] = transaction.user!;
        }
      }
    }
    return wallet.copyWith(
      driver: rider,
      transactions: enrichedTransactions,
      associatedUsers: associatedUsers.isNotEmpty ? associatedUsers : null,
    );
  }

  WalletTransaction _enrichTransactionWithData(WalletTransaction transaction, [Rider? fallbackRider]) {
    final rider = fallbackRider ?? (transaction.driverId != null ? _getRiderById(transaction.driverId!) : null);
    final user = transaction.userId != null ? _getUserById(transaction.userId!) : null;
    return WalletTransaction(
      id: transaction.id,
      receipt: transaction.receipt,
      amount: transaction.amount,
      phone: transaction.phone,
      tripId: transaction.tripId,
      driverId: transaction.driverId,
      userId: transaction.userId,
      date: transaction.date,
      checkoutRequestId: transaction.checkoutRequestId,
      merchantRequestId: transaction.merchantRequestId,
      resultDesc: transaction.resultDesc,
      trip: transaction.trip,
      walletId: transaction.walletId,
      wallet: transaction.wallet,
      driver: rider,
      user: user,
    );
  }

  Rider? _getRiderById(String riderId) {
    try {
      return ridersController.filteredRiders.firstWhere((rider) => rider.id == riderId);
    } catch (e) {
      return null;
    }
  }

  Users? _getUserById(String userId) {
    try {
      return usersController.allUsers.firstWhere((user) => user.userId == userId);
    } catch (e) {
      return null;
    }
  }

  Future<void> refreshAll(BuildContext context) async {
    await fetchAllData(context);
  }
  
  void setSelectedTab(int index) {
    selectedTabIndex.value = index;
  }

  void setWalletDetailTab(int index) {
    walletDetailTabIndex.value = index;
  }

  void selectWallet(Wallet wallet) {
    selectedWallet.value = wallet;
    walletDetailTabIndex.value = 0; 
  }

  void clearWalletSelection() {
    selectedWallet.value = null;
  }

  Future<void> payRider(BuildContext context, {
    required String riderId,
    required double amount,
    String? description,
  }) async {
    try {
      isLoading.value = true;
      final result = await walletsService.payRiders(
        context,
        riderId: riderId,
        amount: amount,
        description: description,
      );
      if (result != null) {
        toastService.showSuccess(
          context: context,
          message: 'Payment successful!'
        );
        await refreshAll(context);
      }
    } catch (e) {
      toastService.showError(
        context: context,
        message: 'Payment failed: ${e.toString()}'
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> payAllDrivers(BuildContext context, {
    required List<String> riderIds, 
    String? description,
  }) async {
    final Map<String, double> riderPayments = {};
    double totalAmount = 0.0;
    for (String riderId in riderIds) {
      final wallet = getWalletByDriverId(riderId);
      if (wallet != null && (wallet.balance ?? 0.0) > 0) {
        final balance = wallet.balance!;
        riderPayments[riderId] = balance;
        totalAmount += balance;
      }
    }
    final ridersToPayIds = riderPayments.keys.toList();
    if (ridersToPayIds.isEmpty) {
      toastService.showError(
        context: context,
        message: 'No riders have positive balances to pay out.'
      );
      return;
    }
    bool? shouldProceed = await WalletHelpers.showPaymentConfirmationDialog(
      ridersToPayIds: ridersToPayIds,
      riderPayments: riderPayments,
      totalAmount: totalAmount,
      description: description,
      getRiderById: getRiderById,
    );
    if (shouldProceed != true) {
      return;
    }
    try {
      isLoading.value = true;
      WalletHelpers.showProcessingDialog(ridersToPayIds.length);
      int successCount = 0;
      int failureCount = 0;
      List<Map<String, dynamic>> paymentResults = [];
      for (String riderId in ridersToPayIds) {
        try {
          final amount = riderPayments[riderId]!;
          final rider = getRiderById(riderId);
          final riderName = rider?.fullnames ?? 'Unknown Rider';
          final result = await walletsService.payRiders(
            context,
            riderId: riderId,
            amount: amount,
            description: description ?? 'Wallet balance payout',
          );
          if (result != null) {
            successCount++;
            paymentResults.add({
              'riderId': riderId,
              'riderName': riderName,
              'email': rider?.email ?? '',
              'phone': rider?.phone ?? '',
              'amount': amount,
              'status': 'Success',
              'timestamp': DateTime.now().toIso8601String(),
              'transactionId': result.toString(),
            });
          } else {
            failureCount++;
            paymentResults.add({
              'riderId': riderId,
              'riderName': riderName,
              'email': rider?.email ?? '',
              'phone': rider?.phone ?? '',
              'amount': amount,
              'status': 'Failed',
              'timestamp': DateTime.now().toIso8601String(),
              'error': 'Payment processing failed',
            });
          }
        } catch (e) {
          failureCount++;
          final rider = getRiderById(riderId);
          final riderName = rider?.fullnames ?? 'Unknown Rider';
          paymentResults.add({
            'riderId': riderId,
            'riderName': riderName,
            'email': rider?.email ?? '',
            'phone': rider?.phone ?? '',
            'amount': riderPayments[riderId]!,
            'status': 'Failed',
            'timestamp': DateTime.now().toIso8601String(),
            'error': e.toString(),
          });
          continue;
        }
      }
      Get.back();
      await WalletHelpers.generatePaymentReceipt(paymentResults, totalAmount, description);
      if (successCount > 0 && failureCount == 0) {
        toastService.showSuccess(
          context: context,
          message: 'Successfully paid out KES ${totalAmount.toStringAsFixed(2)} to $successCount riders! Receipt downloaded.'
        );
      } else if (successCount > 0 && failureCount > 0) {
        toastService.showWarning(
          context: context,
          message: 'Partially successful: $successCount payments succeeded, $failureCount failed. Check receipt for details.'
        );
      } else {
        toastService.showError(
          context: context,
          message: 'All payments failed. Check receipt for error details.'
        );
      }
      await refreshAll(context);
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      toastService.showError(
        context: context,
        message: 'Payment failed: ${e.toString()}'
      );
    } finally {
      isLoading.value = false;
    }
  }
 
  void searchWallets(String query) {
    searchQuery.value = query.toLowerCase();
    _applyFilters();
  }
  
  void searchTransacitons(String query) {
    searchQuery.value = query.toLowerCase();
    _applyTransactionFilters();
  }

  void clearSearch() {
    searchQuery.value = '';
    _applyFilters();
  }

  void toggleActiveWalletsOnly() {
    showOnlyActiveWallets.toggle();
    _applyFilters();
  }

  void setBalanceFilter({double? min, double? max}) {
    if (min != null) minBalanceFilter.value = min;
    if (max != null) maxBalanceFilter.value = max;
    _applyFilters();
  }

  void clearFilters() {
    searchQuery.value = '';
    showOnlyActiveWallets.value = false;
    minBalanceFilter.value = 0.0;
    maxBalanceFilter.value = double.infinity;
    _applyFilters();
  }

  Wallet? getWalletByDriverId(String driverId) {
    try {
      return allWallets.firstWhere((wallet) => wallet.driverId == driverId);
    } catch (e) {
      return null;
    }
  }

  List<WalletTransaction> get successfulTransactions {
    return allTransactions.successfulTransactions;
  }

  List<WalletTransaction> getTransactionsByDriver(String driverId) {
    return allTransactions.filterByDriver(driverId);
  }

  Rider? getRiderById(String riderId) => _getRiderById(riderId);
  Users? getUserById(String userId) => _getUserById(userId);
  
  String getDriverName(Wallet wallet) {
    return wallet.driver?.fullnames ?? 'Unknown Driver';
  }
  
  String getDriverEmail(Wallet wallet) {
    return wallet.driver?.email ?? '';
  }
  
  String? getDriverImage(Wallet wallet) {
    return wallet.driver?.image;
  }
  
  Map<String, dynamic> get enhancedStats {
    final stats = <String, dynamic>{};
    stats['totalWallets'] = allWallets.length;
    stats['totalBalance'] = allWallets.totalBalance;
    stats['activeWallets'] = allWallets.activeWallets.length;
    stats['totalTransactions'] = allTransactions.length;
    stats['successfulTransactions'] = allTransactions.successfulTransactions.length;
    stats['failedTransactions'] = allTransactions.failedTransactions.length;
    stats['totalRiders'] = ridersController.totalRiders;
    stats['totalUsers'] = usersController.totalUsers;
    stats['averageBalance'] = allWallets.averageBalance;
    stats['successRate'] = allTransactions.successRate;
    return stats;
  }
  
  List<WalletTransaction> getTransactionsByUser(String userId) {
    return allTransactions.filterByUser(userId);
  }
  
  List<Users> get transactionCustomers {
    final customerIds = allTransactions
        .where((t) => t.userId != null)
        .map((t) => t.userId!)
        .toSet();
    
    return customerIds
        .map((id) => _getUserById(id))
        .where((user) => user != null)
        .cast<Users>()
        .toList();
  }

  List<Rider> get allRiders => ridersController.filteredRiders;
  List<Users> get allUsers => usersController.allUsers;
  int get approvedRidersCount => ridersController.approvedRiders;
  int get pendingRidersCount => ridersController.pendingRiders;
  
  void _applyFilters() {
    List<Wallet> filtered = List.from(allWallets);
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((wallet) {
        final driverName = wallet.driverName.toLowerCase();
        final driverEmail = wallet.driverEmail.toLowerCase();
        final driverPhone = wallet.driverPhone.toLowerCase();
        final walletId = wallet.id?.toLowerCase() ?? '';
        final query = searchQuery.value;
        
        return driverName.contains(query) ||
               driverEmail.contains(query) ||
               driverPhone.contains(query) ||
               walletId.contains(query);
      }).toList();
    }
    
    if (showOnlyActiveWallets.value) {
      filtered = filtered.where((wallet) => 
        (wallet.balance ?? 0.0) > 0
      ).toList();
    }
    
    filtered = filtered.where((wallet) {
      final balance = wallet.balance ?? 0.0;
      return balance >= minBalanceFilter.value && 
             balance <= maxBalanceFilter.value;
    }).toList();

    filteredWallets.assignAll(filtered);
  }

  void _applyTransactionFilters() {
    List<WalletTransaction> filtered = List.from(allTransactions);
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((transaction) {
        final driverName = transaction.driver?.fullnames.toLowerCase() ?? '';
        final userName = transaction.user?.userName.toLowerCase() ?? '';
        final receipt = transaction.receipt?.toLowerCase() ?? '';
        final phone = transaction.phone?.toLowerCase() ?? '';
        final query = searchQuery.value;
        return driverName.contains(query) ||
               userName.contains(query) ||
               receipt.contains(query) ||
               phone.contains(query);
      }).toList();
    }
    filteredTransactions.assignAll(filtered);
  }

  void _updateStats() {
    walletStats.value = enhancedStats;
  }

  @override
  void onClose() {
    walletsService.clearCache();
    super.onClose();
  }
}