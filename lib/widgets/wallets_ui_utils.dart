import 'package:boder/models/wallet_model.dart';
import 'package:boder/constants/utils/colors.dart';
import 'package:boder/widgets/space.dart';
import 'package:boder/widgets/text.dart';
import 'package:flutter/material.dart';

class WalletUIUtils {
  
  static Widget buildDefaultAvatar(String name, {double size = 40}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.blue,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: size > 30 ? 18 : 14,
          ),
        ),
      ),
    );
  }
  
  static Widget buildDialogAvatar(String name) {
    return buildDefaultAvatar(name, size: 50);
  }
  
  static Widget buildDialogDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: CustomText(
              label,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              textColor: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: CustomText(
              value,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              textColor: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  static void showTransactionDetailsDialog(
    BuildContext context,
    WalletTransaction transaction,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: horizontalSpace(context, 0.5),
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusBadge(transaction),
                      const SizedBox(height: 20),
                      buildDialogDetailRow('Transaction ID', transaction.id ?? 'N/A'),
                      buildDialogDetailRow('Receipt Number', transaction.receipt ?? 'N/A'),
                      buildDialogDetailRow('Amount', transaction.formattedAmount),
                      buildDialogDetailRow('Phone Number', transaction.phone ?? 'N/A'),
                      buildDialogDetailRow('Date', transaction.formattedDate),
                      buildDialogDetailRow('Result Description', transaction.resultDesc ?? 'N/A'),
                      if (transaction.checkoutRequestId != null)
                        buildDialogDetailRow('Checkout Request ID', transaction.checkoutRequestId!),
                      if (transaction.merchantRequestId != null)
                        buildDialogDetailRow('Merchant Request ID', transaction.merchantRequestId!),
                      if (transaction.driver != null || transaction.user != null)
                        _buildParticipantInfo(transaction),
                      if (transaction.trip != null)
                        _buildTripInfo(transaction),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildDialogHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.receipt_long,
            color: AppColors.blue,
            size: 24,
          ),
          const SizedBox(width: 12),
          const CustomText(
            'Transaction Details',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            textColor: AppColors.primaryBlue,
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  static Widget _buildStatusBadge(WalletTransaction transaction) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: transaction.isSuccessful 
                ? AppColors.success.withOpacity(0.1)
                : AppColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                transaction.isSuccessful 
                    ? Icons.check_circle 
                    : Icons.warning,
                color: transaction.isSuccessful 
                    ? AppColors.success 
                    : AppColors.warning,
                size: 16,
              ),
              const SizedBox(width: 4),
              CustomText(
                transaction.transactionType,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                textColor: transaction.isSuccessful 
                    ? AppColors.success 
                    : AppColors.warning,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildParticipantInfo(WalletTransaction transaction) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const CustomText(
          'Participant Information',
          fontSize: 16,
          fontWeight: FontWeight.bold,
          textColor: AppColors.primaryBlue,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: transaction.driver?.image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Image.network(
                          transaction.driver!.image!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => 
                              buildDialogAvatar(transaction.participantName),
                        ),
                      )
                    : buildDialogAvatar(transaction.participantName),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      transaction.participantName,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      textColor: AppColors.primaryBlue,
                    ),
                    if (transaction.driver != null) ...[
                      CustomText(
                        transaction.driver!.email,
                        fontSize: 14,
                        textColor: AppColors.textSecondary,
                      ),
                      CustomText(
                        'Driver • ${transaction.driver!.phone}',
                        fontSize: 12,
                        textColor: AppColors.textSecondary,
                      ),
                    ] else if (transaction.user != null) ...[
                      CustomText(
                        transaction.user!.email,
                        fontSize: 14,
                        textColor: AppColors.textSecondary,
                      ),
                      CustomText(
                        'User • ${transaction.user!.phone}',
                        fontSize: 12,
                        textColor: AppColors.textSecondary,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildTripInfo(WalletTransaction transaction) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const CustomText(
          'Trip Information',
          fontSize: 16,
          fontWeight: FontWeight.bold,
          textColor: AppColors.primaryBlue,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Column(
            children: [
              buildDialogDetailRow('Trip ID', transaction.tripId ?? 'N/A'),
              buildDialogDetailRow('Route', transaction.trip!.shortRoute),
              buildDialogDetailRow('Trip Amount', transaction.trip!.formattedAmount),
              if (transaction.trip!.status != null)
                buildDialogDetailRow('Trip Status', transaction.trip!.status!),
            ],
          ),
        ),
      ],
    );
  }

  static Widget buildStatCard(
    String title, 
    String value, 
    IconData icon, 
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Icon(Icons.trending_up, color: AppColors.lightGrey, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          CustomText(
            value, 
            fontSize: 24, 
            fontWeight: FontWeight.bold,
            textColor: AppColors.primaryBlue
          ),
          const SizedBox(height: 4),
          CustomText(
            title, 
            fontSize: 14, 
            textColor: AppColors.textSecondary,
            fontWeight: FontWeight.w500
          ),
        ],
      ),
    );
  }

  static Widget buildTab(String title, bool isActive, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1E3A8A) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  static Widget buildFilterButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    bool isActive = false,
    Color? activeColor,
  }) {
    return Container(
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: isActive 
            ? (activeColor ?? AppColors.primaryBlue).withOpacity(0.1) 
            : Colors.white,
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: isActive 
              ? (activeColor ?? AppColors.primaryBlue) 
              : Colors.grey.shade600,
        ),
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }
}