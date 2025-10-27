class Rider {
  final String id;
  final String userId;
  final String email;
  final String fullnames;
  final String phone;
  final double balance;
  final double rating;
  final int complitedTrips;
  final int canciel;
  final String gender;
  final String dateOfBirth;
  final String? image;
  final String numberPlate;
  final String bikeMake;
  final String bikeModel;
  final String bikeColor;
  final String? vehicleCategory;
  final List<String> photosOfBike;
  final String idNumber;
  final String identificationType;
  final String city;
  final String? idPhoto;
  final String? driversLicensePhoto;
  final bool previousDriverExperience;
  final bool consentBackgroundChecks;
  final String? referalCode;
  final String? username;
  final String status;
  final bool isAvailable;
  final String? deviceInfo;
  final String? lastLogoutTime;
  final Location location;
  final List<Complaint> complainsFiled;
  final Verification verification;
  final DateTime joinedDate;

  Rider({
    required this.id,
    required this.userId,
    required this.email,
    required this.fullnames,
    required this.phone,
    required this.balance,
    required this.complitedTrips,
    required this.canciel,
    required this.rating,
    required this.vehicleCategory,
    required this.gender,
    required this.dateOfBirth,
    this.image,
    required this.numberPlate,
    required this.bikeMake,
    required this.bikeModel,
    required this.bikeColor,
    required this.photosOfBike,
    required this.idNumber,
    required this.identificationType,
    required this.city,
    this.idPhoto,
    this.driversLicensePhoto,
    required this.previousDriverExperience,
    required this.consentBackgroundChecks,
    this.referalCode,
    this.username,
    required this.status,
    required this.isAvailable,
    this.deviceInfo,
    this.lastLogoutTime,
    required this.location,
    required this.complainsFiled,
    required this.verification,
    required this.joinedDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'email': email,
      'fullnames': fullnames,
      'phone': phone,
      'gender': gender,
      'date_of_birth': dateOfBirth,
      'image': image,
      'id_number': idNumber,
      'city': city,
      'id_photo': idPhoto,
      'drivers_license_photo': driversLicensePhoto,
      'previous_driver_experience': previousDriverExperience,
      'consent_background_checks': consentBackgroundChecks,
      'referal_code': referalCode,
      'username': username,
      'status': status,
      'is_available': isAvailable,
      'device_info': deviceInfo,
      'last_logout_time': lastLogoutTime,
      'location': location.toMap(),
      'vehicle': {
        'bike_make': bikeMake,
        'bike_model': bikeModel,
        'bike_color': bikeColor,
        'number_plate': numberPlate,
        'identification_type': identificationType,
        'photos_of_bike': photosOfBike,
        'vehicleCategory': vehicleCategory
      },
      'verification': verification.toMap(),
      'stats': {
        'complains_filed': complainsFiled.map((c) => c.toMap()).toList(),
        "rating": rating,
        "trips_completed": complitedTrips,
        "trips_cancelled": canciel,
        "balance": balance,
      },
    };
  }

  factory Rider.fromMap(Map<String, dynamic> map) {
    final vehicle = map['vehicle'] ?? {};
    final locationData = map['location'] ?? {};
    final stats = map['stats'] ?? {};
    final verificationData = map['verification'] ?? {};
    final complainsData = stats['complains_filed'] as List? ?? [];

    bool parseBool(dynamic value, [bool defaultValue = false]) {
      if (value is bool) return value;
      if (value is String) {
        final lowerValue = value.toLowerCase().trim();
        return lowerValue == 'true' || lowerValue == '1' || lowerValue == 'yes';
      }
      if (value is int) return value == 1;
      return defaultValue;
    }

    String parseString(dynamic value, [String defaultValue = '']) {
      if (value == null) return defaultValue;
      return value.toString().trim();
    }

    List<String> parseStringList(dynamic value) {
      if (value is List) {
        return value.map((item) => item?.toString() ?? '').toList();
      }
      return <String>[];
    }

    double parseDouble(dynamic value, [double defaultValue = 0.0]) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? defaultValue;
      }
      return defaultValue;
    }

    int parseInt(dynamic value, [int defaultValue = 0]) {
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) {
        return int.tryParse(value) ?? defaultValue;
      }
      return defaultValue;
    }

    DateTime parsedJoinedDate;
    try {
      final dobString = parseString(map['date_of_birth']);
      if (dobString.isEmpty) {
        parsedJoinedDate = DateTime.now();
      } else if (dobString.contains('/')) {
        final parts = dobString.split('/');
        if (parts.length == 3) {
          parsedJoinedDate = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        } else {
          parsedJoinedDate = DateTime.now();
        }
      } else if (dobString.contains('-')) {
        // Handle the new format like "2003-02-28 00:00:00.000"
        final cleanedString = dobString.split(' ')[0]; // Get just the date part
        parsedJoinedDate = DateTime.tryParse(cleanedString) ?? DateTime.now();
      } else {
        parsedJoinedDate = DateTime.now();
      }
    } catch (e) {
      parsedJoinedDate = DateTime.now();
    }

    final rider = Rider(
      id: parseString(map['id']),
      userId: parseString(map['userId']),
      email: parseString(map['email']),
      fullnames: parseString(map['fullnames']),
      phone: parseString(map['phone']),
      gender: parseString(map['gender']),
      dateOfBirth: parseString(map['date_of_birth']),
      image: map['image']?.toString(),
      numberPlate: parseString(vehicle['number_plate']),
      bikeMake: parseString(vehicle['bike_make']),
      bikeModel: parseString(vehicle['bike_model']),
      bikeColor: parseString(vehicle['bike_color']),
      photosOfBike: parseStringList(vehicle['photos_of_bike']),
      identificationType: parseString(vehicle['identification_type']),
      idNumber: parseString(map['id_number']),
      city: parseString(map['city']),
      idPhoto: map['id_photo']?.toString(),
      driversLicensePhoto: map['drivers_license_photo']?.toString(),
      previousDriverExperience: parseBool(map['previous_driver_experience']),
      consentBackgroundChecks: parseBool(map['consent_background_checks']),
      referalCode: map['referal_code']?.toString(),
      username: map['username']?.toString(),
      status: parseString(map['status']),
      isAvailable: parseBool(map['is_available']),
      deviceInfo: map['device_info']?.toString(),
      lastLogoutTime: map['last_logout_time']?.toString(),
      location: Location.fromMap(locationData),
      complainsFiled: complainsData.map((c) => Complaint.fromMap(c is Map<String, dynamic> ? c : {})).toList(),
      verification: Verification.fromMap(verificationData),
      joinedDate: parsedJoinedDate,
      balance: parseDouble(stats['balance'] ?? map['balance']),
      rating: parseDouble(stats['rating'] ?? map['rating']),
      complitedTrips: parseInt(stats['trips_completed']),
      canciel: parseInt(stats['trips_cancelled']), 
      vehicleCategory: parseString(vehicle['vehicleCategory']),
    );

    return rider;
  }

  Rider copyWith({
    String? id,
    String? userId,
    String? email,
    String? fullnames,
    String? phone,
    String? gender,
    String? dateOfBirth,
    String? image,
    String? numberPlate,
    String? bikeMake,
    String? vehicleCategory,
    String? bikeModel,
    String? bikeColor,
    double? balance,
    double? rating,
    int? complitedTrips,
    int? canciel,
    List<String>? photosOfBike,
    String? idNumber,
    String? identificationType,
    String? city,
    String? idPhoto,
    String? driversLicensePhoto,
    bool? previousDriverExperience,
    bool? consentBackgroundChecks,
    String? referalCode,
    String? username,
    String? status,
    bool? isAvailable,
    String? deviceInfo,
    String? lastLogoutTime,
    Location? location,
    List<Complaint>? complainsFiled,
    Verification? verification,
    DateTime? joinedDate,
  }) {
    return Rider(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      fullnames: fullnames ?? this.fullnames,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      image: image ?? this.image,
      balance: balance ?? this.balance,
      rating: rating ?? this.rating,
      complitedTrips: complitedTrips ?? this.complitedTrips,
      canciel: canciel ?? this.canciel,
      numberPlate: numberPlate ?? this.numberPlate,
      bikeMake: bikeMake ?? this.bikeMake,
      bikeModel: bikeModel ?? this.bikeModel,
      bikeColor: bikeColor ?? this.bikeColor,
      photosOfBike: photosOfBike ?? this.photosOfBike,
      idNumber: idNumber ?? this.idNumber,
      vehicleCategory:vehicleCategory ?? this.vehicleCategory,
      identificationType: identificationType ?? this.identificationType,
      city: city ?? this.city,
      idPhoto: idPhoto ?? this.idPhoto,
      driversLicensePhoto: driversLicensePhoto ?? this.driversLicensePhoto,
      previousDriverExperience: previousDriverExperience ?? this.previousDriverExperience,
      consentBackgroundChecks: consentBackgroundChecks ?? this.consentBackgroundChecks,
      referalCode: referalCode ?? this.referalCode,
      username: username ?? this.username,
      status: status ?? this.status,
      isAvailable: isAvailable ?? this.isAvailable,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      lastLogoutTime: lastLogoutTime ?? this.lastLogoutTime,
      location: location ?? this.location,
      complainsFiled: complainsFiled ?? this.complainsFiled,
      verification: verification ?? this.verification,
      joinedDate: joinedDate ?? this.joinedDate,
    );
  }

  String get formattedJoinedDate => '${joinedDate.day}/${joinedDate.month}/${joinedDate.year}';
  String get locationString => '${location.lat}, ${location.lng}';
  String get statusText => verification.isApproved ? 'Approved' : 'Pending Approval';
  bool get approved => verification.isApproved;
}

