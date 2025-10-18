import 'dart:math';

import 'package:boder/constants/utils/enums.dart';
import 'package:boder/models/riders_model.dart';
import 'package:boder/models/users_model.dart';

class Trip {
  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String pickupLocation;
  final String destinationLocation;
  final double price;
  final List<TripRoute> route;
  final bool isRated;
  final bool driverAccepted;
  final bool driverArrive;
  final bool paid;
  final bool paymentConfirmed;
  final bool tripEnded;
  final TripStatus status;
  final Users passenger;
  final Rider rider;
  final bool isActive;
  final bool isRejected;
  final bool isCancelled;
  final bool isCompleted;
  Trip({
    required this.id,
    required this.createdAt,
    this.updatedAt,
    required this.pickupLocation,
    required this.destinationLocation,
    required this.price,
    required this.route,
    required this.isRated,
    required this.driverAccepted,
    required this.driverArrive,
    required this.paid,
    required this.paymentConfirmed,
    required this.tripEnded,
    required this.status,
    required this.passenger,
    required this.rider,
    required this.isActive,
    required this.isRejected,
    required this.isCancelled,
    required this.isCompleted,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'pickup_location': pickupLocation,
      'destination_location': destinationLocation,
      'price': price,
      'route': route.map((r) => r.toMap()).toList(),
      'is_rated': isRated,
      'driver_accepted': driverAccepted,
      'driver_arrive': driverArrive,
      'paid': paid,
      'payment_confirmed': paymentConfirmed,
      'trip_ended': tripEnded,
      'trip_status': status.name,
      'user': passenger.toMap(), 
      'driver': rider.toMap(),
      'is_active': isActive,
      'is_rejected': isRejected,
      'is_cancelled': isCancelled,
      'is_completed': isCompleted,
    };
  }
  factory Trip.fromMap(Map<String, dynamic> map) {
    TripStatus tripStatus = TripStatus.active;
    String statusString = map['trip_status']?.toString() ?? '';
    try {
      switch (statusString.toLowerCase()) {
        case 'pending':
          tripStatus = TripStatus.active;
          break;
        case 'completed':
          tripStatus = TripStatus.completed;
          break;
        case 'cancelled':
        case 'cancelled_by_user':
          tripStatus = TripStatus.cancelled_by_user;
          break;
        default:
          tripStatus = TripStatus.values.firstWhere(
            (e) => e.name == statusString,
            orElse: () => TripStatus.active,
          );
      }
    } catch (e) {
      tripStatus = TripStatus.active;
    }
    final userData = map['user'] is Map ? Map<String, dynamic>.from(map['user'] as Map) : <String, dynamic>{};
    final userMap = {
      'id': userData['user_id']?.toString() ?? userData['userId']?.toString() ?? '',
      'email': userData['email']?.toString() ?? '',
      'userName': userData['firstname']?.toString() ?? userData['userName']?.toString() ?? '',
      'phoneNumber': userData['phone']?.toString() ?? '',
      'emailConfirmed': userData['is_email_verified'] == true,
      'userType': 1,
      'roles': <String>[],
    };
    final driverData = map['driver'] is Map ? Map<String, dynamic>.from(map['driver'] as Map) : <String, dynamic>{};
    final vehicleData = driverData['vehicle'] is Map ? Map<String, dynamic>.from(driverData['vehicle'] as Map) : <String, dynamic>{};
    final locationData = driverData['location'] is Map ? Map<String, dynamic>.from(driverData['location'] as Map) : <String, dynamic>{};
    final verificationData = driverData['verification'] is Map ? Map<String, dynamic>.from(driverData['verification'] as Map) : <String, dynamic>{};
    final driverMap = {
      'id': driverData['rider_id']?.toString() ?? driverData['userId']?.toString() ?? '',
      'email': driverData['email']?.toString() ?? '',
      'fullnames': driverData['fullnames']?.toString() ?? '',
      'phone': driverData['phone']?.toString() ?? '',
      'gender': '',
      'date_of_birth': '',
      'approved': verificationData['is_approved'] == true,
      'vehicle': {
        'number_plate': vehicleData['number_plate']?.toString() ?? '',
        'bike_make': '',
        'bike_model': vehicleData['bike_model']?.toString() ?? '',
        'bike_color': vehicleData['bike_color']?.toString() ?? '',
        'identification_type': '',
        'photos_of_bike': <String>[],
      },
      'verification': {
        'is_approved': verificationData['is_approved'], 
        'document_verified': verificationData['document_verified'],
        'interviewed': verificationData['interviewed'], 
        'is_license_verified': verificationData['is_license_verified']
       },
      'location': {
        'lat': _parseDouble(locationData['lat']),
        'lng': _parseDouble(locationData['lng']),
      },
      'stats': {
        'rating': _parseDouble(driverData['rating']),
        'trips_completed': 0,
        'trips_cancelled': 0,
        'balance': 0.0,
        'complains_filed': <String>[],
      },
      'is_available': driverData['is_available'] == true,
      'is_verified': driverData['is_verified'] == true,
      'device_token': driverData['device_token']?.toString(),
      'identity_id': driverData['identity_id']?.toString() ?? '',
    };
    List<TripRoute> routeList = <TripRoute>[];
    try {
      final routeData = map['route'];
      if (routeData is List) {
        for (int i = 0; i < routeData.length; i++) {
          final routeItem = routeData[i];
          if (routeItem is Map) {
            try {
              final routeMap = Map<String, dynamic>.from(routeItem);
              routeList.add(TripRoute.fromMap(routeMap));
            } catch (e) {
            }
          }
        }
      }
    } catch (e) {
      routeList = <TripRoute>[];
    }
    try {
      return Trip(
        id: map['id']?.toString() ?? '',
        createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ?? DateTime.now(),
        updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at']?.toString() ?? '') : null,
        pickupLocation: map['pickup_location']?.toString() ?? '',
        destinationLocation: map['destination_location']?.toString() ?? '',
        price: _parseDouble(map['price']),
        route: routeList,
        isRated: map['is_rated'] == true,
        driverAccepted: map['driver_accepted'] == true,
        driverArrive: map['driver_arrive'] == true,
        paid: map['paid'] == true,
        paymentConfirmed: map['payment_confirmed'] == true,
        tripEnded: map['trip_ended'] == true,
        status: tripStatus,
        passenger: Users.fromMap(userMap),
        rider: Rider.fromMap(driverMap), 
        isActive: map['is_active'] == true,
        isRejected: map['is_rejected'] == true,
        isCancelled: map['is_cancelled'] == true,
        isCompleted: map['is_completed'] == true,
      );
    } catch (e) {
      rethrow;
    }
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  String get formattedCreatedAt => '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  String get formattedUpdatedAt => updatedAt != null ? '${updatedAt!.day}/${updatedAt!.month}/${updatedAt!.year}' : 'Not updated';

  String get shortRoute {
    final pickup = pickupLocation.split(',');
    final destination = destinationLocation.split(',');
    if (pickup.length >= 2 && destination.length >= 2) {
      final pickupShort = pickup[0].substring(0, min(6, pickup[0].length));
      final destinationShort = destination[0].substring(0, min(6, destination[0].length));
      return '$pickupShort... → $destinationShort...';
    }
    return 'Route not available';
  }

  String get statusText {
    if (isCompleted) return 'Completed';
    if (isCancelled) return 'Cancelled';
    if (isRejected) return 'Rejected';
    if (isActive) return 'Active';
    switch (status) {
      case TripStatus.completed:
        return 'Completed';
      case TripStatus.active:
        return 'Active';
      case TripStatus.cancelled_by_user:
        return 'Cancelled';
      case TripStatus.all:
        return 'All';
      default:
        return 'Unknown';
    }
  }

  bool get isPending => isActive && !driverAccepted && !isRejected && !isCancelled && !isCompleted;
  bool get isInProgress => driverAccepted && !isCompleted && !isCancelled;
  bool get hasEnded => isCompleted || isCancelled;
}

class TripRoute {
  final double lat;
  final double lng;
  TripRoute({required this.lat, required this.lng});

  Map<String, dynamic> toMap() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }

  factory TripRoute.fromMap(Map<String, dynamic> map) {
    try {
      return TripRoute(
        lat: _parseDouble(map['lat']),
        lng: _parseDouble(map['lng']),
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
}

extension TripListExtension on List<Trip> {
  List<Map<String, dynamic>> toMapList() {
    return map((trip) => trip.toMap()).toList();
  }
}