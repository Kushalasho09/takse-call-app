import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/prefs_service.dart';
import '../routes/app_pages.dart';

class ContactsPermissionController extends GetxController {
  var isLoading = false.obs;

  Future<void> requestPermission() async {
    isLoading.value = true;
    try {
      bool isGranted = false;

      if (!kIsWeb) {
        // Trigger system OS permission dialog for contacts
        final status = await Permission.contacts.request();

        if (status.isGranted) {
          isGranted = true;
        } else if (status.isPermanentlyDenied) {
          Get.snackbar(
            'Permission Required',
            'Contacts permission is required. Please enable it in system settings.',
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
            'Please allow contacts permission in the system prompt to continue.',
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
        await PrefsService.setContactsPermissionGranted(true);
        _proceedToNext();
      }
    } catch (e) {
      await PrefsService.setContactsPermissionGranted(true);
      _proceedToNext();
    } finally {
      isLoading.value = false;
    }
  }

  void _proceedToNext() {
    if (!PrefsService.isNotificationPermissionGranted) {
      Get.offAllNamed(AppRoutes.notificationPermission);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
