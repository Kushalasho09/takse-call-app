import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/post_call_lead_status_dialog.dart';
import 'call_log_service.dart';

class PostCallMonitorService with WidgetsBindingObserver {
  static final PostCallMonitorService _instance = PostCallMonitorService._internal();
  factory PostCallMonitorService() => _instance;
  PostCallMonitorService._internal();

  static const MethodChannel _channel = MethodChannel('com.callyzer.app/post_call');
  static String? lastDialedNumber;
  static DateTime? lastDialedTime;
  static bool _isInitialized = false;

  static void init() {
    if (_isInitialized) return;
    _isInitialized = true;

    WidgetsBinding.instance.addObserver(_instance);
    _setupMethodChannel();
  }

  /// Check whether 'Display over other apps' (SYSTEM_ALERT_WINDOW) is granted
  static Future<bool> isOverlayPermissionGranted() async {
    try {
      final bool? granted = await _channel.invokeMethod<bool>('checkOverlayPermission');
      return granted ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Open Android settings to allow 'Display over other apps'
  static Future<void> requestOverlayPermission() async {
    try {
      await _channel.invokeMethod('requestOverlayPermission');
    } catch (_) {}
  }

  /// Trigger native WindowManager overlay over any system dialer/app
  static Future<void> showNativeOverlay({
    required String phoneNumber,
    String callType = 'outgoing',
    int durationSeconds = 0,
  }) async {
    try {
      await _channel.invokeMethod('showNativeOverlay', {
        'phoneNumber': phoneNumber,
        'callType': callType,
        'durationSeconds': durationSeconds,
      });
    } catch (_) {}
  }

  static void _setupMethodChannel() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onCallEnded') {
        final data = call.arguments as Map<dynamic, dynamic>? ?? {};
        final phone = data['phoneNumber']?.toString() ?? '';
        final type = data['callType']?.toString() ?? 'outgoing';

        if (phone.isNotEmpty) {
          triggerPostCallDialog(
            phoneNumber: phone,
            callType: type,
          );
        }
      }
    });

    // Check if initial call data was passed on startup
    _channel.invokeMethod<Map<dynamic, dynamic>>('getInitialCallData').then((data) {
      if (data != null) {
        final phone = data['phoneNumber']?.toString() ?? '';
        final type = data['callType']?.toString() ?? 'outgoing';
        if (phone.isNotEmpty) {
          Future.delayed(const Duration(milliseconds: 1200), () {
            triggerPostCallDialog(phoneNumber: phone, callType: type);
          });
        }
      }
    }).catchError((_) {});
  }

  /// Mark when the user initiates a phone call from the app
  static void markOutgoingCall(String phoneNumber) {
    lastDialedNumber = phoneNumber;
    lastDialedTime = DateTime.now();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Check if we just returned from a dialed call
      if (lastDialedNumber != null && lastDialedTime != null) {
        final elapsed = DateTime.now().difference(lastDialedTime!);
        // If dialed within the last 30 minutes
        if (elapsed.inMinutes < 30) {
          final phone = lastDialedNumber!;
          lastDialedNumber = null;
          lastDialedTime = null;

          Future.delayed(const Duration(milliseconds: 600), () async {
            // Find recent call log to get duration if possible
            int duration = 0;
            String type = 'outgoing';
            try {
              final logs = await CallLogService.fetchCallLogsInBackground(forceRefresh: true);
              final recentMatch = logs.firstWhere(
                (l) => l.number.contains(phone) || phone.contains(l.number),
                orElse: () => logs.isNotEmpty ? logs.first : throw Exception(),
              );
              duration = recentMatch.durationInSeconds;
              type = recentMatch.type.name;
            } catch (_) {}

            triggerPostCallDialog(
              phoneNumber: phone,
              callType: type,
              durationSeconds: duration,
            );
          });
        }
      }
    }
  }

  /// Display the Truecaller-style Post Call Lead Status Dialog
  static void triggerPostCallDialog({
    required String phoneNumber,
    String? contactName,
    String callType = 'outgoing',
    int durationSeconds = 0,
    VoidCallback? onSaved,
  }) {
    final name = contactName?.isNotEmpty == true
        ? contactName!
        : CallLogService.resolveContactName(phoneNumber);

    PostCallLeadStatusDialog.show(
      phoneNumber: phoneNumber,
      contactName: name,
      callType: callType,
      durationSeconds: durationSeconds,
      onSaved: onSaved,
    );
  }
}
