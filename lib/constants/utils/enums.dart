
enum AppAuthState{
  loggedOut,
  phoneAuth,
  loggedIn,
}

enum PaymentOptions{
  mpesa,
  airtel,
  cash
}
enum ApprovalFilter { 
  all,
  approved, 
  pending 
}


enum TripStatus {
  all,
  active,
  completed,
  cancelled_by_user,
  rejected,
}

enum InternetConnectionState{
  connected,
  weakConnection,
  disconnected
}

extension InternetConnectionStateExtension on InternetConnectionState{
  String get display{
    if(this == InternetConnectionState.connected){
      return 'connected';
    } else if(this == InternetConnectionState.disconnected) {
      return 'lost';
    } else{
      return 'is unstable';
    }
  }
}

enum AuthScreenDisplay{
  login,
  register
}

enum RiderStatus { 
  all, 
  approved, 
  pending, 
  suspended 
}

enum ReportType { 
  financial, 
  trips, 
  users, 
  riders 
}
enum DateRangeType { 
  today, 
  yesterday, 
  thisWeek, 
  thisMonth, 
  lastMonth, 
  custom 
}
enum RecipientType { all, users, riders, specific }
enum NotificationType {
  general,
  promotional,
  alert,
  update,
  reminder,
}

enum NotificationStatus {
  pending,
  sent,
  failed,
}