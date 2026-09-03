import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static bool get isLoggedIn => _prefs.getBool('is_logged_in') ?? false;

  static Future<void> setLoggedIn(bool value) async {
    await _prefs.setBool('is_logged_in', value);
  }

  static String get userName => _prefs.getString('user_name') ?? 'Rohan Sharma';

  static Future<void> setUserName(String name) async {
    await _prefs.setString('user_name', name);
  }

  static String get connectCode => _prefs.getString('connect_code') ?? 'ROH-3453-2342';

  static Future<void> setConnectCode(String code) async {
    await _prefs.setString('connect_code', code);
  }

  static String get userPhone => _prefs.getString('user_phone') ?? '+91 88663 69985';

  static Future<void> setUserPhone(String phone) async {
    await _prefs.setString('user_phone', phone);
  }

  static String get companyName => _prefs.getString('company_name') ?? 'Apex Enterprise';

  static Future<void> setCompanyName(String company) async {
    await _prefs.setString('company_name', company);
  }

  static bool get isCallLogPermissionGranted => _prefs.getBool('call_log_permission_granted') ?? false;

  static Future<void> setCallLogPermissionGranted(bool value) async {
    await _prefs.setBool('call_log_permission_granted', value);
  }

  static bool get isContactsPermissionGranted => _prefs.getBool('contacts_permission_granted') ?? false;

  static Future<void> setContactsPermissionGranted(bool value) async {
    await _prefs.setBool('contacts_permission_granted', value);
  }

  static bool get isNotificationPermissionGranted => _prefs.getBool('notification_permission_granted') ?? false;

  static Future<void> setNotificationPermissionGranted(bool value) async {
    await _prefs.setBool('notification_permission_granted', value);
  }

  static bool get isSimCardInstalled => _prefs.getBool('sim_card_installed') ?? true;

  static Future<void> setSimCardInstalled(bool value) async {
    await _prefs.setBool('sim_card_installed', value);
  }

  static String get selectedSimId => _prefs.getString('selected_sim_id') ?? 'all';

  static Future<void> setSelectedSimId(String simId) async {
    await _prefs.setString('selected_sim_id', simId);
  }

  static String? getCallNote(String key) {
    return _prefs.getString('call_note_$key');
  }

  static Future<void> setCallNote(String key, String note) async {
    await _prefs.setString('call_note_$key', note);
  }

  static Future<void> clear() async {
    await _prefs.clear();
  }
}
