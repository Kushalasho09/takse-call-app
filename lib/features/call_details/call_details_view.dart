import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/call_log_model.dart';
import '../../utils/animated_loader.dart';
import '../../utils/app_theme.dart';
import '../routes/app_pages.dart';
import 'call_details_controller.dart';

class CallDetailsView extends GetView<CallDetailsController> {
  const CallDetailsView({super.key});

  String _formatDuration(int seconds) {
    int h = seconds ~/ 3600;
    int m = (seconds % 3600) ~/ 60;
    int s = seconds % 60;
    return '${h}h ${m}m ${s}s';
  }

  String _formatTimeLabel(DateTime dt) {
    DateTime now = DateTime.now();
    bool isToday = dt.year == now.year && dt.month == now.month && dt.day == now.day;
    bool isYesterday = dt.year == now.year && dt.month == now.month && dt.day == now.day - 1;

    String datePrefix = isToday
        ? 'Today'
        : isYesterday
            ? 'Yesterday'
            : '${dt.day}/${dt.month}/${dt.year}';

    int hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    String minute = dt.minute.toString().padLeft(2, '0');
    String period = dt.hour >= 12 ? 'PM' : 'AM';

    return '$datePrefix | $hour:$minute $period';
  }

  void _showDurationBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E202B),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF64748B),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title Header
              const Text(
                'Select Duration',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              // Options List
              ...controller.durationOptions.map((option) {
                return Obx(() {
                  final isSelected = controller.selectedDuration.value == option;
                  return Column(
                    children: [
                      InkWell(
                        onTap: () async {
                          Navigator.pop(context);
                          if (option == 'Custom') {
                            await _pickCustomDateRange(context);
                          } else {
                            controller.setDurationDirect(option);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 24,
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        color: Color(0xFF2563EB),
                                        size: 20,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                                  ),
                                ),
                              ),
                              if (option == 'Custom')
                                const Icon(
                                  Icons.calendar_month_rounded,
                                  color: Color(0xFF2563EB),
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(
                        color: Color(0xFF2B2D3C),
                        height: 1,
                      ),
                    ],
                  );
                });
              }),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickCustomDateRange(BuildContext context) async {
    final now = DateTime.now();
    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: controller.customStartDate.value != null && controller.customEndDate.value != null
          ? DateTimeRange(
              start: controller.customStartDate.value!,
              end: controller.customEndDate.value!,
            )
          : DateTimeRange(
              start: now.subtract(const Duration(days: 7)),
              end: now,
            ),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF2563EB),
              onPrimary: Colors.white,
              surface: Color(0xFF1E202B),
              onSurface: Colors.white,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF191A20)),
          ),
          child: child!,
        );
      },
    );

    if (pickedRange != null) {
      controller.selectedDuration.value = 'Custom';
      controller.customStartDate.value = DateTime(pickedRange.start.year, pickedRange.start.month, pickedRange.start.day, 0, 0, 0);
      controller.customEndDate.value = DateTime(pickedRange.end.year, pickedRange.end.month, pickedRange.end.day, 23, 59, 59, 999);
    }
  }

  void _showCallTypeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E202B),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF64748B),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title Header
              const Text(
                'Select Call Type',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              // Options List
              ...controller.callTypeOptions.map((option) {
                return Obx(() {
                  final isSelected = controller.selectedCallType.value == option;
                  return Column(
                    children: [
                      InkWell(
                        onTap: () {
                          controller.setCallTypeDirect(option);
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 24,
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        color: Color(0xFF2563EB),
                                        size: 20,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                option,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(
                        color: Color(0xFF2B2D3C),
                        height: 1,
                      ),
                    ],
                  );
                });
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Get.put(CallDetailsController());
    final contactItem = controller.item;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contactItem.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              contactItem.number,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 12.5,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: AppAnimatedPulseLoader(
                size: 54,
                loadingText: 'Fetching call details...',
              ),
            );
          }

          return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Actions Bar (Call, WhatsApp, SMS, Add Note)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E202B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF282B3C), width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildActionButton(
                      icon: Icons.person_add_alt_1_rounded,
                      label: 'Add',
                      color: const Color(0xFF8B5CF6),
                      onTap: () => controller.addContact(context, contactItem.name, contactItem.number),
                    ),
                    _buildActionButton(
                      icon: Icons.call_rounded,
                      label: 'Call',
                      color: const Color(0xFF10B981),
                      onTap: () => controller.makePhoneCall(contactItem.number),
                    ),
                    _buildActionButton(
                      icon: Icons.chat_bubble_rounded,
                      label: 'WhatsApp',
                      color: const Color(0xFF25D366),
                      onTap: () => controller.openWhatsApp(contactItem.number),
                    ),
                    _buildActionButton(
                      icon: Icons.message_rounded,
                      label: 'SMS',
                      color: const Color(0xFF3B82F6),
                      onTap: () => controller.sendSms(contactItem.number),
                    ),
                    _buildActionButton(
                      icon: Icons.note_add_rounded,
                      label: 'Note',
                      color: const Color(0xFFF59E0B),
                      onTap: () => controller.openAddNote(contactItem),
                    ),
                  ],
                ),
              ),

              // Adaptive Top Filters Pill Row
              Obx(() {
                final currentTab = controller.activeTab.value;
                final isCallHistory = currentTab == 'Call History';

                if (!isCallHistory) {
                  // Summary & Analysis Tabs Filter Row (Images 1 & 2: Single All Time Dropdown)
                  final durationLabel = controller.selectedDuration.value;
                  return Row(
                    children: [
                      _buildFilterPill(
                        onTap: () => _showDurationBottomSheet(context),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              durationLabel,
                              style: const TextStyle(
                                fontSize: 13.5,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Color(0xFF2563EB),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                // Call History Tab Filter Row (Image 3: Filter 1 | Sort By: [v] | All Time [v])
                final count = controller.activeFilterCount;
                final durationLabel = controller.selectedDuration.value;
                final sortLabel = controller.selectedCallType.value == 'All'
                    ? 'Sort By:'
                    : controller.selectedCallType.value;

                return Row(
                  children: [
                    // Filter Pill 1
                    _buildFilterPill(
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
                              if (count > 0)
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
                    ),
                    const SizedBox(width: 8),

                    // Sort By Dropdown Pill
                    _buildFilterPill(
                      onTap: () => _showCallTypeBottomSheet(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            sortLabel,
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
                    ),
                    const SizedBox(width: 8),

                    // All Time Duration Dropdown Pill
                    _buildFilterPill(
                      onTap: () => _showDurationBottomSheet(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            durationLabel,
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
                    ),
                  ],
                );
              }),

              const SizedBox(height: 16),

              // Date Range Row
              Obx(() {
                final isCustom = controller.selectedDuration.value == 'Custom';
                return InkWell(
                  onTap: () async => await _pickCustomDateRange(context),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
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
                            controller.dateRangeText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isCustom)
                          const Icon(
                            Icons.edit_calendar_rounded,
                            color: Color(0xFF2563EB),
                            size: 18,
                          ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 20),

              // Sub-Tabs Header (Summary | Analysis | Call History)
              Obx(() {
                final currentTab = controller.activeTab.value;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSubTabItem('Summary', currentTab == 'Summary'),
                    _buildSubTabItem('Analysis', currentTab == 'Analysis'),
                    _buildSubTabItem('Call History', currentTab == 'Call History'),
                  ],
                );
              }),

              const SizedBox(height: 16),

              // Content according to Active Tab (Summary / Analysis / Call History)
              Obx(() {
                final activeTab = controller.activeTab.value;
                if (activeTab == 'Summary') {
                  return _buildSummaryTab();
                } else if (activeTab == 'Analysis') {
                  return _buildAnalysisTab(context);
                } else {
                  return _buildCallHistoryTab();
                }
              }),
            ],
          ),
        );
      }),
      ),
    );
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  // ── 1. Summary Tab View (Matching Image 2) ──────────────────────────────────
  Widget _buildSummaryTab() {
    final logs = controller.filteredLogs;

    final incomingLogs = logs.where((e) => e.type == CallType.incoming).toList();
    final outgoingLogs = logs.where((e) => e.type == CallType.outgoing).toList();
    final missedLogs = logs.where((e) => e.type == CallType.missed).toList();
    final rejectedLogs = logs.where((e) => e.type == CallType.rejected || e.type == CallType.neverAttended || e.type == CallType.notPickupByClient).toList();

    final int incomingDuration = incomingLogs.fold(0, (sum, item) => sum + item.durationInSeconds);
    final int outgoingDuration = outgoingLogs.fold(0, (sum, item) => sum + item.durationInSeconds);
    final int totalDuration = logs.fold(0, (sum, item) => sum + item.durationInSeconds);

    double incomingRatio = totalDuration > 0 ? (incomingDuration / totalDuration) : 0.5;
    double outgoingRatio = totalDuration > 0 ? (outgoingDuration / totalDuration) : 0.5;

    return Column(
      children: [
        // Donut Chart Container Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF212330),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF2B2D3C), width: 1),
          ),
          child: Column(
            children: [
              // Legend Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFFA3E635),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Incoming',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFFCBD5E1),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF59E0B),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Outgoing',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFFCBD5E1),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Donut Chart
              SizedBox(
                width: 160,
                height: 160,
                child: CustomPaint(
                  painter: _DonutChartPainter(
                    incomingRatio: incomingRatio,
                    outgoingRatio: outgoingRatio,
                    incomingColor: const Color(0xFFA3E635),
                    outgoingColor: const Color(0xFFF59E0B),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Call Breakdown Table
        Column(
          children: [
            // Table Header Row
            Row(
              children: const [
                Expanded(child: SizedBox()),
                SizedBox(
                  width: 80,
                  child: Text(
                    'Calls',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  width: 110,
                  child: Text(
                    'Duration',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Incoming Row
            _buildTableRow('Incoming', const Color(0xFFA3E635), '${incomingLogs.length}', _formatDuration(incomingDuration)),
            const SizedBox(height: 12),

            // Outgoing Row
            _buildTableRow('Outgoing', const Color(0xFFF59E0B), '${outgoingLogs.length}', _formatDuration(outgoingDuration)),
            const SizedBox(height: 12),

            // Missed Row
            _buildTableRow('Missed', const Color(0xFFEF4444), '${missedLogs.length}', '-'),
            const SizedBox(height: 12),

            // Rejected Row
            _buildTableRow('Rejected', const Color(0xFFEF4444), '${rejectedLogs.length}', '-'),
            const SizedBox(height: 16),

            const Divider(color: Color(0xFF282B3C), height: 1),
            const SizedBox(height: 16),

            // Total Row
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    '${logs.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  width: 110,
                  child: Text(
                    _formatDuration(totalDuration),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTableRow(String title, Color labelColor, String calls, String duration) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              color: labelColor,
            ),
          ),
        ),
        SizedBox(
          width: 80,
          child: Text(
            calls,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(
          width: 110,
          child: Text(
            duration,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  // ── 2. Analysis Tab View (Matching Image 1) ──────────────────────────────────
  Widget _buildAnalysisTab(BuildContext context) {
    final logs = controller.allLogs;

    // 1. Longest call calculation
    CallLogItem? longestCall;
    if (logs.isNotEmpty) {
      longestCall = logs.reduce((curr, next) => curr.durationInSeconds > next.durationInSeconds ? curr : next);
    }

    String longestDate = longestCall != null
        ? '${longestCall.timestamp.day} ${_monthName(longestCall.timestamp.month)} ${longestCall.timestamp.year}'
        : '-';
    String longestType = longestCall != null
        ? (longestCall.type == CallType.incoming ? 'Incoming' : longestCall.type == CallType.outgoing ? 'Outgoing' : 'Missed')
        : '-';
    Color longestTypeColor = longestCall != null
        ? (longestCall.type == CallType.incoming ? const Color(0xFFA3E635) : longestCall.type == CallType.outgoing ? const Color(0xFFF59E0B) : const Color(0xFFEF4444))
        : Colors.white;
    String longestDuration = longestCall != null ? _formatDuration(longestCall.durationInSeconds) : '0h 0m 0s';

    // 2. Average duration calculation
    int totalSec = logs.fold(0, (sum, e) => sum + e.durationInSeconds);
    int connectedCount = logs.where((e) => e.durationInSeconds > 0).length;
    int avgSec = connectedCount > 0 ? totalSec ~/ connectedCount : 0;

    int incomingSec = logs.where((e) => e.type == CallType.incoming).fold(0, (sum, e) => sum + e.durationInSeconds);
    int incomingConnCount = logs.where((e) => e.type == CallType.incoming && e.durationInSeconds > 0).length;
    int avgIncomingSec = incomingConnCount > 0 ? incomingSec ~/ incomingConnCount : 0;

    int outgoingSec = logs.where((e) => e.type == CallType.outgoing).fold(0, (sum, e) => sum + e.durationInSeconds);
    int outgoingConnCount = logs.where((e) => e.type == CallType.outgoing && e.durationInSeconds > 0).length;
    int avgOutgoingSec = outgoingConnCount > 0 ? outgoingSec ~/ outgoingConnCount : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card 1: Longest Call
        _buildAnalysisMetricCard(
          context: context,
          title: 'Longest Call',
          onTap: () => Get.toNamed(AppRoutes.longestCall),
          children: [
            _buildMetricRow('Date', longestDate),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Call Type',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFCBD5E1),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      longestType,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: longestTypeColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.white70, width: 1),
                      ),
                      child: const Text(
                        '1',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildMetricRow('Duration', longestDuration),
          ],
        ),
        const SizedBox(height: 24),

        // Card 2: Frequently Talked
        _buildAnalysisMetricCard(
          context: context,
          title: 'Frequently Talked',
          children: [
            _buildMetricRow('Date', controller.lastCallDateText),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'No of Calls',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFCBD5E1),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${logs.where((e) => e.type == CallType.incoming).length} Incoming Calls',
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${logs.where((e) => e.type == CallType.outgoing).length} Outgoing Calls',
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total ${logs.length} Calls',
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Card 3: Average Call Duration of Connected Calls
        _buildAnalysisMetricCard(
          context: context,
          title: 'Average Call Duration of Connected Calls',
          onTap: () => Get.toNamed(AppRoutes.avgCallDuration),
          children: [
            _buildMetricRow('Per Day', _formatDuration(controller.avgPerDayDurationSeconds)),
            const SizedBox(height: 8),
            _buildMetricRow('Per Call', _formatDuration(avgSec)),
            const SizedBox(height: 8),
            _buildMetricRow('Per Incoming Call', _formatDuration(avgIncomingSec)),
            const SizedBox(height: 8),
            _buildMetricRow('Per Outgoing Call', _formatDuration(avgOutgoingSec)),
          ],
        ),
      ],
    );
  }

  void _showCardInfoDialog(BuildContext context, String title) {
    String infoText = 'Detailed call performance breakdown for this contact.';
    if (title.contains('Summary')) {
      infoText = 'Overview of all call interactions with this contact, including total call counts and cumulative duration.';
    } else if (title.contains('Types')) {
      infoText = 'Breakdown of call types (Incoming, Outgoing, Missed, and Rejected) recorded for this contact.';
    } else if (title.contains('Duration')) {
      infoText = 'Average call duration metrics calculated per call, per incoming call, and per outgoing call.';
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E202B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB), size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          content: Text(
            infoText,
            style: const TextStyle(fontSize: 14, color: Color(0xFFCBD5E1), height: 1.4),
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

  Widget _buildAnalysisMetricCard({
    required BuildContext context,
    required String title,
    required List<Widget> children,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Header with info (i) icon on right
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.info_outline_rounded,
                  size: 20,
                  color: Color(0xFFCBD5E1),
                ),
                onPressed: () => _showCardInfoDialog(context, title),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFFCBD5E1),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // ── 3. Call History Tab View ───────────────────────────────────────────────
  Widget _buildCallHistoryTab() {
    final logs = controller.filteredLogs;
    if (logs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            'No call records match the selected filters',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14.5),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final item = logs[index];
        return _buildCallLogCard(context, item);
      },
    );
  }

  Widget _buildFilterPill({required Widget child, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1D26),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF282B3C), width: 1),
        ),
        child: child,
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              shape: BoxShape.circle,
              border: Border.all(color: color.withAlpha(100), width: 1),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubTabItem(String title, bool isSelected) {
    return GestureDetector(
      onTap: () => controller.setActiveTab(title),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: isSelected ? 6 : 0,
            height: isSelected ? 6 : 0,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallLogCard(BuildContext context, CallLogItem item) {
    final bool isIncoming = item.type == CallType.incoming;
    final bool isOutgoing = item.type == CallType.outgoing;

    final Color statusColor = isIncoming
        ? const Color(0xFFA3E635)
        : isOutgoing
            ? const Color(0xFFF59E0B)
            : const Color(0xFFEF4444);

    final IconData statusIcon = isIncoming
        ? Icons.call_received_rounded
        : isOutgoing
            ? Icons.call_made_rounded
            : Icons.call_missed_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E202B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF282B3C), width: 1),
      ),
      child: Column(
        children: [
          // Top Row: Status Icon Avatar + Status Title + Timestamp + Duration
          Row(
            children: [
              // Circle Avatar for status icon
              CircleAvatar(
                radius: 18,
                backgroundColor: statusColor.withAlpha(35),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),

              // Title & Time Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isIncoming
                              ? 'Incoming'
                              : isOutgoing
                                  ? 'Outgoing'
                                  : 'Missed',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        // SIM Badge [1]
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.white70, width: 1),
                          ),
                          child: const Text(
                            '1',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTimeLabel(item.timestamp),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),

              // Duration Pie Icon + Text
              Row(
                children: [
                  const Icon(
                    Icons.pie_chart_outline_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDuration(item.durationInSeconds),
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Bottom Note Container (Tapping opens AddNoteView - Image 2)
          GestureDetector(
            onTap: () => controller.openAddNote(item),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF14151E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF222432), width: 1),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.article_outlined,
                    size: 18,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.note ?? 'No notes attached yet',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: item.note != null ? Colors.white : const Color(0xFF94A3B8),
                        fontWeight: item.note != null ? FontWeight.w500 : FontWeight.w400,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: Color(0xFF94A3B8),
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

// ── Donut Chart Custom Painter ────────────────────────────────────────────────
class _DonutChartPainter extends CustomPainter {
  final double incomingRatio;
  final double outgoingRatio;
  final Color incomingColor;
  final Color outgoingColor;

  _DonutChartPainter({
    required this.incomingRatio,
    required this.outgoingRatio,
    required this.incomingColor,
    required this.outgoingColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double total = incomingRatio + outgoingRatio;
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 14;
    const strokeWidth = 28.0;

    final paintIncoming = Paint()
      ..color = incomingColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final paintOutgoing = Paint()
      ..color = outgoingColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    double startAngle = -pi / 2;
    double incomingSweep = (incomingRatio / total) * 2 * pi;
    double outgoingSweep = (outgoingRatio / total) * 2 * pi;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      incomingSweep,
      false,
      paintIncoming,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle + incomingSweep,
      outgoingSweep,
      false,
      paintOutgoing,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