class Location {
  final double lat;
  final double lng;
  
  Location({required this.lat, required this.lng});
  
  Map<String, dynamic> toMap() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      lat: (map['lat'] ?? 0.0).toDouble(),
      lng: (map['lng'] ?? 0.0).toDouble(),
    );
  }
}

class Verification {
  final bool isApproved;
  final bool documentVerified;
  final bool interviewed;
  final bool isLicenseVerified;

  Verification({
    required this.isApproved,
    required this.documentVerified,
    required this.interviewed,
    required this.isLicenseVerified,
  });

  Map<String, dynamic> toMap() {
    return {
      'is_approved': isApproved,
      'document_verified': documentVerified,
      'interviewed': interviewed,
      'is_license_verified': isLicenseVerified,
    };
  }

  factory Verification.fromMap(Map<String, dynamic> map) {
    bool parseBool(dynamic value, [bool defaultValue = false]) {
      if (value is bool) return value;
      if (value is String) {
        final lowerValue = value.toLowerCase().trim();
        return lowerValue == 'true' || lowerValue == '1' || lowerValue == 'yes';
      }
      if (value is int) return value == 1;
      return defaultValue;
    }

    return Verification(
      isApproved: parseBool(map['is_approved']),
      documentVerified: parseBool(map['document_verified']),
      interviewed: parseBool(map['interviewed']),
      isLicenseVerified: parseBool(map['is_license_verified']),
    );
  }

