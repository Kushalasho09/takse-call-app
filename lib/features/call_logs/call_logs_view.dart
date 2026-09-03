import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/call_log_model.dart';
import '../../utils/animated_loader.dart';
import '../../utils/app_theme.dart';
import '../../utils/permission_required_widget.dart';
import '../routes/app_pages.dart';
import 'call_logs_controller.dart';

class CallLogsView extends GetView<CallLogsController> {
  const CallLogsView({super.key});

  void _showDialpadBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _DialpadBottomSheet(),
    );
  }

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

  @override
  Widget build(BuildContext context) {
    Get.put(CallLogsController());

    final filterTabs = [
      {'title': 'All Calls', 'filterKey': 'All', 'icon': Icons.phone_rounded, 'color': Colors.white},
      {'title': 'Incoming', 'filterKey': 'Incoming', 'icon': Icons.call_received_rounded, 'color': const Color(0xFFA3E635)},
      {'title': 'Outgoing', 'filterKey': 'Outgoing', 'icon': Icons.call_made_rounded, 'color': const Color(0xFFF59E0B)},
      {'title': 'Missed', 'filterKey': 'Missed', 'icon': Icons.call_missed_rounded, 'color': const Color(0xFFEF4444)},
      {'title': 'Rejected', 'filterKey': 'Rejected', 'icon': Icons.block_rounded, 'color': const Color(0xFFEF4444)},
      {'title': 'Never Attended', 'filterKey': 'Never Attended', 'icon': Icons.phone_disabled_rounded, 'color': const Color(0xFFEF4444)},
      {'title': 'Not Pickup by Client', 'filterKey': 'Not Pickup by Client', 'icon': Icons.phone_missed_rounded, 'color': const Color(0xFFEF4444)},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        heroTag: 'call_logs_fab',
        onPressed: () => _showDialpadBottomSheet(context),
        backgroundColor: const Color(0xFF2563EB),
        shape: const CircleBorder(),
        elevation: 6,
        child: const Icon(
          Icons.dialpad_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (!controller.hasPermission.value) {
            return PermissionRequiredWidget(
              title: 'Call History Permission Required',
              description:
                  'Task Call needs access to your call logs to display your call history, incoming/outgoing logs, and team stats.',
              icon: Icons.phone_locked_rounded,
              buttonText: 'Allow Permission',
              onGrantPermission: controller.requestCallLogPermission,
            );
          }

          return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top App Title & SIM Selector Button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Call History',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Obx(() {
                    final currentSim = controller.selectedSim.value;
                    return GestureDetector(
                      onTap: () => _showSimSelectorBottomSheet(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2638),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primary, width: 1.2),
                        ),
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
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 18,
                              color: Colors.white70,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Top Filter Tabs with icons and white dot indicator (Horizontally Scrollable)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Obx(() {
                final currentFilter = controller.selectedFilter.value;
                return Row(
                  children: filterTabs.map((tab) {
                    final title = tab['title'] as String;
                    final filterKey = tab['filterKey'] as String;
                    final icon = tab['icon'] as IconData;
                    final color = tab['color'] as Color;
                    final isSelected = (currentFilter == 'All' && filterKey == 'All') ||
                        currentFilter == filterKey;

                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () => controller.setFilter(filterKey),
                        behavior: HitTestBehavior.opaque,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF1E2638) : const Color(0xFF1B1D26),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : const Color(0xFF282B3C),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                icon,
                                size: 18,
                                color: isSelected ? Colors.white : color,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              }),
            ),

            const SizedBox(height: 10),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder, width: 1),
                ),
                child: TextField(
                  onChanged: controller.setSearchQuery,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  decoration: const InputDecoration(
                    hintText: 'Search call logs...',
                    hintStyle: TextStyle(color: Color(0xFF64748B), fontSize: 14.5),
                    prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 22),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

            // Section Header (Today)
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Text(
                'Today',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            // Call Logs List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const CallLogsShimmerLoader();
                }

                final logs = controller.displayedLogs;
                if (logs.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: controller.refreshCallLogs,
                    color: AppColors.primary,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 120),
                        Center(
                          child: Text(
                            'No call history found',
                            style: TextStyle(color: Color(0xFF64748B), fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.refreshCallLogs,
                  color: AppColors.primary,
                  child: ListView.builder(
                    controller: controller.scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    itemCount: logs.length + (controller.isLoadingMore.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == logs.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                              ),
                            ),
                          ),
                        );
                      }
                      final item = logs[index];
                      return _CallLogCardItem(item: item);
                    },
                  ),
                );
              }),
            ),
          ],
        );
      }),
      ),
    );
  }
}

