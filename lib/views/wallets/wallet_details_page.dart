import 'package:boder/controller/wallets_controller.dart';
import 'package:boder/models/wallet_model.dart';
import 'package:boder/services/toast_service.dart';
import 'package:boder/constants/utils/colors.dart';
import 'package:boder/widgets/space.dart';
import 'package:boder/widgets/text.dart';
import 'package:boder/widgets/text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WalletDetailsDrawer extends StatelessWidget {
  final Wallet wallet;
  final VoidCallback onClose;
  const WalletDetailsDrawer({
    super.key,
    required this.wallet,
    required this.onClose,
  });
  @override
  Widget build(BuildContext context) {
    final WalletsController controller = Get.find<WalletsController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (wallet.driverId != null) {
        controller.fetchTransactions(context);
      }
    });
    return Material(
      elevation: 16,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        height: MediaQuery.of(context).size.height,
        color: AppColors.white,
        child: Column(
          children: [
            _buildDrawerHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWalletHeader(),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: (){
                        if (wallet.driverId != null) {
                          _showPayRiderDialog(context, controller);
                        }
                      },
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.blue,
                            borderRadius: BorderRadius.circular(4)
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CustomText(
                                "Pay rider", 
                                fontSize: 14, 
                                textColor: AppColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildTabSection(controller,context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(
          bottom: BorderSide(color: AppColors.borderColor),
        ),
      ),
      child: Row(
        children: [
          CustomText(
            'Wallet Details',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            textColor: AppColors.primaryBlue,
          ),
          const Spacer(),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close),
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildWalletHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: wallet.driver?.image != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    wallet.driver!.image!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => 
                        _buildDefaultAvatar(),
                  ),
                )
              : _buildDefaultAvatar(),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: CustomText(
                      wallet.driver?.fullnames ?? 'Unknown Driver',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      textColor: AppColors.primaryBlue,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: wallet.hasRecentActivity 
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomText(
                      wallet.hasRecentActivity ? 'ACTIVE' : 'INACTIVE',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      textColor: wallet.hasRecentActivity 
                          ? AppColors.success 
                          : AppColors.warning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              CustomText(
                wallet.driver?.email ?? 'No email',
                fontSize: 12,
                textColor: AppColors.textSecondary,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildInfoChip(
                    'Balance', 
                    wallet.formattedBalance,
                    AppColors.success,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    'Transactions', 
                    '${wallet.transactionCount ?? 0}',
                    AppColors.blue,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    final name = wallet.driver?.fullnames ?? 'U';
    return Container(
      decoration: BoxDecoration(
        color: AppColors.blue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomText(
            '$label: ',
            fontSize: 10,
            textColor: AppColors.textSecondary,
          ),
          CustomText(
            value,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            textColor: color,
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection(WalletsController controller,BuildContext context) {
    return Column(
      children: [
        _buildTabBar(controller),
        const SizedBox(height: 16),
        SizedBox(
          height: verticalSpace(context, 0.6),
          child: Obx(() => IndexedStack(
            index: controller.walletDetailTabIndex.value,
            children: [
              _buildDetailsTab(),
              _buildTransactionsTab(controller),
            ],
          )),
        ),
      ],
    );
  }

  Widget _buildTabBar(WalletsController controller) {
    return Container(
      child: Row(
        children: [
          Obx(() => _buildTabButton(
            'Details',
            0,
            controller.walletDetailTabIndex.value == 0,
            () => controller.setWalletDetailTab(0),
          )),
          const SizedBox(width: 24),
          Obx(() => _buildTabButton(
            'Transactions',
            1,
            controller.walletDetailTabIndex.value == 1,
            () => controller.setWalletDetailTab(1),
          )),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, int index, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          border: isActive
              ? const Border(
                  bottom: BorderSide(
                    color: AppColors.blue,
                    width: 2,
                  ),
                )
              : null,
        ),
        child: CustomText(
          text,
          fontSize: 14,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          textColor: isActive ? AppColors.blue : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Wallet ID', wallet.id ?? 'N/A'),
          _buildDetailRow('Current Balance', wallet.formattedBalance),
          _buildDetailRow('Total Transactions', '${wallet.transactionCount ?? 0}'),
          _buildDetailRow('Successful Transactions', '${wallet.successfulTransactions ?? 0}'),
          _buildDetailRow('Total Amount', 'KES ${wallet.totalTransactionAmount ?? 0}'),
          _buildDetailRow('Last Transaction ID', wallet.lastTransactionId ?? 'None'),
          _buildDetailRow('Last Updated', wallet.formattedCreatedAt),
          _buildDetailRow('Created At', wallet.formattedCreatedAt),
          if (wallet.driver != null) ...[
            const SizedBox(height: 20),
            CustomText(
              'Driver Information',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              textColor: AppColors.primaryBlue,
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Full Name', wallet.driver!.fullnames),
            _buildDetailRow('Email', wallet.driver!.email),
            _buildDetailRow('Phone', wallet.driver!.phone),
            _buildDetailRow('City', wallet.driver!.city),
            _buildDetailRow('Rating', '${wallet.driver!.rating}/5.0'),
            _buildDetailRow('Completed Trips', '${wallet.driver!.complitedTrips}'),
            _buildDetailRow('Status', wallet.driver!.statusText),
          ],
        ],
      ),
    );
  }

  Widget _buildTransactionsTab(WalletsController controller) {
    return Obx(() {
      if (controller.isLoadingTransactions.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.blue),
        );
      }

      final transactions = controller.filteredTransactions
          .where((t) => t.driverId == wallet.driverId)
          .toList();

      if (transactions.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: AppColors.lightGrey,
              ),
              const SizedBox(height: 12),
              CustomText(
                'No transactions found',
                fontSize: 14,
                textColor: AppColors.textSecondary,
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return _buildTransactionItem(transaction);
        },
      );
    });
  }

  Widget _buildTransactionItem(WalletTransaction transaction) {
    final isSuccessful = transaction.isSuccessful;
    final statusColor = isSuccessful ? AppColors.success : AppColors.warning;
    return GestureDetector(
      onTap: () => _showTransactionDetailsDialog(Get.context!, transaction),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomText(
                  transaction.formattedDate,
                  fontSize: 10,
                  textColor: AppColors.textSecondary,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: CustomText(
                    transaction.transactionType,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    textColor: statusColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            CustomText(
              transaction.transactionType.toUpperCase(),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              textColor: AppColors.primaryBlue,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        transaction.formattedAmount,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        textColor: AppColors.primaryBlue,
                      ),
                      CustomText(
                        'AMOUNT',
                        fontSize: 8,
                        textColor: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
                if (isSuccessful)
                  Row(
                    children: [
                      Icon(
                        Icons.arrow_downward,
                        color: statusColor,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      CustomText(
                        transaction.formattedAmount,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        textColor: statusColor,
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: CustomText(
              label,
              fontSize: 12,
              textColor: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: CustomText(
              value,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              textColor: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  void _showPayRiderDialog(BuildContext context, WalletsController controller) {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: CustomText(
          'Pay Rider',
          fontSize: 16,
          fontWeight: FontWeight.bold,
          textColor: AppColors.primaryBlue,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextFormField(
              darkTheme: false,
              controller: amountController,
              keyboardType: TextInputType.number,
              label: 'Amount (KES)',
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              darkTheme: false,
              controller: descriptionController,
              keyboardType: TextInputType.emailAddress,
              label: 'Description (Optional)',
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () async {
                  Get.back();
                },
                child: const Text('Canciel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final amount = double.tryParse(amountController.text);
                  if (amount != null && amount > 0) {   
                    // await controller.payRider(
                    //   context,
                    //   riderId: wallet.driverId!,
                    //   amount: amount,
                    //   description: descriptionController.text,
                    // );
                  }
                },
                child: const Text('Pay'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showTransactionDetailsDialog(BuildContext context, WalletTransaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titlePadding: EdgeInsets.zero,
        title: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.receipt_long,
                color: AppColors.blue,
                size: 20,
              ),
              const SizedBox(width: 8),
              CustomText(
                'Transaction Details',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                textColor: AppColors.primaryBlue,
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, size: 20),
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogDetailRow('Receipt', transaction.receipt ?? 'N/A'),
              _buildDialogDetailRow('Amount', transaction.formattedAmount),
              _buildDialogDetailRow('Phone', transaction.phone ?? 'N/A'),
              _buildDialogDetailRow('Date', transaction.formattedDate),
              _buildDialogDetailRow('Status', transaction.transactionType),
              _buildDialogDetailRow('Result', transaction.resultDesc ?? 'N/A'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: CustomText(
              label,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              textColor: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: CustomText(
              value,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              textColor: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}