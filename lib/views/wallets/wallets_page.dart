import 'package:boder/controller/wallets_controller.dart';
import 'package:boder/models/wallet_model.dart';
import 'package:boder/views/wallets/wallet_details_page.dart';
import 'package:boder/widgets/colors.dart';
import 'package:boder/widgets/custom_header.dart';
import 'package:boder/widgets/table/custom_data_table.dart';
import 'package:boder/widgets/table/table_colunm.dart';
import 'package:boder/widgets/text.dart';
import 'package:boder/widgets/wallets_ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WalletsPage extends StatelessWidget {
  final WalletsController controller = Get.put(WalletsController());
  WalletsPage({super.key});
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refreshAll(context);
    });    
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: Obx(() {
        return Stack(
          children: [
            Column(
              children: [
                CustomHeader(
                  title: "Wallets",
                  payRiders: () => controller.payAllDrivers(
                    context, 
                    riderIds: controller.activeWalletRiderIds,
                    description: "Wallet balance payout",
                  ),
                ),
                _buildStatsSection(controller),
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          WalletUIUtils.buildTab(
                            'WALLETS', 
                            controller.selectedTabIndex.value == 0,
                            onTap: () => controller.setSelectedTab(0),
                          ),
                          const SizedBox(width: 32),
                          WalletUIUtils.buildTab(
                            'TRANSACTIONS', 
                            controller.selectedTabIndex.value == 1,
                            onTap: () => controller.setSelectedTab(1),
                          ),
                          const SizedBox(width: 32),
                          Expanded(
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextField(
                                onChanged: controller.selectedTabIndex.value == 0 ? controller.searchWallets : controller.searchTransacitons,
                                decoration: InputDecoration(
                                  hintText: controller.selectedTabIndex.value == 0 
                                      ? 'Search wallets by driver name or wallet ID...'
                                      : 'Search transactions by receipt, driver, or user...',
                                  hintStyle: TextStyle(color: Colors.grey.shade500),
                                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.download, color: Colors.grey.shade600),
                              onPressed: () {
                              },
                              tooltip: 'Export',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Obx(() => IndexedStack(
                      index: controller.selectedTabIndex.value,
                      children: [
                        _buildWalletsTab(controller),
                        _buildTransactionsTab(controller),
                      ],
                    )),
                  ),
                ),
              ],
            ),
            if (controller.selectedWallet.value != null)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: WalletDetailsDrawer(
                    wallet: controller.selectedWallet.value!,
                    onClose: controller.clearWalletSelection,
                  ),
                ),
              ),
            if (controller.selectedWallet.value != null)
              Positioned.fill(
                child: GestureDetector(
                  onTap: controller.clearWalletSelection,
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                    margin: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.4),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
  Widget _buildStatsSection(WalletsController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: AppColors.cardBackground,
      child: Obx(() => Row(
        children: [
          Expanded(
            child: WalletUIUtils.buildStatCard(
              'Total Wallets', 
              controller.totalWallets.toString(), 
              Icons.account_balance_wallet, 
              AppColors.blue
            )
          ),
          const SizedBox(width: 16),
          Expanded(
            child: WalletUIUtils.buildStatCard(
              'Total Balance', 
              controller.formattedTotalBalance, 
              Icons.monetization_on, 
              AppColors.success
            )
          ),
          const SizedBox(width: 16),
          Expanded(
            child: WalletUIUtils.buildStatCard(
              'Active Wallets', 
              controller.activeWalletsCount.toString(), 
              Icons.trending_up, 
              AppColors.warning
            )
          ),
          const SizedBox(width: 16),
          Expanded(
            child:WalletUIUtils.buildStatCard(
              'Transactions', 
              controller.totalTransactionsCount.toString(), 
              Icons.receipt_long, 
              AppColors.primaryBlue
            )
          ),
        ],
      )),
    );
  }
  Widget _buildWalletsTab(WalletsController controller) {
    return Obx(() => CustomDataTable<Map<String, dynamic>>(
      tag: 'wallets_table',
      columns: _buildWalletsTableColumns(),
      data: controller.filteredWallets
          .map((wallet) => wallet.toJson())
          .toList(),
      onRowTap: (walletMap) {
        final wallet = Wallet.fromJson(walletMap);
        controller.selectWallet(wallet);
      },
      onSearch: controller.searchWallets,
      showSearchBar: false,
      searchHint: 'Search wallets by driver name or wallet ID...',
      actionBar: _buildWalletsFilterBar(controller),
      isLoading: controller.isLoading.value,
      noDataMessage: 'No wallets found',
    ));
  }

  Widget _buildTransactionsTab(WalletsController controller) {
    return Obx(() => CustomDataTable<Map<String, dynamic>>(
      tag: 'transactions_table',
      columns: _buildTransactionsTableColumns(),
      data: controller.filteredTransactions
          .map((transaction) => transaction.toJson())
          .toList(),
      onRowTap: (transactionMap) {
        final transaction = WalletTransaction.fromJson(transactionMap);
        WalletUIUtils.showTransactionDetailsDialog(Get.context!, transaction);
      },
      showSearchBar: false,
      actionBar: _buildTransactionsFilterBar(controller),
      isLoading: controller.isLoadingTransactions.value,
      noDataMessage: 'No transactions found',
    ));
  }

  Widget _buildWalletsFilterBar(WalletsController controller) {
    return Obx(() => Row(
      children: [
        CustomText(
          "Show:", 
          fontSize: 14, 
          textColor: AppColors.textSecondary
        ),
        const SizedBox(width: 12),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.lightGrey),
            borderRadius: BorderRadius.circular(8),
            color: AppColors.white,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: controller.showOnlyActiveWallets.value,
                onChanged: (_) => controller.toggleActiveWalletsOnly(),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                activeColor: AppColors.blue,
              ),
              CustomText(
                "Active Only", 
                fontSize: 12, 
                textColor: AppColors.textSecondary
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () => controller.refreshAll(Get.context!),
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('Refresh', style: TextStyle(fontSize: 12)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.blue,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            minimumSize: const Size(0, 40),
          ),
        ),
      ],
    ));
  }

  Widget _buildTransactionsFilterBar(WalletsController controller) {
    return Row(
      children: [
        CustomText(
          "Filter:", 
          fontSize: 14, 
          textColor: AppColors.textSecondary
        ),
        const SizedBox(width: 12),
        Container(
          height: 40,
          width: 120,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.lightGrey),
            borderRadius: BorderRadius.circular(8),
            color: AppColors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: 'All',
              hint: CustomText(
                "All", 
                fontSize: 14, 
                textColor: AppColors.textSecondary
              ),
              isExpanded: true,
              items: ['All', 'Successful', 'Failed', 'Pending']
                  .map((filter) => DropdownMenuItem<String>(
                    value: filter,
                    child: Text(filter, style: const TextStyle(fontSize: 12)),
                  ))
                  .toList(),
              onChanged: (value) {
                // Handle transaction filter change
              },
              icon: const Icon(Icons.keyboard_arrow_down, size: 16),
            ),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () => controller.fetchTransactions(Get.context!),
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('Refresh', style: TextStyle(fontSize: 12)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.blue,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            minimumSize: const Size(0, 40),
          ),
        ),
      ],
    );
  }

  List<TableColumn> _buildWalletsTableColumns() {
    return [
      TableColumn(
        header: 'DRIVER',
        key: 'driver',
        flex: 2,
        customWidget: (value, item) {
          final wallet = Wallet.fromJson(item);
          final driverName = wallet.driver?.fullnames ?? 'Unknown Driver';
          return Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: wallet.driver?.image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          wallet.driver!.image!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => 
                              WalletUIUtils.buildDefaultAvatar(driverName),
                        ),
                      )
                    : WalletUIUtils.buildDefaultAvatar(driverName),
              ),
              const SizedBox(width: 12),
              Text(
                driverName, 
                style: const TextStyle(
                  fontSize: 14, 
                  fontWeight: FontWeight.w600, 
                  color: AppColors.primaryBlue
                ), 
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );
        },
      ),
      TableColumn(
        header: 'BALANCE',
        key: 'balance',
        flex: 1,
        customWidget: (value, item) {
          final wallet = Wallet.fromJson(item);
          final balance = wallet.balance ?? 0.0;
          final color = balance > 0 ? AppColors.success : AppColors.textSecondary;
          
          return Text(
            wallet.formattedBalance,
            style: TextStyle(
              fontSize: 14, 
              fontWeight: FontWeight.w600, 
              color: color
            ),
          );
        },
      ),
      TableColumn(
        header: 'TRANSACTIONS',
        key: 'transactionCount',
        flex: 1,
        customWidget: (value, item) {
          final wallet = Wallet.fromJson(item);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomText(
              '${wallet.transactionCount ?? 0}', 
              fontSize: 12, 
              fontWeight: FontWeight.w600, 
              textColor: AppColors.blue,
            ),
          );
        },
      ),
      TableColumn(
        header: 'SUCCESSFUL',
        key: 'successfulTransactions',
        flex: 1,
        customWidget: (value, item) {
          final wallet = Wallet.fromJson(item);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomText(
              '${wallet.successfulTransactions ?? 0}', 
              fontSize: 12, 
              fontWeight: FontWeight.w600, 
              textColor: AppColors.success,
            ),
          );
        },
      ),
      TableColumn(
        header: 'LAST UPDATED',
        key: 'updated_at',
        flex: 1,
        customWidget: (value, item) {
          final wallet = Wallet.fromJson(item);
          return CustomText(
            wallet.formattedCreatedAt, 
            fontSize: 12, 
            textColor: AppColors.textSecondary,
          );
        },
      ),
    ];
  }

  List<TableColumn> _buildTransactionsTableColumns() {
    return [
      TableColumn(
        header: 'RECEIPT',
        key: 'receipt',
        flex: 2,
        customWidget: (value, item) {
          final transaction = WalletTransaction.fromJson(item);
          return CustomText(
            transaction.receipt ?? 'N/A', 
            fontSize: 12, 
            fontWeight: FontWeight.w600, 
            textColor: AppColors.primaryBlue,
            overflow: TextOverflow.ellipsis,
          );
        },
      ),
      TableColumn(
        header: 'Rider',
        key: 'participant',
        flex: 2,
        customWidget: (value, item) {
          final transaction = WalletTransaction.fromJson(item);
          final participantName = transaction.driver?.fullnames.toString() ?? "";          
          return CustomText(
            participantName, 
            fontSize: 13, 
            fontWeight: FontWeight.w500, 
            textColor: AppColors.primaryBlue,
            overflow: TextOverflow.ellipsis,
          );
        },
      ),
      TableColumn(
        header: 'AMOUNT',
        key: 'amount',
        flex: 1,
        customWidget: (value, item) {
          final transaction = WalletTransaction.fromJson(item);
          return Text(
            transaction.formattedAmount,
            style: const TextStyle(
              fontSize: 14, 
              fontWeight: FontWeight.w600, 
              color: AppColors.success
            ),
          );
        },
      ),
      TableColumn(
        header: 'PHONE',
        key: 'phone',
        flex: 1,
        customWidget: (value, item) {
          final transaction = WalletTransaction.fromJson(item);
          return CustomText(
            transaction.phone ?? 'N/A', 
            fontSize: 12, 
            textColor: AppColors.textSecondary,
          );
        },
      ),
      TableColumn(
        header: 'STATUS',
        key: 'resultDesc',
        flex: 1,
        customWidget: (value, item) {
          final transaction = WalletTransaction.fromJson(item);
          final isSuccessful = transaction.isSuccessful;
          final color = isSuccessful ? AppColors.success : AppColors.warning;
          
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomText(
              transaction.transactionType, 
              fontSize: 11, 
              fontWeight: FontWeight.w600, 
              textColor: color,
            ),
          );
        },
      ),
      TableColumn(
        header: 'DATE',
        key: 'date',
        flex: 1,
        customWidget: (value, item) {
          final transaction = WalletTransaction.fromJson(item);
          return CustomText(
            transaction.formattedDate, 
            fontSize: 12, 
            textColor: AppColors.textSecondary,
          );
        },
      ),
    ];
  }
}