class _CallLogCardItem extends StatelessWidget {
  final CallLogItem item;

  const _CallLogCardItem({required this.item});

  String _formatDuration(int seconds) {
    int h = seconds ~/ 3600;
    int m = (seconds % 3600) ~/ 60;
    int s = seconds % 60;
    return '${h}h ${m}m ${s}s';
  }

  String _formatTime(DateTime dt) {
    int hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    String minute = dt.minute.toString().padLeft(2, '0');
    String period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    if (item.type == CallType.notPickupByClient) {
      return _CompactCallLogCardItem(
        item: item,
        avatarBgColor: const Color(0xFFFBBF24),
        avatarIcon: Icons.call_made_rounded,
        avatarIconColor: const Color(0xFF1E2025),
        centerBottomIcon: null,
      );
    }

    if (item.type == CallType.neverAttended) {
      return _CompactCallLogCardItem(
        item: item,
        avatarBgColor: const Color(0xFFEF4444),
        avatarIcon: Icons.call_missed_rounded,
        avatarIconColor: Colors.white,
        centerBottomIcon: const Icon(
          Icons.call_missed_rounded,
          size: 18,
          color: Color(0xFFEF4444),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF22242E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2B2D38), width: 1),
      ),
      child: Column(
        children: [
          // Top Info Section (Tapping navigates to Contact Call History - Image 1)
          GestureDetector(
            onTap: () async {
              await Get.toNamed(AppRoutes.callDetails, arguments: item);
              Get.find<CallLogsController>().loadCallLogs(showLoader: true);
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Call Type Icon Avatar
                  _CallTypeAvatar(type: item.type),
                  const SizedBox(width: 12),

                  // Name, SIM, Number, Time, Duration
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Row: Name and SIM Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.1,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _SimCardBadge(simNumber: item.simId),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Bottom Row: Phone Number, Timestamp, Duration
                        Row(
                          children: [
                            Text(
                              item.number,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF9EA3B0),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _formatTime(item.timestamp),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF9EA3B0),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _formatDuration(item.durationInSeconds),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF9EA3B0),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Action Icons Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () => Get.find<CallLogsController>().addContact(context, item.name, item.number),
                  tooltip: 'Add Contact',
                  icon: const Icon(
                    Icons.person_add_outlined,
                    size: 24,
                    color: Color(0xFFA0A5B5),
                  ),
                ),
                IconButton(
                  onPressed: () => Get.find<CallLogsController>().makePhoneCall(item.number),
                  tooltip: 'Call',
                  icon: const Icon(
                    Icons.phone_outlined,
                    size: 24,
                    color: Color(0xFF2563EB),
                  ),
                ),
                IconButton(
                  onPressed: () => Get.find<CallLogsController>().openWhatsApp(item.number),
                  tooltip: 'WhatsApp',
                  icon: const _WhatsAppIcon(size: 24),
                ),
                IconButton(
                  onPressed: () => Get.find<CallLogsController>().sendSms(item.number),
                  tooltip: 'SMS',
                  icon: const _BackupSyncIcon(size: 24),
                ),
                IconButton(
                  onPressed: () => Get.find<CallLogsController>().copyToClipboard(item.number),
                  tooltip: 'Copy Number',
                  icon: const Icon(
                    Icons.copy_rounded,
                    size: 22,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Bottom Notes Container (Tapping navigates to AddNoteView - Image 2)
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.addNote, arguments: item),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF191A20),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.article_outlined,
                    size: 20,
                    color: Color(0xFF717482),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    item.note ?? 'Tap here to add notes',
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF717482),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactCallLogCardItem extends StatelessWidget {
  final CallLogItem item;
  final Color avatarBgColor;
  final IconData avatarIcon;
  final Color avatarIconColor;
  final Widget? centerBottomIcon;

  const _CompactCallLogCardItem({
    required this.item,
    required this.avatarBgColor,
    required this.avatarIcon,
    this.avatarIconColor = const Color(0xFF1E2025),
    this.centerBottomIcon,
  });

  String _formatTime(DateTime dt) {
    int hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    String minute = dt.minute.toString().padLeft(2, '0');
    String period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF22242E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2B2D38), width: 1),
      ),
      child: Column(
        children: [
          // Top Row: Avatar + Name/Phone + 4 Action Buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    await Get.toNamed(AppRoutes.callDetails, arguments: item);
                    Get.find<CallLogsController>().loadCallLogs(showLoader: true);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      // Avatar Circle
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: avatarBgColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          avatarIcon,
                          color: avatarIconColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Name & Phone Number
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.number,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF9EA3B0),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 4 Action Icons (Copy, Forum SMS, WhatsApp, Call)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => Get.find<CallLogsController>().copyToClipboard(item.number),
                    tooltip: 'Copy Number',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    icon: const Icon(
                      Icons.copy_rounded,
                      size: 22,
                      color: Color(0xFF9EA3B0),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.find<CallLogsController>().sendSms(item.number),
                    tooltip: 'SMS',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    icon: const Icon(
                      Icons.forum_outlined,
                      size: 22,
                      color: Color(0xFF3897F0),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: IconButton(
                      onPressed: () => Get.find<CallLogsController>().openWhatsApp(item.number),
                      tooltip: 'WhatsApp',
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      icon: const _WhatsAppIcon(size: 22),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.find<CallLogsController>().makePhoneCall(item.number),
                    tooltip: 'Call',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    icon: const Icon(
                      Icons.phone_outlined,
                      size: 22,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Bottom Row: ① Today | [Icon] 29 Jul 2026 | 06:08 PM [SIM 1]
          Row(
            children: [
              // Circle SIM Badge + Today
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF9EA3B0), width: 1.2),
                ),
                child: Center(
                  child: Text(
                    item.simId,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF9EA3B0),
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Today',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF9EA3B0),
                  fontWeight: FontWeight.w400,
                ),
              ),

              const Spacer(),

              // Center: (Optional Missed Icon) + Date
              if (centerBottomIcon != null) ...[
                centerBottomIcon!,
                const SizedBox(width: 4),
              ],
              Text(
                _formatDate(item.timestamp),
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF9EA3B0),
                  fontWeight: FontWeight.w400,
                ),
              ),

              const Spacer(),

              // Time + SIM Badge
              Text(
                _formatTime(item.timestamp),
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF9EA3B0),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(width: 8),
              _SimCardBadge(simNumber: item.simId),
            ],
          ),
        ],
      ),
    );
  }
}

