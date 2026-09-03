import 'package:get/get.dart';
import '../../models/user_model.dart';
import '../../services/session_manager.dart';
import '../routes/app_pages.dart';

class ProfileController extends GetxController {
  final user = Rxn<UserModel>();

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  void loadProfile() {
    user.value = SessionManager.currentUser ?? UserModel.mock();
  }

  void logout() {
    SessionManager.logout();
    Get.offAllNamed(AppRoutes.login);
  }
}
