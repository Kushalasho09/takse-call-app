import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/prefs_service.dart';
import '../../services/session_manager.dart';
import '../../services/sim_card_service.dart';
import '../routes/app_pages.dart';

class NotificationPermissionController extends GetxController {
  var isLoading = false.obs;

  Future<void> requestPermission() async {
    isLoading.value = true;
    try {
      bool isGranted = false;

      if (!kIsWeb) {
        // Trigger system OS permission dialog for notifications
        final status = await Permission.notification.request();

        if (status.isGranted) {
          isGranted = true;
        } else if (status.isPermanentlyDenied) {
          Get.snackbar(
            'Permission Required',
            'Notification permission is required. Please enable it in system settings.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF1E293B),
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
          );
          await openAppSettings();
          return;
        } else {
          Get.snackbar(
            'Access Required',
            'Please allow notification permission in the system prompt to continue.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFEF4444),
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
          );
          return;
        }
      } else {
        isGranted = true;
      }

      if (isGranted) {
        await PrefsService.setNotificationPermissionGranted(true);
        await _proceedToNext();
      }
    } catch (e) {
      await PrefsService.setNotificationPermissionGranted(true);
      await _proceedToNext();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _proceedToNext() async {
    bool hasSim = await SimCardService.isSimInstalled();
    if (!hasSim) {
      Get.offAllNamed(AppRoutes.noSimCard);
    } else if (SessionManager.isAuthenticated) {
      Get.offAllNamed(AppRoutes.dashboard);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
