import 'dart:convert';
import 'package:boder/models/riders_model.dart';
import 'package:boder/models/users_model.dart';

Wallets walletsFromJson(String str) => Wallets.fromJson(json.decode(str));
String walletsToJson(Wallets data) => json.encode(data.toJson());

class Wallets {
    bool? success;
    String? message;
    Data? data;
    
    Wallets({
      this.success,
      this.message,
      this.data,
    });
    factory Wallets.fromJson(Map<String, dynamic> json) => Wallets(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );
    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
    };
}

class Data {
    List<Wallet>? wallets;
    int? totalCount;
    int? page;
    int? pageSize;
    int? totalPages;
    Filters? filters;
    Data({
        this.wallets,
        this.totalCount,
        this.page,
        this.pageSize,
        this.totalPages,
        this.filters,
    });
    factory Data.fromJson(Map<String, dynamic> json) => Data(
      wallets: json["wallets"] == null ? [] : List<Wallet>.from(json["wallets"]!.map((x) => Wallet.fromJson(x))),
      totalCount: json["totalCount"],
      page: json["page"],
      pageSize: json["pageSize"],
      totalPages: json["totalPages"],
      filters: json["filters"] == null ? null : Filters.fromJson(json["filters"]),
    );
    factory Data.fromJsonWithData(
      Map<String, dynamic> json, 
      Map<String, Rider> ridersMap, 
      Map<String, Users> usersMap
    ) => Data(
      wallets: json["wallets"] == null ? [] : List<Wallet>.from(
        json["wallets"]!.map((x) => Wallet.fromJsonWithData(x, ridersMap, usersMap))
      ),
      totalCount: json["totalCount"],
      page: json["page"],
      pageSize: json["pageSize"],
      totalPages: json["totalPages"],
      filters: json["filters"] == null ? null : Filters.fromJson(json["filters"]),
    );
    Map<String, dynamic> toJson() => {
        "wallets": wallets == null ? [] : List<dynamic>.from(wallets!.map((x) => x.toJson())),
        "totalCount": totalCount,
        "page": page,
        "pageSize": pageSize,
        "totalPages": totalPages,
        "filters": filters?.toJson(),
    };
}

class Filters {
  dynamic minBalance;
  dynamic maxBalance;
  dynamic createdAfter;
  dynamic createdBefore;
  dynamic searchTerm;
  Filters({
      this.minBalance,
      this.maxBalance,
      this.createdAfter,
      this.createdBefore,
      this.searchTerm,
  });
  
  factory Filters.fromJson(Map<String, dynamic> json) => Filters(
      minBalance: json["minBalance"],
      maxBalance: json["maxBalance"],
      createdAfter: json["createdAfter"],
      createdBefore: json["createdBefore"],
      searchTerm: json["searchTerm"],
  );
  
  Map<String, dynamic> toJson() => {
    "minBalance": minBalance,
    "maxBalance": maxBalance,
    "createdAfter": createdAfter,
    "createdBefore": createdBefore,
    "searchTerm": searchTerm,
  };
}

