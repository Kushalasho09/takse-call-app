import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/prefs_service.dart';
import '../../services/session_manager.dart';
import '../routes/app_pages.dart';

import '../../services/sim_card_service.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));

    bool isCallLogGranted = PrefsService.isCallLogPermissionGranted;
    bool isContactsGranted = PrefsService.isContactsPermissionGranted;
    bool isNotificationGranted = PrefsService.isNotificationPermissionGranted;

    if (!kIsWeb) {
      try {
        if (!isCallLogGranted) {
          final status = await Permission.phone.status;
          isCallLogGranted = status.isGranted;
        }
        if (!isContactsGranted) {
          final status = await Permission.contacts.status;
          isContactsGranted = status.isGranted;
        }
        if (!isNotificationGranted) {
          final status = await Permission.notification.status;
          isNotificationGranted = status.isGranted;
        }
      } catch (_) {}
    }

    if (!isCallLogGranted) {
      Get.offAllNamed(AppRoutes.permissions);
    } else if (!isContactsGranted) {
      Get.offAllNamed(AppRoutes.contactsPermission);
    } else if (!isNotificationGranted) {
      Get.offAllNamed(AppRoutes.notificationPermission);
    } else {
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
}
