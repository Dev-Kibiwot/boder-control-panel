import 'package:boder/widgets/custom_toast_notification.dart';
import 'package:flutter/material.dart';

class ToastService {
  static final ToastService _instance = ToastService._internal();
  factory ToastService() => _instance;
  ToastService._internal();
  OverlayEntry? _currentOverlay;

  void showToast({
    required BuildContext context,
    required String title,
    String message = '',
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 2),
  }) {
    _removeCurrentToast();
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        right: 0,
        child: ToastNotification(
          title: title,
          message: message,
          type: type,
          duration: duration,
          onClose: () {
            _removeOverlayEntry(overlayEntry);
          },
        ),
      ),
    );

    _currentOverlay = overlayEntry;
    overlay.insert(overlayEntry);
  }

  void _removeCurrentToast() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }

  void _removeOverlayEntry(OverlayEntry entry) {
    entry.remove();
    if (_currentOverlay == entry) {
      _currentOverlay = null;
    }
  }

  void showSuccess({
    required BuildContext context,
    required String message,
    String title = 'Success',
    Duration duration = const Duration(seconds: 3),
  }) {
    showToast(
      context: context,
      title: title,
      message: message,
      type: ToastType.success,
      duration: duration,
    );
  }

  void showError({
    required BuildContext context,
    required String message,
    String title = 'Error',
    Duration duration = const Duration(seconds: 3),
  }) {
    showToast(
      context: context,
      title: title,
      message: message,
      type: ToastType.error,
      duration: duration,
    );
  }

  void showWarning({
    required BuildContext context,
    required String message,
    String title = 'Warning',
    Duration duration = const Duration(seconds: 3),
  }) {
    showToast(
      context: context,
      title: title,
      message: message,
      type: ToastType.warning,
      duration: duration,
    );
  }

  void showInfo({
    required BuildContext context,
    required String message,
    String title = 'Info',
    Duration duration = const Duration(seconds: 3),
  }) {
    showToast(
      context: context,
      title: title,
      message: message,
      type: ToastType.info,
      duration: duration,
    );
  }
}

// extension BuildContextToast on BuildContext {
//   void showSuccessToast(String message, {String title = 'Success'}) {
//     ToastService().showSuccess(
//       context: this,
//       message: message,
//       title: title,
//     );
//   }

//   void showErrorToast(String message, {String title = 'Error'}) {
//     ToastService().showError(
//       context: this,
//       message: message,
//       title: title,
//     );
//   }

//   void showWarningToast(String message, {String title = 'Warning'}) {
//     ToastService().showWarning(
//       context: this,
//       message: message,
//       title: title,
//     );
//   }

//   void showInfoToast(String message, {String title = 'Info'}) {
//     ToastService().showInfo(
//       context: this,
//       message: message,
//       title: title,
//     );
//   }
// }