class Wallet {
    String? id;
    String? driverId;
    String? lastTransactionId;
    double? balance;
    DateTime? createdAt;
    DateTime? updatedAt;
    List<WalletTransaction>? transactions;
    int? transactionCount;
    double? totalTransactionAmount;
    int? successfulTransactions;
    Rider? driver;
    String? userId;
    Map<String, Users>? associatedUsers;
    Wallet({
        this.id,
        this.driverId,
        this.lastTransactionId,
        this.balance,
        this.createdAt,
        this.updatedAt,
        this.transactions,
        this.transactionCount,
        this.totalTransactionAmount,
        this.successfulTransactions,
        this.driver,
        this.userId,
        this.associatedUsers,
    });
    factory Wallet.fromJson(Map<String, dynamic> json) {
      try {
        return Wallet(
            id: json["id"]?.toString(),
            driverId: json["driver_id"]?.toString(),
            lastTransactionId: json["last_transaction_id"]?.toString(),
            balance: _parseDouble(json["balance"]),
            createdAt: json["created_at"] != null ? DateTime.tryParse(json["created_at"].toString()) : null,
            updatedAt: json["updated_at"] != null ? DateTime.tryParse(json["updated_at"].toString()) : null,
            transactions: json["transactions"] != null 
                ? List<WalletTransaction>.from(json["transactions"].map((x) => WalletTransaction.fromJson(x)))
                : [],
            transactionCount: _parseInt(json["transaction_count"]),
            totalTransactionAmount: _parseDouble(json["total_transaction_amount"]),
            successfulTransactions: _parseInt(json["successful_transactions"]),
            driver: json["driver"] != null ? Rider.fromMap(json["driver"]) : null,
            userId: json["user_id"]?.toString(),
            associatedUsers: json["associated_users"] != null 
                ? Map<String, Users>.from(
                    json["associated_users"].map((key, value) => MapEntry(key, Users.fromMap(value)))
                  )
                : null,
        );
    } catch (e) {
        rethrow;
    }
    }
    factory Wallet.fromJsonWithData(
      Map<String, dynamic> json, 
      Map<String, Rider> ridersMap, 
      Map<String, Users> usersMap
    ) {
      try {
        final driverId = json["driver_id"]?.toString();
        final rider = driverId != null ? ridersMap[driverId] : null;
        List<WalletTransaction>? enrichedTransactions;
        if (json["transactions"] != null) {
          enrichedTransactions = List<WalletTransaction>.from(
            json["transactions"].map((x) => WalletTransaction.fromJsonWithData(x, rider, usersMap))
          );
        }
        final associatedUsers = <String, Users>{};
        if (enrichedTransactions != null) {
          for (final transaction in enrichedTransactions) {
            if (transaction.userId != null && transaction.user != null) {
              associatedUsers[transaction.userId!] = transaction.user!;
            }
          }
        }
        return Wallet(
            id: json["id"]?.toString(),
            driverId: driverId,
            lastTransactionId: json["last_transaction_id"]?.toString(),
            balance: _parseDouble(json["balance"]),
            createdAt: json["created_at"] != null ? DateTime.tryParse(json["created_at"].toString()) : null,
            updatedAt: json["updated_at"] != null ? DateTime.tryParse(json["updated_at"].toString()) : null,
            transactions: enrichedTransactions ?? [],
            transactionCount: _parseInt(json["transaction_count"]),
            totalTransactionAmount: _parseDouble(json["total_transaction_amount"]),
            successfulTransactions: _parseInt(json["successful_transactions"]),
            driver: rider,
            userId: json["user_id"]?.toString(),
            associatedUsers: associatedUsers.isNotEmpty ? associatedUsers : null,
        );
    } catch (e) {
        rethrow;
    }
    }

    static double _parseDouble(dynamic value) {
        if (value == null) return 0.0;
        if (value is double) return value;
        if (value is int) return value.toDouble();
        if (value is String) {
            final parsed = double.tryParse(value);
            if (parsed != null) return parsed;
            return 0.0;
        }
        return 0.0;
    }
   
    static int _parseInt(dynamic value) {
        if (value == null) return 0;
        if (value is int) return value;
        if (value is double) return value.round();
        if (value is String) {
            final parsed = int.tryParse(value);
            if (parsed != null) return parsed;
            return 0;
        }
        return 0;
    }

    Map<String, dynamic> toJson() => {
        "id": id,
        "driver_id": driverId,
        "user_id": userId,
        "last_transaction_id": lastTransactionId,
        "balance": balance,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "transactions": transactions?.map((x) => x.toJson()).toList() ?? [],
        "transaction_count": transactionCount,
        "total_transaction_amount": totalTransactionAmount,
        "successful_transactions": successfulTransactions,
        "driver": driver?.toMap(),
        "associated_users": associatedUsers?.map((key, user) => MapEntry(key, user.toMap())),
    };
    String get formattedBalance => 'KES ${balance?.toStringAsFixed(2) ?? '0.00'}';
    String get formattedCreatedAt => createdAt != null  ? '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}' : 'N/A';
    String get ownerName => driver?.fullnames ?? 'Unknown';
    bool get hasRecentActivity => updatedAt != null && DateTime.now().difference(updatedAt!).inDays < 7;
    String get driverName => driver?.fullnames ?? 'Unknown Driver';
    String get driverEmail => driver?.email ?? '';
    String get driverPhone => driver?.phone ?? '';
    String? get driverImage => driver?.image;
    bool get hasDriver => driver != null;
    List<Users> get transactionUsers => associatedUsers?.values.toList() ?? [];
    int get uniqueCustomersCount => associatedUsers?.length ?? 0;
    Users? getUserById(String userId) => associatedUsers?[userId];
    List<WalletTransaction> get successfulTransactionsList => transactions?.where((t) => t.isSuccessful).toList() ?? [];
    List<WalletTransaction> get failedTransactions =>transactions?.where((t) => !t.isSuccessful).toList() ?? [];
    double get successRate {
      if (transactionCount == null || transactionCount == 0) return 0.0;
      final successful = successfulTransactions ?? 0;
      return (successful / transactionCount!) * 100;
    }
    List<WalletTransaction> getTransactionsByUser(String userId) {
      return transactions?.where((t) => t.userId == userId).toList() ?? [];
    }
    Users? get mostFrequentCustomer {
      if (transactions == null || transactions!.isEmpty) return null;
      final userTransactionCounts = <String, int>{};
      for (final transaction in transactions!) {
        if (transaction.userId != null) {
          userTransactionCounts[transaction.userId!] = 
              (userTransactionCounts[transaction.userId!] ?? 0) + 1;
        }
      }
      if (userTransactionCounts.isEmpty) return null;
      final mostFrequentUserId = userTransactionCounts.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
      return getUserById(mostFrequentUserId);
    }
    
