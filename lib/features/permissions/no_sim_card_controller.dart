import 'package:get/get.dart';
import '../../services/session_manager.dart';
import '../../services/sim_card_service.dart';
import '../routes/app_pages.dart';

class NoSimCardController extends GetxController {
  var isChecking = false.obs;

  Future<void> retryCheckSim() async {
    isChecking.value = true;
    await Future.delayed(const Duration(milliseconds: 800));
    bool hasSim = await SimCardService.isSimInstalled();
    isChecking.value = false;

    if (hasSim) {
      proceedToNext();
    }
  }

  void proceedToNext() {
    if (SessionManager.isAuthenticated) {
      Get.offAllNamed(AppRoutes.dashboard);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
