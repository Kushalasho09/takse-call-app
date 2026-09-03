import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/app_theme.dart';
import '../analytics/analytics_view.dart';
import '../call_logs/call_logs_view.dart';
import '../contacts/contacts_view.dart';
import '../my_leads/my_leads_view.dart';
import '../profile/profile_view.dart';
import 'dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(DashboardController());

    final pages = [
      const CallLogsView(),
      const AnalyticsView(),
      const MyLeadsView(),
      const ContactsView(),
      const ProfileView(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() => IndexedStack(
        index: controller.currentIndex.value,
        children: pages,
      )),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF161822),
            border: Border(
              top: BorderSide(color: Color(0xFF262938), width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              indicatorColor: AppColors.primary.withAlpha(45),
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  );
                }
                return const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                );
              }),
            ),
            child: NavigationBar(
              selectedIndex: controller.currentIndex.value,
              onDestinationSelected: controller.changeTab,
              backgroundColor: Colors.transparent,
              elevation: 0,
              height: 65,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.call_outlined, color: AppColors.textMuted),
                  selectedIcon: Icon(Icons.phone_rounded, color: AppColors.primary),
                  label: 'Call History',
                ),
                NavigationDestination(
                  icon: Icon(Icons.bar_chart_outlined, color: AppColors.textMuted),
                  selectedIcon: Icon(Icons.bar_chart_rounded, color: AppColors.primary),
                  label: 'Analytics',
                ),
                NavigationDestination(
                  icon: Icon(Icons.book_outlined, color: AppColors.textMuted),
                  selectedIcon: Icon(Icons.book_rounded, color: AppColors.primary),
                  label: 'My Leads',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline, color: AppColors.textMuted),
                  selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary),
                  label: 'Contacts',
                ),
                NavigationDestination(
                  icon: _MoreTabIcon(isSelected: false),
                  selectedIcon: _MoreTabIcon(isSelected: true),
                  label: 'More',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MoreTabIcon extends StatelessWidget {
  final bool isSelected;

  const _MoreTabIcon({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          Icons.format_list_bulleted_rounded,
          color: isSelected ? AppColors.primary : AppColors.textMuted,
        ),
        Positioned(
          top: -2,
          right: -4,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.outgoingCall,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.outgoingCall.withAlpha(120),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
