import 'package:boder/models/riders_model.dart';
import 'package:boder/services/payment_service.dart';
import 'package:boder/services/wallets_service.dart';
import 'package:boder/services/toast_service.dart';
import 'package:boder/views/wallets/wallet_helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentController extends GetxController {
  final PaymentService _paymentService = PaymentService();
  final WalletsService _walletsService = WalletsService();
  final ToastService _toastService = ToastService();
  
  // Observable state
  final RxBool isProcessingPayment = false.obs;
  final RxBool isProcessingBatchPayment = false.obs;
  final RxList<Map<String, dynamic>> paymentQueue = <Map<String, dynamic>>[].obs;
  
  /// Pay a single rider
  Future<bool> payRider(
    BuildContext context, {
    required String riderId,
    required double amount,
    String? description,
  }) async {
    try {
      isProcessingPayment.value = true;
      
      print('🔍 PayRider Debug:');
      print('   riderId: $riderId');
      print('   amount: $amount');
      print('   description: $description');
      
      final result = await _walletsService.payRiders(
        context,
        riderId: riderId,
        amount: amount,
        description: description,
      );
      
      if (result != null) {
        _toastService.showSuccess(
          context: context,
          message: 'Payment successful!'
        );
        return true;
      } else {
        _toastService.showError(
          context: context,
          message: 'Payment failed. Please try again.'
        );
        return false;
      }
    } catch (e) {
      print('   Exception in payRider: $e');
      _toastService.showError(
        context: context,
        message: 'Payment failed: ${e.toString()}'
      );
      return false;
    } finally {
      isProcessingPayment.value = false;
    }
  }

  /// Pay all drivers using batch payout API
  Future<bool> payAllDrivers(
    BuildContext context, {
    required Map<String, double> riderPayments, // riderId -> amount
    required Map<String, Rider?> ridersMap, // riderId -> Rider
    String? description,
  }) async {
    // Build payment list with phone numbers from rider data
    final List<Map<String, dynamic>> payouts = [];
    double totalAmount = 0.0;
    final Map<String, String> riderPhones = {};
    
    print('🔍 PayAllDrivers Debug:');
    print('   Total riders to pay: ${riderPayments.length}');
    
    for (var entry in riderPayments.entries) {
      final riderId = entry.key;
      final balance = entry.value;
      final rider = ridersMap[riderId];
      
      print('   Processing rider: $riderId');
      print('   - Balance: $balance');
      print('   - Rider found: ${rider != null}');
      print('   - Rider phone: ${rider?.phone}');
      
      if (balance > 0 && rider != null) {
        String? phoneNumber = rider.phone;
        
        // Ensure phone number is in correct format (254...)
        if (phoneNumber != null && phoneNumber.isNotEmpty) {
          // Remove any spaces, dashes, or special characters
          phoneNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
          
          // Handle different phone number formats
          if (phoneNumber.startsWith('0')) {
            // Convert 0712345678 to 254712345678
            phoneNumber = '254${phoneNumber.substring(1)}';
          } else if (phoneNumber.startsWith('+254')) {
            // Convert +254712345678 to 254712345678
            phoneNumber = phoneNumber.substring(1);
          } else if (phoneNumber.startsWith('+')) {
            // Remove + from any other country code
            phoneNumber = phoneNumber.substring(1);
          } else if (!phoneNumber.startsWith('254')) {
            // If doesn't start with 254, add it
            phoneNumber = '254$phoneNumber';
          }
          
          print('   - Formatted phone: $phoneNumber');
          
          payouts.add({
            "phoneNumber": phoneNumber,
            "amount": balance.toInt(), // Convert to int for M-Pesa
          });
          riderPhones[riderId] = phoneNumber;
          totalAmount += balance;
        } else {
          print('   - Skipped: Invalid phone number');
        }
      }
    }
    
    print('   Total payouts prepared: ${payouts.length}');
    print('   Total amount: KES ${totalAmount.toStringAsFixed(2)}');
    
    if (payouts.isEmpty) {
      _toastService.showError(
        context: context,
        message: 'No riders have valid phone numbers and positive balances to pay out.'
      );
      return false;
    }

    // Show confirmation dialog
    bool? shouldProceed = await WalletHelpers.showPaymentConfirmationDialog(
      ridersToPayIds: riderPayments.keys.toList(),
      riderPayments: riderPayments,
      totalAmount: totalAmount,
      description: description,
      getRiderById: (riderId) => ridersMap[riderId],
    );

    if (shouldProceed != true) {
      print('   Payment cancelled by user');
      return false;
    }

    try {
      isProcessingBatchPayment.value = true;
      WalletHelpers.showProcessingDialog(payouts.length);

      print('   Sending batch payout request...');
      
      // Process batch payout using the payment service
      final result = await _paymentService.processBatchPayout(
        payouts: payouts,
        remarks: description ?? 'Wallet balance payout - ${DateTime.now()}',
        context: context,
      );

      Get.back(); // Close processing dialog

      if (result != null) {
        print('   Batch payout successful!');
        print('   Result: $result');
        
        // Generate payment results for receipt
        List<Map<String, dynamic>> paymentResults = [];
        
        for (var entry in riderPayments.entries) {
          final riderId = entry.key;
          final amount = entry.value;
          final rider = ridersMap[riderId];
          final phone = riderPhones[riderId] ?? '';
          
          paymentResults.add({
            'riderId': riderId,
            'riderName': rider?.fullnames ?? 'Unknown Rider',
            'email': rider?.email ?? '',
            'phone': phone,
            'amount': amount,
            'status': 'Success',
            'timestamp': DateTime.now().toIso8601String(),
            'transactionId': result['batchId'] ?? result['id'] ?? 'BATCH_${DateTime.now().millisecondsSinceEpoch}',
          });
        }

        // Generate receipt
        await WalletHelpers.generatePaymentReceipt(
          paymentResults, 
          totalAmount, 
          description
        );

        _toastService.showSuccess(
          context: context,
          message: 'Successfully paid out KES ${totalAmount.toStringAsFixed(2)} to ${payouts.length} riders! Receipt downloaded.'
        );

        return true;
      } else {
        print('   Batch payout failed - null result');
        _toastService.showError(
          context: context,
          message: 'Batch payout failed. Please try again.'
        );
        return false;
      }
    } catch (e) {
      print('   Exception during batch payout: $e');
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      _toastService.showError(
        context: context,
        message: 'Payment failed: ${e.toString()}'
      );
      return false;
    } finally {
      isProcessingBatchPayment.value = false;
    }
  }

  /// Add a rider to payment queue
  void addToPaymentQueue({
    required String riderId,
    required String phoneNumber,
    required double amount,
  }) {
    paymentQueue.add({
      "riderId": riderId,
      "phoneNumber": phoneNumber,
      "amount": amount,
    });
  }

  /// Remove a rider from payment queue
  void removeFromPaymentQueue(int index) {
    if (index >= 0 && index < paymentQueue.length) {
      paymentQueue.removeAt(index);
    }
  }

  /// Clear payment queue
  void clearPaymentQueue() {
    paymentQueue.clear();
  }

  /// Calculate total amount in payment queue
  double get totalQueueAmount {
    if (paymentQueue.isEmpty) return 0.0;
    return paymentQueue.fold(
      0.0, 
      (sum, item) => sum + (item['amount'] as double)
    );
  }

  /// Get count of items in payment queue
  int get paymentQueueCount => paymentQueue.length;

  /// Format phone number to Kenyan format (254...)
  String? formatPhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) return null;
    
    // Remove any spaces, dashes, or special characters
    String phoneNumber = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Handle different phone number formats
    if (phoneNumber.startsWith('0')) {
      return '254${phoneNumber.substring(1)}';
    } else if (phoneNumber.startsWith('+254')) {
      return phoneNumber.substring(1);
    } else if (phoneNumber.startsWith('+')) {
      return phoneNumber.substring(1);
    } else if (!phoneNumber.startsWith('254')) {
      return '254$phoneNumber';
    }
    
    return phoneNumber;
  }

  /// Validate phone number
  bool isValidPhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) return false;
    final formatted = formatPhoneNumber(phone);
    return formatted != null && 
           formatted.startsWith('254') && 
           formatted.length >= 12;
  }
}