class _CallTypeAvatar extends StatelessWidget {
  final CallType type;
  const _CallTypeAvatar({required this.type});

  @override
  Widget build(BuildContext context) {
    Color bg;
    IconData icon;
    Color iconColor;

    switch (type) {
      case CallType.incoming:
        bg = const Color(0xFFC5FF32);
        icon = Icons.call_received_rounded;
        iconColor = const Color(0xFF1E2025);
        break;
      case CallType.outgoing:
        bg = const Color(0xFFF59E0B);
        icon = Icons.call_made_rounded;
        iconColor = const Color(0xFF1E2025);
        break;
      case CallType.missed:
        bg = const Color(0xFFEF4444);
        icon = Icons.call_missed_rounded;
        iconColor = Colors.white;
        break;
      case CallType.rejected:
        bg = const Color(0xFFEF4444);
        icon = Icons.block_rounded;
        iconColor = Colors.white;
        break;
      case CallType.neverAttended:
        bg = const Color(0xFFEF4444);
        icon = Icons.phone_disabled_rounded;
        iconColor = Colors.white;
        break;
      case CallType.notPickupByClient:
        bg = const Color(0xFFEF4444);
        icon = Icons.phone_missed_rounded;
        iconColor = Colors.white;
        break;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: 22,
      ),
    );
  }
}

