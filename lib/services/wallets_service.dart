import 'package:boder/models/wallet_model.dart';
import 'package:boder/services/api_config.dart';
import 'package:boder/services/toast_service.dart';
import 'package:boder/constants/utils/errors_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

class WalletsService extends GetConnect {
  final storage = GetStorage();
  ToastService toastService = ToastService();
  Wallets? walletsResponse;
  List<WalletTransaction> transactions = [];

  Future<Wallets?> getWallets(BuildContext context) async {
    final token = storage.read('token');
    try {
      final response = await get(
        ApiConfig.wallets,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        if (response.body != null) {
          walletsResponse = Wallets.fromJson(response.body);
          return walletsResponse;
        }
        return null;
      } else if (response.statusCode == 401) {
        await _handleUnauthorized(context);
        return null;
      } else {
        toastService.showError(
          context: context, 
          message: extractErrorMessage(response)
        );
        return null;
      }
    } catch (e) {
      toastService.showError(
        context: context, 
        message: "Network error: ${e.toString()}"
      );
      return null;
    }
  }

  Future<List<WalletTransaction>> getTransactions(BuildContext context) async {
    final token = storage.read('token');
    try {
      final response = await get(
        ApiConfig.transactions,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        if (response.body != null) {
          List<dynamic> transactionData = [];
          if (response.body['data'] != null && response.body['data']['transactions'] != null) {
            transactionData = response.body['data']['transactions'];
          } else if (response.body['transactions'] != null) {
            transactionData = response.body['transactions'];
          } else if (response.body is List) {
            transactionData = response.body;
          }
          transactions = transactionData.map((json) => WalletTransaction.fromJson(json)).toList();
          return transactions;
        }
        return [];
      } else if (response.statusCode == 401) {
        await _handleUnauthorized(context);
        return [];
      } else {
        toastService.showError(
          context: context, 
          message: extractErrorMessage(response)
        );
        return [];
      }
    } catch (e) {
      toastService.showError(
        context: context, 
        message: "Network error: ${e.toString()}"
      );
      return [];
    }
  }
  
  Future<Map<String, dynamic>?> payRiders(BuildContext context, {
    String? riderId,
    double? amount,
    String? description,
  }) async {
      final token = storage.read('token');
      try {
        final requestBody = {
          if (riderId != null) 'rider_id': riderId,
          if (amount != null) 'amount': amount,
          if (description != null) 'description': description,
        };
        final response = await post(
          ApiConfig.payRiders,
          requestBody,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
        if (response.statusCode == 200) {
          if (response.body != null) {
            return response.body;
          }
          return null;
        } else if (response.statusCode == 401) {
          await _handleUnauthorized(context);
          return null;
        } else {
          toastService.showError(
            context: context, 
            message: extractErrorMessage(response)
          );
          return null;
        }
      } catch (e) {
        toastService.showError(
          context: context, 
          message: "Network error: ${e.toString()}"
        );
        return null;
      }
    }

  Future<Map<String, dynamic>?> payAllRiders(BuildContext context, {
    List<String>? riderIds,
    double? totalAmount,
    String? description
  }) async {
    final token = storage.read('token');
    try {
      final requestBody = {
        if (riderIds != null) 'rider_ids': riderIds,
        if (totalAmount != null) 'total_amount': totalAmount,
        if (description != null) 'description': description,
      };
      final response = await post(
        ApiConfig.payRiders,
        requestBody,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        if (response.body != null) {
          return response.body;
        }
        return null;
      } else if (response.statusCode == 401) {
        await _handleUnauthorized(context);
        return null;
      } else {
        toastService.showError(
          context: context, 
          message: extractErrorMessage(response)
        );
        return null;
      }
    } catch (e) {
      toastService.showError(
        context: context, 
        message: "Network error: ${e.toString()}"
      );
      return null;
    }
  }

  Future<Wallet?> getWalletByDriverId(BuildContext context, String driverId) async {
    final walletsResponse = await getWallets(context);
    if (walletsResponse?.data?.wallets != null) {
      try {
        return walletsResponse!.data!.wallets!.firstWhere(
          (wallet) => wallet.driverId == driverId
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<List<WalletTransaction>> getWalletTransactions(
    BuildContext context, 
    String walletId
  ) async {
    final allTransactions = await getTransactions(context);
    return allTransactions.where((transaction) => 
      transaction.walletId == walletId
    ).toList();
  }

  Future<List<WalletTransaction>> getSuccessfulTransactions(BuildContext context) async {
    final allTransactions = await getTransactions(context);
    return allTransactions.successfulTransactions;
  }

  Future<void> _handleUnauthorized(BuildContext context) async {
    storage.remove('token');
    storage.remove('user');
    toastService.showError(
      context: context,
      message: "Session expired. Please login again."
    );
    Get.offAllNamed('/');
  }

  void clearCache() {
    walletsResponse = null;
    transactions.clear();
  }

  Map<String, dynamic> getWalletStats() {
    if (walletsResponse?.data?.wallets == null) {
      return {
        'totalWallets': 0,
        'totalBalance': 0.0,
        'activeWallets': 0,
        'totalTransactions': 0,
      };
    }

    final wallets = walletsResponse!.data!.wallets!;
    return {
      'totalWallets': wallets.length,
      'totalBalance': wallets.totalBalance,
      'activeWallets': wallets.activeWallets.length,
      'totalTransactions': transactions.length,
    };
  }
}