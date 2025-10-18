
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