    Wallet copyWith({
      String? id,
      String? driverId,
      String? lastTransactionId,
      double? balance,
      DateTime? createdAt,
      DateTime? updatedAt,
      List<WalletTransaction>? transactions,
      int? transactionCount,
      double? totalTransactionAmount,
      int? successfulTransactions,
      Rider? driver,
      String? userId,
      Map<String, Users>? associatedUsers,
    }) {
      return Wallet(
        id: id ?? this.id,
        driverId: driverId ?? this.driverId,
        lastTransactionId: lastTransactionId ?? this.lastTransactionId,
        balance: balance ?? this.balance,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        transactions: transactions ?? this.transactions,
        transactionCount: transactionCount ?? this.transactionCount,
        totalTransactionAmount: totalTransactionAmount ?? this.totalTransactionAmount,
        successfulTransactions: successfulTransactions ?? this.successfulTransactions,
        driver: driver ?? this.driver,
        userId: userId ?? this.userId,
        associatedUsers: associatedUsers ?? this.associatedUsers,
      );
    }
}

class WalletTransaction {
    String? id;
    String? receipt;
    double? amount;
    String? phone;
    String? tripId;
    String? driverId;
    String? userId;
    DateTime? date;
    String? checkoutRequestId;
    String? merchantRequestId;
    String? resultDesc;
    WalletTrip? trip;
    String? walletId;
    Wallet? wallet;
    Rider? driver;
    Users? user;
    
    WalletTransaction({
        this.id,
        this.receipt,
        this.amount,
        this.phone,
        this.tripId,
        this.driverId,
        this.userId,
        this.date,
        this.checkoutRequestId,
        this.merchantRequestId,
        this.resultDesc,
        this.trip,
        this.walletId,
        this.wallet,
        this.driver,
        this.user,
    });
    
    factory WalletTransaction.fromJson(Map<String, dynamic> json) {
        try {
          return WalletTransaction(
              id: json["id"]?.toString(),
              receipt: json["receipt"]?.toString(),
              amount: _parseDouble(json["amount"]),
              phone: json["phone"]?.toString(),
              tripId: json["trip_id"]?.toString(),
              driverId: json["driver_id"]?.toString(),
              userId: json["user_id"]?.toString(),
              date: json["date"] != null ? DateTime.tryParse(json["date"].toString()) : null,
              checkoutRequestId: json["checkout_requestID"]?.toString(),
              merchantRequestId: json["merchant_requestId"]?.toString(),
              resultDesc: json["result_desc"]?.toString(),
              trip: json["trip"] != null ? WalletTrip.fromJson(json["trip"]) : null,
              walletId: json["wallet_id"]?.toString(),
              driver: json["driver"] != null ? Rider.fromMap(json["driver"]) : null,
              user: json["user"] != null ? Users.fromMap(json["user"]) : null,
          );
      } catch (e) {
          rethrow;
      }
    }

    // NEW: Enhanced factory constructor with data enrichment
    factory WalletTransaction.fromJsonWithData(
      Map<String, dynamic> json,
      Rider? driver,
      Map<String, Users> usersMap,
    ) {
        try {
          final userId = json["user_id"]?.toString();
          final user = userId != null ? usersMap[userId] : null;
          
          return WalletTransaction(
              id: json["id"]?.toString(),
              receipt: json["receipt"]?.toString(),
              amount: _parseDouble(json["amount"]),
              phone: json["phone"]?.toString(),
              tripId: json["trip_id"]?.toString(),
              driverId: json["driver_id"]?.toString(),
              userId: userId,
              date: json["date"] != null ? DateTime.tryParse(json["date"].toString()) : null,
              checkoutRequestId: json["checkout_requestID"]?.toString(),
              merchantRequestId: json["merchant_requestId"]?.toString(),
              resultDesc: json["result_desc"]?.toString(),
              trip: json["trip"] != null ? WalletTrip.fromJson(json["trip"]) : null,
              walletId: json["wallet_id"]?.toString(),
              driver: driver ?? (json["driver"] != null ? Rider.fromMap(json["driver"]) : null),
              user: user ?? (json["user"] != null ? Users.fromMap(json["user"]) : null),
          );
      } catch (e) {
          rethrow;
      }
    }

