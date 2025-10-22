import 'package:boder/constants/utils/enums.dart';
import 'package:flutter/material.dart';

class NotificationModel {
  final String? id;
  final String title;
  final String message;
  final DateTime? sentAt;
  final String? sentBy;
  final int? recipientCount;
  final NotificationType type;
  final NotificationStatus status;

  NotificationModel({
    this.id,
    required this.title,
    required this.message,
    this.sentAt,
    this.sentBy,
    this.recipientCount,
    this.type = NotificationType.general,
    this.status = NotificationStatus.pending,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'sentAt': sentAt?.toIso8601String(),
      'sentBy': sentBy,
      'recipientCount': recipientCount,
      'type': type.toString(),
      'status': status.toString(),
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'],
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      sentAt: map['sentAt'] != null ? DateTime.tryParse(map['sentAt']) : null,
      sentBy: map['sentBy'],
      recipientCount: map['recipientCount'],
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => NotificationType.general,
      ),
      status: NotificationStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => NotificationStatus.pending,
      ),
    );
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? sentAt,
    String? sentBy,
    int? recipientCount,
    NotificationType? type,
    NotificationStatus? status,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      sentAt: sentAt ?? this.sentAt,
      sentBy: sentBy ?? this.sentBy,
      recipientCount: recipientCount ?? this.recipientCount,
      type: type ?? this.type,
      status: status ?? this.status,
    );
  }
}

extension NotificationTypeExtension on NotificationType {
  String get displayName {
    switch (this) {
      case NotificationType.general:
        return 'General';
      case NotificationType.promotional:
        return 'Promotional';
      case NotificationType.alert:
        return 'Alert';
      case NotificationType.update:
        return 'Update';
      case NotificationType.reminder:
        return 'Reminder';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationType.general:
        return Icons.notifications;
      case NotificationType.promotional:
        return Icons.campaign;
      case NotificationType.alert:
        return Icons.warning;
      case NotificationType.update:
        return Icons.update;
      case NotificationType.reminder:
        return Icons.alarm;
    }
  }

  Color get color {
    switch (this) {
      case NotificationType.general:
        return const Color(0xFF0E9EDC);
      case NotificationType.promotional:
        return const Color(0xFF10B981);
      case NotificationType.alert:
        return const Color(0xFFEF4444);
      case NotificationType.update:
        return const Color(0xFF8B5CF6);
      case NotificationType.reminder:
        return const Color(0xFFF59E0B);
    }
  }
}