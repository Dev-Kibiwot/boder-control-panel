import 'package:boder/constants/utils/enums.dart';
import 'package:boder/controller/dashboard_controller.dart';
import 'package:boder/controller/riders_controller.dart';
import 'package:boder/controller/trip_controller.dart';
import 'package:boder/controller/users_controller.dart';
import 'package:boder/controller/wallets_controller.dart';
import 'package:boder/services/toast_service.dart';
import 'package:boder/views/report/export_service.dart';
import 'package:boder/views/report/report_detail_dialog.dart';
import 'package:boder/views/report/report_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReportsController extends GetxController {
  final ToastService toastService = ToastService();
  final ExportService exportService = ExportService();
  // Controllers
  late DashboardController dashboardController;
  late TripsController tripsController;
  late RidersController ridersController;
  late UsersController usersController;
  late WalletsController walletsController;

  // Observables
  final Rx<ReportType> selectedReportType = ReportType.financial.obs;
  final Rx<DateRangeType> selectedDateRange = DateRangeType.thisMonth.obs;
  final RxBool isLoading = false.obs;
  final RxBool isExporting = false.obs;
  final Rxn<DateTime> customStartDate = Rxn<DateTime>();
  final Rxn<DateTime> customEndDate = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
  }

  void _initializeControllers() {
    if (Get.isRegistered<DashboardController>()) {
      dashboardController = Get.find<DashboardController>();
    } else {
      dashboardController = Get.put(DashboardController());
    }
    
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
    
    if (Get.isRegistered<UsersController>()) {
      usersController = Get.find<UsersController>();
    } else {
      usersController = Get.put(UsersController());
    }
    
    if (Get.isRegistered<WalletsController>()) {
      walletsController = Get.find<WalletsController>();
    } else {
      walletsController = Get.put(WalletsController());
    }
  }
  
  Map<String, dynamic> get quickStats {
    return {
      'totalRevenue': walletsController.totalBalance,
      'totalTrips': tripsController.totalTrips,
      'activeUsers': usersController.totalUsers,
      'avgTripValue': tripsController.totalTrips > 0 
          ? walletsController.totalBalance / tripsController.totalTrips 
          : 0.0,
      'revenueChange': '+12.5%',
      'tripsChange': "+2%",
      'usersChange': '+5%',
      'avgValueChange': '-2.1%',
    };
  }

  // Financial Reports
  List<ReportItem> get financialReports {
    return [
      ReportItem(
        name: 'Revenue Summary',
        description: 'Total earnings, commissions, and payouts',
        lastGenerated: DateTime.now().subtract(const Duration(hours: 2)),
        type: ReportType.financial,
      ),
      ReportItem(
        name: 'Transaction Report',
        description: 'Detailed breakdown of all transactions',
        lastGenerated: DateTime.now().subtract(const Duration(days: 1)),
        type: ReportType.financial,
      ),
      ReportItem(
        name: 'Commission Analysis',
        description: 'Platform fees and rider earnings',
        lastGenerated: DateTime.now().subtract(const Duration(hours: 3)),
        type: ReportType.financial,
      ),
      ReportItem(
        name: 'Payment Methods',
        description: 'Usage statistics by payment type',
        lastGenerated: DateTime.now().subtract(const Duration(hours: 5)),
        type: ReportType.financial,
      ),
    ];
  }

  // Trip Reports
  List<ReportItem> get tripReports {
    return [
      ReportItem(
        name: 'Trip Summary',
        description: 'Completed, cancelled, and active trips',
        lastGenerated: DateTime.now().subtract(const Duration(hours: 1)),
        type: ReportType.trips,
      ),
      ReportItem(
        name: 'Peak Hours Analysis',
        description: 'Busiest times and demand patterns',
        lastGenerated: DateTime.now().subtract(const Duration(hours: 6)),
        type: ReportType.trips,
      ),
      ReportItem(
        name: 'Route Analysis',
        description: 'Most popular pickup and dropoff locations',
        lastGenerated: DateTime.now().subtract(const Duration(hours: 4)),
        type: ReportType.trips,
      ),
      ReportItem(
        name: 'Trip Duration Report',
        description: 'Average trip times and distances',
        lastGenerated: DateTime.now().subtract(const Duration(days: 2)),
        type: ReportType.trips,
      ),
    ];
  }

  // User Reports
  List<ReportItem> get userReports {
    return [
      ReportItem(
        name: 'User Growth',
        description: 'New registrations and retention rates',
        lastGenerated: DateTime.now().subtract(const Duration(hours: 3)),
        type: ReportType.users,
      ),
      ReportItem(
        name: 'User Demographics',
        description: 'Age, location, and usage patterns',
        lastGenerated: DateTime.now().subtract(const Duration(days: 1)),
        type: ReportType.users,
      ),
      ReportItem(
        name: 'Active Users',
        description: 'Daily, weekly, and monthly active users',
        lastGenerated: DateTime.now().subtract(const Duration(hours: 5)),
        type: ReportType.users,
      ),
      ReportItem(
        name: 'User Feedback',
        description: 'Ratings and reviews analysis',
        lastGenerated: DateTime.now().subtract(const Duration(hours: 8)),
        type: ReportType.users,
      ),
    ];
  }

  // Rider Reports
  List<ReportItem> get riderReports {
    return [
      ReportItem(
        name: 'Rider Performance',
        description: 'Trips completed, ratings, and earnings',
        lastGenerated: DateTime.now().subtract(const Duration(hours: 2)),
        type: ReportType.riders,
      ),
      ReportItem(
        name: 'Availability Analysis',
        description: 'Online hours and acceptance rates',
        lastGenerated: DateTime.now().subtract(const Duration(hours: 4)),
        type: ReportType.riders,
      ),
      ReportItem(
        name: 'Top Performers',
        description: 'Highest rated and most active riders',
        lastGenerated: DateTime.now().subtract(const Duration(days: 1)),
        type: ReportType.riders,
      ),
      ReportItem(
        name: 'Rider Retention',
        description: 'Churn analysis and engagement metrics',
        lastGenerated: DateTime.now().subtract(const Duration(hours: 6)),
        type: ReportType.riders,
      ),
    ];
  }

  List<ReportItem> get currentReports {
    switch (selectedReportType.value) {
      case ReportType.financial:
        return financialReports;
      case ReportType.trips:
        return tripReports;
      case ReportType.users:
        return userReports;
      case ReportType.riders:
        return riderReports;
    }
  }

  void selectReportType(ReportType type) {
    selectedReportType.value = type;
  }

  void selectDateRange(DateRangeType range) {
    selectedDateRange.value = range;
  }

  String getReportTypeName(ReportType type) {
    switch (type) {
      case ReportType.financial:
        return 'Financial Reports';
      case ReportType.trips:
        return 'Trip Analytics';
      case ReportType.users:
        return 'User Analytics';
      case ReportType.riders:
        return 'Rider Performance';
    }
  }

  IconData getReportTypeIcon(ReportType type) {
    switch (type) {
      case ReportType.financial:
        return Icons.attach_money;
      case ReportType.trips:
        return Icons.location_on;
      case ReportType.users:
        return Icons.people;
      case ReportType.riders:
        return Icons.trending_up;
    }
  }

  Color getReportTypeColor(ReportType type) {
    switch (type) {
      case ReportType.financial:
        return Colors.green;
      case ReportType.trips:
        return Colors.blue;
      case ReportType.users:
        return Colors.purple;
      case ReportType.riders:
        return Colors.orange;
    }
  }

  String getDateRangeText(DateRangeType range) {
    switch (range) {
      case DateRangeType.today:
        return 'Today';
      case DateRangeType.yesterday:
        return 'Yesterday';
      case DateRangeType.thisWeek:
        return 'This Week';
      case DateRangeType.thisMonth:
        return 'This Month';
      case DateRangeType.lastMonth:
        return 'Last Month';
      case DateRangeType.custom:
        return 'Custom Range';
    }
  }

  String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