    static double _parseDouble(dynamic value) {
        if (value == null) return 0.0;
        if (value is double) return value;
        if (value is int) return value.toDouble();
        if (value is String) {
            final parsed = double.tryParse(value);
            if (parsed != null) return parsed;
            return 0.0;
        }
        return 0.0;
    }

    Map<String, dynamic> toJson() => {
        "id": id,
        "receipt": receipt,
        "amount": amount,
        "phone": phone,
        "trip_id": tripId,
        "driver_id": driverId,
        "user_id": userId,
        "date": date?.toIso8601String(),
        "checkout_requestID": checkoutRequestId,
        "merchant_requestId": merchantRequestId,
        "result_desc": resultDesc,
        "trip": trip?.toJson(),
        "wallet_id": walletId,
        "driver": driver?.toMap(),
        "user": user?.toMap(),
    };
    
    // Existing getters
    String get formattedAmount => 'KES ${amount?.toStringAsFixed(2) ?? '0.00'}';
    String get formattedDate => date != null ? '${date!.day}/${date!.month}/${date!.year}' : 'N/A';
    
    String get transactionType {
      if (resultDesc?.toLowerCase().contains('success') == true) {
          return 'Success';
      } else if (resultDesc?.toLowerCase().contains('failed') == true || 
                  resultDesc?.toLowerCase().contains('timeout') == true) {
          return 'Failed';
      } else {
          return 'Pending';
      }
    }

    bool get isSuccessful => resultDesc?.toLowerCase().contains('success') == true;
   
    String get participantName {
        if (user != null) return user!.userName;
        if (driver != null) return driver!.fullnames;
        return phone ?? 'Unknown';
    }
    
    // NEW: Enhanced participant information
    String get participantEmail {
      if (user != null) return user!.email;
      if (driver != null) return driver!.email;
      return '';
    }
    
    String? get participantImage {
      if (user != null) return user!.image;
      if (driver != null) return driver!.image;
      return null;
    }
    
    String get participantType {
      if (user != null) return 'Customer';
      if (driver != null) return 'Driver';
      return 'Unknown';
    }
    
    String get participantPhone {
      if (user != null) return user!.phone;
      if (driver != null) return driver!.phone;
      return phone ?? '';
    }
    
    // NEW: Enhanced status information
    bool get isFailed => resultDesc?.toLowerCase().contains('failed') == true || 
                        resultDesc?.toLowerCase().contains('timeout') == true;
    bool get isPending => !isSuccessful && !isFailed;
    
    String get statusColor {
      if (isSuccessful) return 'success';
      if (isFailed) return 'error';
      return 'warning';
    }
}

class WalletTrip {
    String? id;
    String? from;
    String? to;
    double? amount;
    String? status;
    
    WalletTrip({
        this.id,
        this.from,
        this.to,
        this.amount,
        this.status,
    });
    
    factory WalletTrip.fromJson(Map<String, dynamic> json) {
      return WalletTrip(
          id: json["id"]?.toString(),
          from: json["from"]?.toString(),
          to: json["to"]?.toString(),
          amount: json["amount"] != null ? _parseDouble(json["amount"]) : null,
          status: json["status"]?.toString(),
      );
    }
    
    static double _parseDouble(dynamic value) {
        if (value == null) return 0.0;
        if (value is double) return value;
        if (value is int) return value.toDouble();
        if (value is String) {
            final parsed = double.tryParse(value);
            if (parsed != null) return parsed;
            return 0.0;
        }
        return 0.0;
    }
    
    Map<String, dynamic> toJson() => {
        "id": id,
        "from": from,
        "to": to,
        "amount": amount,
        "status": status,
    };

