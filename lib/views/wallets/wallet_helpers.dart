import 'package:boder/services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:boder/models/riders_model.dart';
import 'package:boder/widgets/colors.dart';

class WalletHelpers {
  static Future<bool?> showPaymentConfirmationDialog({
    required List<String> ridersToPayIds,
    required Map<String, double> riderPayments,
    required double totalAmount,
    required String? description,
    required Rider? Function(String) getRiderById,
  }) async {
    return await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
            const SizedBox(width: 8),
            Text('Confirm Balance Payout', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to pay each rider their wallet balance?',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Riders to pay:', style: TextStyle(fontWeight: FontWeight.w500)),
                        Text('${ridersToPayIds.length}', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total payout:', style: TextStyle(fontWeight: FontWeight.w500)),
                        Text(
                          'KES ${totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Payment breakdown:', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 150,
                      child: _buildRidersList(ridersToPayIds, riderPayments, getRiderById),
                    ),
                    if (description != null) ...[
                      const SizedBox(height: 8),
                      Text('Description:', style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text(description, style: TextStyle(color: Colors.grey.shade700)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Each rider will receive their current wallet balance. This action cannot be undone.',
                style: TextStyle(
                  color: Colors.red.shade600,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Confirm Payout'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  static void showProcessingDialog(int ridersCount) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.blue),
              const SizedBox(height: 16),
              Text(
                'Processing balance payout to $ridersCount riders...',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Please wait, this may take a moment.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static Future<void> generatePaymentReceipt(
    List<Map<String, dynamic>> paymentResults, 
    double totalAmount, 
    String? description,

  ) async {
    try {
      final DateTime now = DateTime.now();
      final String timestamp = '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}';
      final StringBuffer csvContent = StringBuffer();
      csvContent.writeln('BODER PAYMENT RECEIPT');
      csvContent.writeln('Generated: $timestamp');
      csvContent.writeln('Description: ${description ?? "Wallet balance payout"}');
      csvContent.writeln('Total Amount: KES ${totalAmount.toStringAsFixed(2)}');
      csvContent.writeln('Total Riders: ${paymentResults.length}');
      csvContent.writeln('Successful Payments: ${paymentResults.where((r) => r['status'] == 'Success').length}');
      csvContent.writeln('Failed Payments: ${paymentResults.where((r) => r['status'] == 'Failed').length}');
      csvContent.writeln('');
      csvContent.writeln('Rider Name,Email,Phone,Amount (KES),Status,Transaction ID,Error Details,Timestamp');
      for (var result in paymentResults) {
        final name = result['riderName'] ?? 'Unknown';
        final email = result['email'] ?? '';
        final phone = result['phone'] ?? '';
        final amount = (result['amount'] as double).toStringAsFixed(2);
        final status = result['status'] ?? 'Unknown';
        final transactionId = result['transactionId'] ?? '';
        final error = result['error'] ?? '';
        final timestamp = result['timestamp'] ?? '';
        final escapedName = '"${name.replaceAll('"', '""')}"';
        final escapedEmail = '"${email.replaceAll('"', '""')}"';
        final escapedError = '"${error.replaceAll('"', '""')}"';
        csvContent.writeln('$escapedName,$escapedEmail,$phone,$amount,$status,$transactionId,$escapedError,$timestamp');
      }
      final String dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
      final String timeStr = '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
      final String filename = 'payment_receipt_${dateStr}_$timeStr.csv';
      await _saveToDownloads(csvContent.toString(), filename);
    } catch (e) {
      Get.snackbar(
        'Receipt Error',
        'Failed to generate payment receipt: $e',
        backgroundColor: AppColors.warning.withOpacity(0.1),
        colorText: AppColors.warning,
      );
      
    }
  }
  static Future<void> _saveToDownloads(String content, String filename) async {
    try {
      Directory? downloadsDir;
      if (Platform.isWindows) {
        final String userProfile = Platform.environment['USERPROFILE'] ?? '';
        if (userProfile.isNotEmpty) {
          downloadsDir = Directory('$userProfile\\Downloads');
        }
      }
      downloadsDir ??= await getApplicationDocumentsDirectory();
      final String fullPath = '${downloadsDir.path}${Platform.pathSeparator}$filename';
      final File file = File(fullPath);
      await file.writeAsString(content, encoding: utf8);
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.success, size: 24),
              SizedBox(width: 8),
              Text('Receipt Downloaded', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Payment receipt has been saved successfully!'),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('File saved to:', style: TextStyle(fontWeight: FontWeight.w500)),
                    SizedBox(height: 4),
                    SelectableText(
                      fullPath,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: AppColors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (Platform.isWindows) {
                  await Process.run('explorer', ['/select,', fullPath]);
                }
              },
              child: Text('Open Folder'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
              ),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      _showReceiptDialog(content, filename);
    }
  }

  static void _showReceiptDialog(String content, String filename) {
    Get.dialog(
      AlertDialog(
        title: Text('Payment Receipt'),
        content: SizedBox(
          width: 600,
          height: 500,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Unable to save file automatically. Please copy the content below and save as "$filename":'),
              SizedBox(height: 16),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      content,
                      style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  static Widget _buildRidersList(
    List<String> ridersToPayIds, 
    Map<String, double> riderPayments,
    Rider? Function(String) getRiderById,
  ) {
    const int maxItemsToShow = 6;
    if (ridersToPayIds.length <= maxItemsToShow) {
      return ListView.builder(
        itemCount: ridersToPayIds.length,
        itemBuilder: (context, index) {
          final riderId = ridersToPayIds[index];
          final amount = riderPayments[riderId]!;
          final rider = getRiderById(riderId);
          final riderName = rider?.fullnames ?? 'Unknown Rider';
          return _buildRiderListItem(riderName, amount);
        },
      );
    } else {
      return ListView.builder(
        itemCount: maxItemsToShow + 1,
        itemBuilder: (context, index) {
          if (index < 3) {
            final riderId = ridersToPayIds[index];
            final amount = riderPayments[riderId]!;
            final rider = getRiderById(riderId);
            final riderName = rider?.fullnames ?? 'Unknown Rider';
            return _buildRiderListItem(riderName, amount);
          } else if (index == 3) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Text(
                  '... ${ridersToPayIds.length - 6} more riders ...',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            );
          } else {
            final actualIndex = ridersToPayIds.length - (maxItemsToShow + 1 - index);
            final riderId = ridersToPayIds[actualIndex];
            final amount = riderPayments[riderId]!;
            final rider = getRiderById(riderId);
            final riderName = rider?.fullnames ?? 'Unknown Rider';
            return _buildRiderListItem(riderName, amount);
          }
        },
      );
    }
  }

  static Widget _buildRiderListItem(String riderName, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              riderName,
              style: TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            'KES ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}