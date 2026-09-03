import '../models/user_model.dart';
import 'prefs_service.dart';

class SessionManager {
  static UserModel? _currentUser;

  static void init() {
    if (PrefsService.isLoggedIn) {
      _currentUser = UserModel(
        id: 'usr_${PrefsService.connectCode}',
        name: PrefsService.userName,
        email: '',
        phone: PrefsService.userPhone,
        role: 'Sales Executive',
        companyName: PrefsService.companyName,
        connectCode: PrefsService.connectCode,
      );
    }
  }

  static UserModel? get currentUser => _currentUser;

  static bool get isAuthenticated => _currentUser != null || PrefsService.isLoggedIn;

  static void login(UserModel user) {
    _currentUser = user;
    PrefsService.setLoggedIn(true);
    PrefsService.setUserName(user.name);
    PrefsService.setConnectCode(user.connectCode);
    PrefsService.setUserPhone(user.phone);
    PrefsService.setCompanyName(user.companyName);
  }

  static void logout() {
    _currentUser = null;
    PrefsService.clear();
  }
}
