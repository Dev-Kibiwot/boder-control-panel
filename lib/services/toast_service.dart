import 'package:devboder/widgets/custom_toast_notification.dart';
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
    // Check if context is still valid
    if (!context.mounted) {
      print('⚠️ Toast skipped: Context is no longer mounted');
      return;
    }

    _removeCurrentToast();
    
    // Safely get overlay
    final overlay = Overlay.of(context, rootOverlay: true);
    
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
    try {
      _currentOverlay?.remove();
      _currentOverlay = null;
    } catch (e) {
      print('⚠️ Error removing toast: $e');
      _currentOverlay = null;
    }
  }

  void _removeOverlayEntry(OverlayEntry entry) {
    try {
      entry.remove();
      if (_currentOverlay == entry) {
        _currentOverlay = null;
      }
    } catch (e) {
      print('⚠️ Error removing overlay entry: $e');
      if (_currentOverlay == entry) {
        _currentOverlay = null;
      }
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