    String get shortRoute {
      if (from != null && to != null) {
        try {
            final fromCoords = from!.split(',');
            final toCoords = to!.split(',');
            if (fromCoords.length == 2 && toCoords.length == 2) {
                final fromLat = double.parse(fromCoords[0]).toStringAsFixed(3);
                final fromLng = double.parse(fromCoords[1]).toStringAsFixed(3);
                final toLat = double.parse(toCoords[0]).toStringAsFixed(3);
                final toLng = double.parse(toCoords[1]).toStringAsFixed(3);
                return '$fromLat,$fromLng → $toLat,$toLng';
            }
        } catch (e) {
            final fromShort = from!.length > 15 ? '${from!.substring(0, 15)}...' : from!;
            final toShort = to!.length > 15 ? '${to!.substring(0, 15)}...' : to!;
            return '$fromShort → $toShort';
        }
    }
      return 'Route not available';
  }
    
    String get formattedAmount => amount != null ? 'KES ${amount!.toStringAsFixed(2)}' : 'KES 0.00';
}

// Enhanced extensions
extension WalletListExtension on List<Wallet> {
    List<Map<String, dynamic>> toMapList() {
        return map((wallet) => wallet.toJson()).toList();
    }
    
    double get totalBalance {
        return fold(0.0, (sum, wallet) => sum + (wallet.balance ?? 0.0));
    }

    List<Wallet> get activeWallets {
        return where((wallet) => (wallet.balance ?? 0.0) > 0).toList();
    }

    List<Wallet> filterByDriver(String driverId) {
        return where((wallet) => wallet.driverId == driverId).toList();
    }
    
    // NEW: Enhanced filtering and analysis
    List<Wallet> filterByBalance({double? min, double? max}) {
        return where((wallet) {
          final balance = wallet.balance ?? 0.0;
          final minCheck = min == null || balance >= min;
          final maxCheck = max == null || balance <= max;
          return minCheck && maxCheck;
        }).toList();
    }
    
    List<Wallet> get walletsWithRecentActivity {
        return where((wallet) => wallet.hasRecentActivity).toList();
    }
    
    Map<String, int> get driverWalletCount {
        final counts = <String, int>{};
        for (final wallet in this) {
          if (wallet.driverId != null) {
            counts[wallet.driverId!] = (counts[wallet.driverId!] ?? 0) + 1;
          }
        }
        return counts;
    }
    
    double get averageBalance {
        if (isEmpty) return 0.0;
        return totalBalance / length;
    }
}

extension WalletTransactionListExtension on List<WalletTransaction> {
    List<Map<String, dynamic>> toMapList() {
        return map((transaction) => transaction.toJson()).toList();
    }
    
    List<WalletTransaction> get successfulTransactions {
        return where((transaction) => transaction.isSuccessful).toList();
    }
    
    double get totalAmount {
        return fold(0.0, (sum, transaction) => sum + (transaction.amount ?? 0.0));
    }
    
    List<WalletTransaction> filterByDateRange(DateTime start, DateTime end) {
        return where((transaction) => 
            transaction.date != null &&
            transaction.date!.isAfter(start) &&
            transaction.date!.isBefore(end)
        ).toList();
    }
    
    List<WalletTransaction> filterByDriver(String driverId) {
        return where((transaction) => transaction.driverId == driverId).toList();
    }
    
    List<WalletTransaction> filterByUser(String userId) {
        return where((transaction) => transaction.userId == userId).toList();
    }
    
    // NEW: Enhanced filtering and analysis
    List<WalletTransaction> get failedTransactions {
        return where((transaction) => transaction.isFailed).toList();
    }
    
    List<WalletTransaction> get pendingTransactions {
        return where((transaction) => transaction.isPending).toList();
    }
    
    Map<String, List<WalletTransaction>> groupByUser() {
        final groups = <String, List<WalletTransaction>>{};
        for (final transaction in this) {
          if (transaction.userId != null) {
            groups.putIfAbsent(transaction.userId!, () => []);
            groups[transaction.userId!]!.add(transaction);
          }
        }
        return groups;
    }
    
    Map<String, List<WalletTransaction>> groupByDriver() {
        final groups = <String, List<WalletTransaction>>{};
        for (final transaction in this) {
          if (transaction.driverId != null) {
            groups.putIfAbsent(transaction.driverId!, () => []);
            groups[transaction.driverId!]!.add(transaction);
          }
        }
        return groups;
    }
    
    double get successRate {
        if (isEmpty) return 0.0;
        return (successfulTransactions.length / length) * 100;
    }
    
    List<WalletTransaction> filterByAmountRange({double? min, double? max}) {
        return where((transaction) {
          final amount = transaction.amount ?? 0.0;
          final minCheck = min == null || amount >= min;
          final maxCheck = max == null || amount <= max;
          return minCheck && maxCheck;
        }).toList();
    }
}