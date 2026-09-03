import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/app_theme.dart';
import '../../utils/filter_bottom_sheets.dart';
import '../../utils/permission_required_widget.dart';
import '../routes/app_pages.dart';
import 'analytics_controller.dart';

class AnalyticsView extends GetView<AnalyticsController> {
  const AnalyticsView({super.key});

  void _showSimSelectorBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF191A20),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select SIM Card',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Obx(() {
                final sims = controller.availableSims;
                final selected = controller.selectedSim.value;

                return Column(
                  children: sims.map((sim) {
                    final isSelected = selected.id == sim.id;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF22283A) : const Color(0xFF22242E),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : const Color(0xFF2B2D38),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: ListTile(
                        onTap: () {
                          controller.changeSim(sim);
                          Navigator.pop(context);
                        },
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary.withValues(alpha: 0.2) : const Color(0xFF2B2D38),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            sim.id == 'all' ? Icons.phonelink_setup_rounded : Icons.sim_card_rounded,
                            color: isSelected ? AppColors.primary : Colors.white70,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          sim.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                          ),
                        ),
                        subtitle: Text(
                          sim.carrierName,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 24)
                            : null,
                      ),
                    );
                  }).toList(),
                );
              }),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _showAnalyticsInfoDialog(BuildContext context, [String? title]) {
    final String dialogTitle = title ?? 'Analytics Guide';
    String description = 'Task Call Analytics provides complete statistical reports for your call activities.\n\n'
        '• Summary: View total calls, incoming, outgoing, missed, rejected, never attended, and unique contacts.\n'
        '• Analysis: Key highlights including Top Caller, Longest Call, Highest Total Duration, Average Duration, and Top Frequently Talked contacts.\n'
        '• SIM Filter: Isolate stats for SIM 1, SIM 2, or All SIMs.\n'
        '• Date Filter: Filter reports by Today, Yesterday, Week, Month, or Custom Date-to-Date ranges.';

    if (title != null) {
      if (title.contains('Total Phone Calls')) {
        description = 'Total number of incoming, outgoing, missed, and rejected call logs recorded during the selected period.';
      } else if (title.contains('Incoming')) {
        description = 'Total count and total talk time duration of calls received from external contacts.';
      } else if (title.contains('Outgoing')) {
        description = 'Total count and total talk time duration of calls initiated by you to contacts.';
      } else if (title.contains('Missed')) {
        description = 'Calls received on your phone that were not answered.';
      } else if (title.contains('Rejected')) {
        description = 'Incoming calls that were manually declined or rejected during ringing.';
      } else if (title.contains('Never Attended')) {
        description = 'Unique contacts from whom calls were received but never answered across your entire log history.';
      } else if (title.contains('Not Pickup')) {
        description = 'Outgoing calls initiated by you that were not picked up or answered by the client.';
      } else if (title.contains('Unique')) {
        description = 'Total count of distinct, unique phone numbers interacted with during the selected filter range.';
      } else if (title.contains('Top Caller')) {
        description = 'Contact who has interacted with you the highest number of total calls in the selected timeframe.';
      } else if (title.contains('Longest Call')) {
        description = 'Single call log record with the longest uninterrupted talk duration.';
      } else if (title.contains('Highest Total Duration')) {
        description = 'Contact with the highest cumulative total talk duration across all call logs.';
      } else if (title.contains('Average Call Duration')) {
        description = 'Average talk duration metrics computed per call and per active calling day.';
      } else if (title.contains('Top Frequently Talked')) {
        description = 'Contact with whom you have communicated most frequently over the selected period.';
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E202B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB), size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  dialogTitle,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          content: Text(
            description,
            style: const TextStyle(fontSize: 14, color: Color(0xFFCBD5E1), height: 1.45),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Got It', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Get.put(AnalyticsController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          if (!controller.hasPermission.value) {
            return PermissionRequiredWidget(
              title: 'Call Analytics Permission Required',
              description:
                  'Task Call needs access to your call history to compute total call duration, call ratios, and performance analytics.',
              icon: Icons.analytics_outlined,
              buttonText: 'Allow Permission',
              onGrantPermission: controller.requestAnalyticsPermission,
            );
          }

          return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Header with Info (i) button
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Analytics',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFF2563EB),
                        size: 24,
                      ),
                      onPressed: () => _showAnalyticsInfoDialog(context),
                    ),
                  ],
                ),
              ),

              // Top Filters Pill Row (Horizontally Scrollable for all screen sizes)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    // Filter Pill (Count) -> Opens FilterByView
                    Obx(() {
                      final count = controller.activeFilterCount;
                      return _buildFilterPill(
                        onTap: () => Get.toNamed(AppRoutes.filterBy),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                const Icon(
                                  Icons.filter_alt_outlined,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF2563EB),
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 12,
                                      minHeight: 12,
                                    ),
                                    child: Text(
                                      '$count',
                                      style: const TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Filter',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(width: 8),

                    // SIM Selector Pill -> Opens SIM Bottom Sheet
                    Obx(() {
                      final currentSim = controller.selectedSim.value;
                      return _buildFilterPill(
                        onTap: () => _showSimSelectorBottomSheet(context),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.sim_card_outlined,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              currentSim.name,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Color(0xFF2563EB),
                              size: 18,
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(width: 8),

                    // Duration Dropdown Pill -> Opens Duration Bottom Sheet (with Custom Date Range Picker)
                    Obx(() {
                      final range = controller.selectedRange.value;
                      return _buildFilterPill(
                        onTap: () => FilterBottomSheets.showDurationBottomSheet(
                          context,
                          selected: range,
                          onSelected: controller.setRange,
                          onCustomRangeSelected: controller.setCustomDateRange,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              range,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Color(0xFF2563EB),
                              size: 18,
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(width: 8),

                    // Ex. No.:Yes Dropdown Pill -> Opens Exclude Numbers Bottom Sheet
                    Obx(() {
                      final exNo = controller.selectedExcludeNo.value;
                      return _buildFilterPill(
                        onTap: () => FilterBottomSheets.showExcludeNoBottomSheet(
                          context,
                          selected: exNo,
                          onSelected: (val) {
                            controller.selectedExcludeNo.value = val;
                            controller.applyFilters();
                          },
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Ex. No.:$exNo',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Color(0xFF2563EB),
                              size: 18,
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Calendar Date Range Row (Shown ONLY when Custom duration is selected)
              Obx(() {
                if (controller.selectedRange.value != 'Custom') {
                  return const SizedBox.shrink();
                }
                return Column(
                  children: [
                    InkWell(
                      onTap: () async => await FilterBottomSheets.pickCustomDateRange(
                        context,
                        controller.setCustomDateRange,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              color: Color(0xFF2563EB),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                controller.dateRangeBannerText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.edit_calendar_rounded,
                              color: Color(0xFF2563EB),
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              }),

              const SizedBox(height: 18),

              // Sub-Tabs Header (Summary vs Analysis)
              Obx(() {
                final currentTab = controller.activeTab.value;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Summary Tab
                    GestureDetector(
                      onTap: () => controller.setActiveTab('Summary'),
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        children: [
                          Text(
                            'Summary',
                            style: TextStyle(
                              fontSize: 14,
                              color: currentTab == 'Summary' ? Colors.white : const Color(0xFF94A3B8),
                              fontWeight: currentTab == 'Summary' ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: currentTab == 'Summary' ? 6 : 0,
                            height: currentTab == 'Summary' ? 6 : 0,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Analysis Tab
                    GestureDetector(
                      onTap: () => controller.setActiveTab('Analysis'),
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        children: [
                          Text(
                            'Analysis',
                            style: TextStyle(
                              fontSize: 14,
                              color: currentTab == 'Analysis' ? Colors.white : const Color(0xFF94A3B8),
                              fontWeight: currentTab == 'Analysis' ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: currentTab == 'Analysis' ? 6 : 0,
                            height: currentTab == 'Analysis' ? 6 : 0,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),

              const SizedBox(height: 16),

              // Body Content depending on active tab
              Obx(() {
                final currentTab = controller.activeTab.value;
                if (currentTab == 'Summary') {
                  final stats = controller.stats.value;
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.15,
                    children: [
                      // 1. Total Phone Calls
                      _SummaryStatCard(
                        title: 'Total Phone Calls',
                        iconWidget: const Icon(
                          Icons.swap_calls_rounded,
                          color: Color(0xFF3B82F6),
                          size: 24,
                        ),
                        countText: '${stats.totalCalls}',
                        durationText: _formatDuration(stats.totalDurationSeconds),
                        onTap: () => _showAnalyticsInfoDialog(context, 'Total Phone Calls'),
                      ),

                      // 2. Incoming Calls
                      _SummaryStatCard(
                        title: 'Incoming Calls',
                        iconWidget: const Icon(
                          Icons.call_received_rounded,
                          color: Color(0xFFA3E635),
                          size: 24,
                        ),
                        countText: '${stats.incomingCount}',
                        durationText: _formatDuration(stats.incomingDurationSeconds),
                        onTap: () => _showAnalyticsInfoDialog(context, 'Incoming Calls'),
                      ),

                      // 3. Outgoing Calls
                      _SummaryStatCard(
                        title: 'Outgoing Calls',
                        iconWidget: const Icon(
                          Icons.call_made_rounded,
                          color: Color(0xFFF59E0B),
                          size: 24,
                        ),
                        countText: '${stats.outgoingCount}',
                        durationText: _formatDuration(stats.outgoingDurationSeconds),
                        onTap: () => _showAnalyticsInfoDialog(context, 'Outgoing Calls'),
                      ),

                      // 4. Missed Calls
                      _SummaryStatCard(
                        title: 'Missed Calls',
                        iconWidget: const Icon(
                          Icons.call_missed_rounded,
                          color: Color(0xFFEF4444),
                          size: 24,
                        ),
                        countText: '${stats.missedCount}',
                        durationText: '0h 0m 0s',
                        onTap: () => _showAnalyticsInfoDialog(context, 'Missed Calls'),
                      ),

                      // 5. Rejected Calls
                      _SummaryStatCard(
                        title: 'Rejected Calls',
                        iconWidget: const Icon(
                          Icons.phone_disabled_rounded,
                          color: Color(0xFFEF4444),
                          size: 24,
                        ),
                        countText: '${stats.rejectedCount}',
                        durationText: '0h 0m 0s',
                        onTap: () => _showAnalyticsInfoDialog(context, 'Rejected Calls'),
                      ),

                      // 6. Never Attended
                      _SummaryStatCard(
                        title: 'Never Attended',
                        iconWidget: const Icon(
                          Icons.phone_missed_rounded,
                          color: Color(0xFF3B82F6),
                          size: 24,
                        ),
                        countText: '${stats.neverAttendedCount}',
                        onTap: () => _showAnalyticsInfoDialog(context, 'Never Attended'),
                      ),

                      // 7. Not Pickup by Client
                      _SummaryStatCard(
                        title: 'Not Pickup by Client',
                        iconWidget: const Icon(
                          Icons.phone_paused_rounded,
                          color: Color(0xFF38BDF8),
                          size: 24,
                        ),
                        countText: '${stats.notPickupByClientCount}',
                        onTap: () => _showAnalyticsInfoDialog(context, 'Not Pickup by Client'),
                      ),

                      // 8. Unique Calls
                      _SummaryStatCard(
                        title: 'Unique Calls',
                        iconWidget: const Icon(
                          Icons.person_pin_rounded,
                          color: Color(0xFF60A5FA),
                          size: 24,
                        ),
                        countText: '${stats.uniqueCallsCount}',
                        onTap: () => _showAnalyticsInfoDialog(context, 'Unique Calls'),
                      ),
                    ],
                  );
                }

                // Grid of 6 Redesigned Premium Dynamic Cards in Analysis Tab
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.78,
                  children: [
                    _AnalyticsCardItem(
                      cardData: controller.topCallerCard,
                      onTap: () {
                        final item = controller.getLogItemForCard(controller.topCallerCard);
                        if (item != null) Get.toNamed(AppRoutes.callDetails, arguments: item);
                      },
                    ),
                    _AnalyticsCardItem(
                      cardData: controller.longestCallCard,
                      onTap: () {
                        final item = controller.longestCallItem;
                        if (item != null) Get.toNamed(AppRoutes.callDetails, arguments: item);
                      },
                    ),
                    _AnalyticsCardItem(
                      cardData: controller.highestTotalDurationCard,
                      onTap: () {
                        final item = controller.getLogItemForCard(controller.highestTotalDurationCard);
                        if (item != null) Get.toNamed(AppRoutes.callDetails, arguments: item);
                      },
                    ),
                    _AnalyticsCardItem(
                      cardData: controller.avgCallDurationCard,
                      onTap: () => Get.toNamed(AppRoutes.avgCallDuration),
                    ),
                    _AnalyticsCardItem(
                      cardData: controller.topFrequentlyTalkedCard,
                      onTap: () {
                        final item = controller.getLogItemForCard(controller.topFrequentlyTalkedCard);
                        if (item != null) Get.toNamed(AppRoutes.callDetails, arguments: item);
                      },
                    ),
                    _AnalyticsCardItem(
                      cardData: controller.topCallDurationCard,
                      onTap: () {
                        final item = controller.getLogItemForCard(controller.topCallDurationCard);
                        if (item != null) Get.toNamed(AppRoutes.callDetails, arguments: item);
                      },
                    ),
                  ],
                );
              }),
            ],
          ),
        );
      }),
      ),
    );
  }

  Widget _buildFilterPill({required Widget child, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1D26),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(20),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class _AnalyticsCardItem extends StatelessWidget {
  final AnalyticsCardData cardData;
  final VoidCallback? onTap;

  const _AnalyticsCardItem({
    required this.cardData,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasSeparateNumber = cardData.phoneNumber.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E202B),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: cardData.accentColor.withAlpha(45), width: 1),
          boxShadow: [
            BoxShadow(
              color: cardData.accentColor.withAlpha(25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Title Header
            Text(
              cardData.title,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFFCBD5E1),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // Center Big 3D Image with Glowing Aura
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: cardData.accentColor.withAlpha(50),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  cardData.imageAsset,
                  width: 58,
                  height: 58,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: cardData.accentColor.withAlpha(40),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(cardData.icon, size: 28, color: cardData.accentColor),
                  ),
                ),
              ),
            ),

            // Below Center Image: Contact Name + Number
            Column(
              children: [
                Text(
                  cardData.contactName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (hasSeparateNumber) ...[
                  const SizedBox(height: 2),
                  Text(
                    cardData.phoneNumber,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),

            // Bottom Label (Metric Pill)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: cardData.accentColor.withAlpha(25),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cardData.accentColor.withAlpha(60), width: 1),
              ),
              child: Text(
                cardData.metricText,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: cardData.accentColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDuration(int seconds) {
  int h = seconds ~/ 3600;
  int m = (seconds % 3600) ~/ 60;
  int s = seconds % 60;
  return '${h}h ${m}m ${s}s';
}

class _SummaryStatCard extends StatelessWidget {
  final String title;
  final Widget iconWidget;
  final String countText;
  final String? durationText;
  final VoidCallback? onTap;

  const _SummaryStatCard({
    required this.title,
    required this.iconWidget,
    required this.countText,
    this.durationText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E202B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF2A2D3E), width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header: Icon + Title
          Row(
            children: [
              iconWidget,
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE2E8F0),
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          // Count Row: Phone icon + Big count
          Row(
            children: [
              const Icon(Icons.phone_outlined, size: 16, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                countText,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),

          // Duration Row (optional)
          if (durationText != null)
            Row(
              children: [
                const Icon(
                  Icons.timer_outlined,
                  size: 15,
                  color: Color(0xFF94A3B8),
                ),
                const SizedBox(width: 8),
                Text(
                  durationText!,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
        ],
      ),
    ),
  );
}
}