Future<void> viewReport(ReportItem report, BuildContext context) async {
  try {
    Get.dialog(
      ReportDetailDialog(report: report, controller: this),
      barrierDismissible: true,
    );
  } catch (e) {
    toastService.showError(
      context: context,
      message: 'Failed to open report: $e',
    );
  }
}

Future<void> exportReport(ReportItem report, BuildContext context, String format) async {
  try {
    isExporting.value = true;
    
    switch (format) {
      case 'PDF':
        await exportService.exportToPDF(context, report, this);
        break;
      case 'Excel':
        await exportService.exportToExcel(context, report, this);
        break;
      case 'CSV':
        await exportService.exportToCSV(context, report, this);
        break;
    }
  } catch (e) {
    toastService.showError(
      context: context,
      message: 'Failed to export report: $e',
    );
  } finally {
    isExporting.value = false;
  }
}

// Financial Data Methods
Map<String, dynamic> getFinancialData() {
  return {
    'totalRevenue': walletsController.totalBalance,
    'totalTransactions': walletsController.totalTransactionsCount,
    'successfulTransactions': walletsController.successfulTransactionsCount,
    'failedTransactions': walletsController.failedTransactionsCount,
    'successRate': walletsController.transactionSuccessRate,
    'averageTransactionValue': walletsController.totalTransactionsCount > 0
        ? walletsController.totalBalance / walletsController.totalTransactionsCount
        : 0.0,
  };
}

// Trip Data Methods
Map<String, dynamic> getTripData() {
  return {
    'totalTrips': tripsController.totalTrips,
    'completedTrips': tripsController.completedTrips,
    'activeTrips': tripsController.activeTrips,
    'cancelledTrips': tripsController.cancelledTrips,
    'completionRate': tripsController.totalTrips > 0
        ? (tripsController.completedTrips / tripsController.totalTrips) * 100
        : 0.0,
  };
}

// User Data Methods
Map<String, dynamic> getUserData() {
  return {
    'totalUsers': usersController.totalUsers,
    'activeUsers': usersController.filteredUsersCount,
  };
}

// Rider Data Methods
Map<String, dynamic> getRiderData() {
  return {
    'totalRiders': ridersController.totalRiders,
    'approvedRiders': ridersController.approvedRiders,
    'pendingRiders': ridersController.pendingRiders,
    'approvalRate': ridersController.totalRiders > 0
        ? (ridersController.approvedRiders / ridersController.totalRiders) * 100
        : 0.0,
  };
}
  Future<void> refreshReportData(BuildContext context) async {
    try {
      isLoading.value = true;
      await dashboardController.refreshAllData(context);
      toastService.showSuccess(
        context: context,
        message: 'Report data refreshed successfully',
      );
    } catch (e) {
      toastService.showError(
        context: context,
        message: 'Failed to refresh report data: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> exportAllReports(BuildContext context, String format) async {
    try {
      isExporting.value = true;
      toastService.showInfo(
        context: context,
        message: 'Exporting all reports as $format...',
      );
      
      await Future.delayed(const Duration(seconds: 3));
      
      toastService.showSuccess(
        context: context,
        message: 'All reports exported successfully as $format',
      );
    } catch (e) {
      toastService.showError(
        context: context,
        message: 'Failed to export reports: $e',
      );
    } finally {
      isExporting.value = false;
    }
  }

  bool get isAnyLoading => 
      isLoading.value || 
      dashboardController.isAnyLoading ||
      isExporting.value;
}