class _SimCardBadge extends StatelessWidget {
  final String simNumber;
  const _SimCardBadge({this.simNumber = '1'});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SimCardPainter(),
      child: SizedBox(
        width: 19,
        height: 23,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 1.0, right: 1.0),
            child: Text(
              simNumber,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                height: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SimCardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xE6FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    final path = Path();
    const double cutSize = 5.5;
    const double radius = 3.0;

    path.moveTo(radius, 0);
    path.lineTo(size.width - cutSize, 0);
    path.lineTo(size.width, cutSize);
    path.lineTo(size.width, size.height - radius);
    path.arcToPoint(Offset(size.width - radius, size.height), radius: const Radius.circular(radius));
    path.lineTo(radius, size.height);
    path.arcToPoint(Offset(0, size.height - radius), radius: const Radius.circular(radius));
    path.lineTo(0, radius);
    path.arcToPoint(Offset(radius, 0), radius: const Radius.circular(radius));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WhatsAppIcon extends StatelessWidget {
  final double size;
  const _WhatsAppIcon({this.size = 24.0});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/whatsapp.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}


class _BackupSyncIcon extends StatelessWidget {
  final double size;
  const _BackupSyncIcon({this.size = 24.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size + 4,
      height: size + 4,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFA0A5B5), width: 1.5),
            ),
            child: Icon(
              Icons.arrow_upward_rounded,
              size: size * 0.6,
              color: const Color(0xFFA0A5B5),
            ),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFF2563EB),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DialpadBottomSheet extends StatefulWidget {
  const _DialpadBottomSheet();

  @override
  State<_DialpadBottomSheet> createState() => _DialpadBottomSheetState();
}

class _DialpadBottomSheetState extends State<_DialpadBottomSheet> {
  String _input = '';

  void _onKeyPress(String value) {
    if (_input.length < 10) {
      setState(() {
        _input += value;
      });
    } else {
      Get.snackbar(
        '10 Digits Limit',
        'Phone number cannot exceed 10 digits',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF232530),
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    }
  }

  void _onBackspace() {
    if (_input.isNotEmpty) {
      setState(() {
        _input = _input.substring(0, _input.length - 1);
      });
    }
  }

  void _onClearAll() {
    setState(() {
      _input = '';
    });
  }

  Future<void> _makeCall() async {
    if (_input.trim().isEmpty) {
      Get.snackbar(
        'Enter Number',
        'Please enter a phone number to make a call',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
      return;
    }
    await Get.find<CallLogsController>().makePhoneCall(_input.trim());
  }

  Future<void> _openWhatsApp() async {
    if (_input.trim().isEmpty) {
      Get.snackbar(
        'Enter Number',
        'Please enter a phone number to open WhatsApp chat',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
      return;
    }
    await Get.find<CallLogsController>().openWhatsApp(_input.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF16171E),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Bar: Copy / Display Number / Delete
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Copy Button
              IconButton(
                onPressed: () {
                  if (_input.isNotEmpty) {
                    Get.find<CallLogsController>().copyToClipboard(_input);
                  }
                },
                icon: const Icon(
                  Icons.copy_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),

              // Number Display
              Expanded(
                child: Container(
                  alignment: Alignment.centerRight,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: Text(
                      _input,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),

              // Delete / Backspace Button
              GestureDetector(
                onLongPress: _onClearAll,
                child: IconButton(
                  onPressed: _onBackspace,
                  icon: const Icon(
                    Icons.backspace_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Keypad Grid 4x3
          _buildKeypadRow(['1', '2', '3']),
          const SizedBox(height: 18),
          _buildKeypadRow(['4', '5', '6']),
          const SizedBox(height: 18),
          _buildKeypadRow(['7', '8', '9']),
          const SizedBox(height: 18),
          _buildKeypadRow(['*', '0', '#']),

          const SizedBox(height: 28),

          // Bottom Action Buttons (WhatsApp, Call, Hide Keypad)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // WhatsApp Action Button
              IconButton(
                onPressed: _openWhatsApp,
                icon: const _WhatsAppIcon(size: 32),
              ),

              // Main Call Button (Large Blue Circle)
              GestureDetector(
                onTap: _makeCall,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2563EB),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x662563EB),
                        blurRadius: 16,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.phone_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),

              // Hide Dialpad Button
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.dialpad_rounded,
                  color: Color(0xFF64748B),
                  size: 26,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: keys.map((key) => _buildKeypadButton(key)).toList(),
    );
  }

  Widget _buildKeypadButton(String key) {
    return InkWell(
      onTap: () => _onKeyPress(key),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 72,
        height: 52,
        alignment: Alignment.center,
        child: key == '0'
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '0',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '+',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                      height: 1.0,
                    ),
                  ),
                ],
              )
            : Text(
                key,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
