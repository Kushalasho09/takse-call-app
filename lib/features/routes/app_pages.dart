import 'package:get/get.dart';

import '../analytics/analytics_controller.dart';
import '../analytics/analytics_view.dart';
import '../automation/automation_settings_view.dart';
import '../auth/login_controller.dart';
import '../auth/login_view.dart';
import '../analytics/metric_details/avg_call_duration_view.dart';
import '../analytics/metric_details/longest_call_view.dart';
import '../analytics/metric_details/missed_calls_view.dart';
import '../call_details/add_note_controller.dart';
import '../call_details/add_note_view.dart';
import '../call_details/call_details_controller.dart';
import '../call_details/call_details_view.dart';
import '../call_details/filter_by_view.dart';
import '../call_logs/call_logs_controller.dart';
import '../call_logs/call_logs_view.dart';
import '../contacts/contacts_controller.dart';
import '../contacts/contacts_view.dart';
import '../dashboard/dashboard_controller.dart';
import '../dashboard/dashboard_view.dart';
import '../home/home_controller.dart';
import '../home/home_view.dart';
import '../permissions/call_history_permission_controller.dart';
import '../permissions/call_history_permission_view.dart';
import '../permissions/contacts_permission_controller.dart';
import '../permissions/contacts_permission_view.dart';
import '../permissions/no_sim_card_controller.dart';
import '../permissions/no_sim_card_view.dart';
import '../permissions/notification_permission_controller.dart';
import '../permissions/notification_permission_view.dart';
import '../profile/profile_controller.dart';
import '../profile/profile_view.dart';
import '../sim_selection/work_sim_selection_controller.dart';
import '../sim_selection/work_sim_selection_view.dart';
import '../splash/splash_controller.dart';
import '../splash/splash_view.dart';

// ── Global binding ────────────────────────────────────────────
class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(() => SplashController(), fenix: true);
    Get.lazyPut<LoginController>(() => LoginController(), fenix: true);
    Get.lazyPut<DashboardController>(() => DashboardController(), fenix: true);
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<CallLogsController>(() => CallLogsController(), fenix: true);
    Get.lazyPut<CallDetailsController>(() => CallDetailsController(), fenix: true);
    Get.lazyPut<AnalyticsController>(() => AnalyticsController(), fenix: true);
    Get.lazyPut<ContactsController>(() => ContactsController(), fenix: true);
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
  }
}

// ── Routes ────────────────────────────────────────────────────
class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
      binding: BindingsBuilder(() {
        Get.put(DashboardController());
      }),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: BindingsBuilder(() {
        Get.put(HomeController());
      }),
    ),
    GetPage(
      name: AppRoutes.callLogs,
      page: () => const CallLogsView(),
      binding: BindingsBuilder(() {
        Get.put(CallLogsController());
      }),
    ),
    GetPage(
      name: AppRoutes.callDetails,
      page: () => const CallDetailsView(),
      binding: BindingsBuilder(() {
        Get.put(CallDetailsController());
      }),
    ),
    GetPage(
      name: AppRoutes.addNote,
      page: () => const AddNoteView(),
      binding: BindingsBuilder(() {
        Get.put(AddNoteController());
      }),
    ),
    GetPage(
      name: AppRoutes.filterBy,
      page: () => const FilterByView(),
    ),
    GetPage(
      name: AppRoutes.longestCall,
      page: () => const LongestCallView(),
    ),
    GetPage(
      name: AppRoutes.avgCallDuration,
      page: () => const AvgCallDurationView(),
    ),
    GetPage(
      name: AppRoutes.missedCalls,
      page: () => const MissedCallsView(),
    ),
    GetPage(
      name: AppRoutes.analytics,
      page: () => const AnalyticsView(),
      binding: BindingsBuilder(() {
        Get.put(AnalyticsController());
      }),
    ),
    GetPage(
      name: AppRoutes.contacts,
      page: () => const ContactsView(),
      binding: BindingsBuilder(() {
        Get.put(ContactsController());
      }),
    ),
    GetPage(
      name: AppRoutes.permissions,
      page: () => const CallHistoryPermissionView(),
      binding: BindingsBuilder(() {
        Get.put(CallHistoryPermissionController());
      }),
    ),
    GetPage(
      name: AppRoutes.contactsPermission,
      page: () => const ContactsPermissionView(),
      binding: BindingsBuilder(() {
        Get.put(ContactsPermissionController());
      }),
    ),
    GetPage(
      name: AppRoutes.notificationPermission,
      page: () => const NotificationPermissionView(),
      binding: BindingsBuilder(() {
        Get.put(NotificationPermissionController());
      }),
    ),
    GetPage(
      name: AppRoutes.noSimCard,
      page: () => const NoSimCardView(),
      binding: BindingsBuilder(() {
        Get.put(NoSimCardController());
      }),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: BindingsBuilder(() {
        Get.put(ProfileController());
      }),
    ),
    GetPage(
      name: AppRoutes.automationSettings,
      page: () => const AutomationSettingsView(),
    ),
    GetPage(
      name: AppRoutes.workSimSelection,
      page: () => const WorkSimSelectionView(),
      binding: BindingsBuilder(() {
        Get.put(WorkSimSelectionController());
      }),
    ),
  ];
}

// ── Route name constants ──────────────────────────────────────
abstract class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const home = '/home';
  static const callLogs = '/call-logs';
  static const callDetails = '/call-details';
  static const addNote = '/add-note';
  static const filterBy = '/filter-by';
  static const longestCall = '/longest-call';
  static const avgCallDuration = '/avg-call-duration';
  static const missedCalls = '/missed-calls';
  static const analytics = '/analytics';
  static const contacts = '/contacts';
  static const permissions = '/permissions';
  static const contactsPermission = '/contacts-permission';
  static const notificationPermission = '/notification-permission';
  static const noSimCard = '/no-sim-card';
  static const profile = '/profile';
  static const automationSettings = '/automation-settings';
  static const workSimSelection = '/work-sim-selection';
}