  Verification copyWith({
    bool? isApproved,
    bool? documentVerified,
    bool? interviewed,
    bool? isLicenseVerified,
  }) {
    return Verification(
      isApproved: isApproved ?? this.isApproved,
      documentVerified: documentVerified ?? this.documentVerified,
      interviewed: interviewed ?? this.interviewed,
      isLicenseVerified: isLicenseVerified ?? this.isLicenseVerified,
    );
  }
}

class Complaint {
  final String id;
  final String complaintText;
  final DateTime createdAt;
  final String status;
  final String? resolution;
  
  Complaint({
    required this.id,
    required this.complaintText,
    required this.createdAt,
    required this.status,
    this.resolution,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'complaintText': complaintText,
      'createdAt': createdAt,
      'status': status,
      'resolution': resolution,
    };
  }
  
  factory Complaint.fromMap(Map<String, dynamic> map) {
    return Complaint(
      id: map['id'] ?? '',
      complaintText: map['complaintText'] ?? '',
      createdAt: map['createdAt'] ?? DateTime.now(),
      status: map['status'] ?? '',
      resolution: map['resolution'],
    );
  }
}

extension RiderListExtension on List<Rider> {
  List<Map<String, dynamic>> toMapList() {
    return map((rider) => rider.toMap()).toList();
  }
}