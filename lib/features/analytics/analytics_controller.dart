import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../models/call_log_model.dart';
import '../../models/call_stats_model.dart';
import '../../services/call_log_service.dart';

import '../../models/sim_card_model.dart';
import '../../services/sim_card_service.dart';
import '../../services/prefs_service.dart';

class AnalyticsCardData {
  final String title;
  final String contactName;
  final String phoneNumber;
  final String metricText;
  final IconData icon;
  final String imageAsset;
  final Color accentColor;

  AnalyticsCardData({
    required this.title,
    required this.contactName,
    required String phoneNumber,
    required this.metricText,
    required this.icon,
    required this.imageAsset,
    required this.accentColor,
  }) : phoneNumber = (_cleanPhone(phoneNumber) == _cleanPhone(contactName))
            ? ''
            : phoneNumber;

  static String _cleanPhone(String str) => str.replaceAll(RegExp(r'[^0-9]'), '');
}

class AnalyticsController extends GetxController {
  final activeTab = 'Analysis'.obs; // 'Summary' or 'Analysis'
  final selectedRange = 'Today'.obs;
  final selectedCallType = 'All'.obs;
  final selectedExcludeNo = 'Yes'.obs;

  final customStartDate = Rx<DateTime?>(null);
  final customEndDate = Rx<DateTime?>(null);

  final availableSims = <SimCardInfo>[].obs;
  final selectedSim = Rx<SimCardInfo>(
    const SimCardInfo(id: 'all', name: 'All SIMs', carrierName: 'All Networks'),
  );

  final allLogs = <CallLogItem>[].obs;
  final filteredLogs = <CallLogItem>[].obs;
  final stats = CallStatsModel.empty().obs;
  final isLoading = false.obs;
  final hasPermission = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadSimsAndAnalytics();
  }

  Future<void> loadSimsAndAnalytics() async {
    await loadAvailableSims();
    await checkPermissionAndLoad();
  }

  Future<void> loadAvailableSims() async {
    try {
      final sims = await SimCardService.getAvailableSimCards();
      if (sims.isNotEmpty) {
        availableSims.assignAll(sims);
        final savedSimId = PrefsService.selectedSimId;
        final matched = sims.firstWhere(
          (element) => element.id == savedSimId,
          orElse: () => sims.first,
        );
        selectedSim.value = matched;
      }
    } catch (e) {
      debugPrint('Error loading SIMs in Analytics: $e');
    }
  }

  void changeSim(SimCardInfo sim) {
    selectedSim.value = sim;
    PrefsService.setSelectedSimId(sim.id);
    applyFilters();
  }

  Future<void> checkPermissionAndLoad() async {
    try {
      final status = await Permission.phone.status;
      hasPermission.value = status.isGranted || true;
    } catch (_) {
      hasPermission.value = true;
    }
    loadAnalytics();
  }

  Future<void> requestAnalyticsPermission() async {
    try {
      final status = await Permission.phone.request();
      hasPermission.value = status.isGranted || true;
    } catch (_) {
      hasPermission.value = true;
    }
    loadAnalytics();
  }

  void setActiveTab(String tab) {
    activeTab.value = tab;
  }

  int get activeFilterCount {
    int count = 0;
    if (selectedRange.value != 'All Time') count++;
    if (selectedCallType.value != 'All') count++;
    if (selectedSim.value.id != 'all') count++;
    if (selectedExcludeNo.value == 'Yes') count++;
    return count;
  }

  void setRange(String range) {
    selectedRange.value = range;
    applyFilters();
  }

  void setCustomDateRange(DateTime start, DateTime end) {
    selectedRange.value = 'Custom';
    customStartDate.value = DateTime(start.year, start.month, start.day, 0, 0, 0);
    customEndDate.value = DateTime(end.year, end.month, end.day, 23, 59, 59, 999);
    applyFilters();
  }

  void setCallType(String callType) {
    selectedCallType.value = callType;
    applyFilters();
  }

  void toggleExcludeNo() {
    selectedExcludeNo.value = selectedExcludeNo.value == 'Yes' ? 'No' : 'Yes';
    applyFilters();
  }

  Future<void> loadAnalytics() async {
    isLoading.value = true;
    try {
      final logs = await CallLogService.fetchCallLogsInBackground();
      allLogs.assignAll(logs);
      applyFilters();
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters() {
    var result = List<CallLogItem>.from(allLogs);

    // 1. SIM Card Filter
    if (selectedSim.value.id != 'all') {
      result = result.where((e) => e.simId == selectedSim.value.id).toList();
    }

    // 2. Exclude Spam Filter
    if (selectedExcludeNo.value == 'Yes') {
      result = result.where((e) => e.tag != CallTag.spam).toList();
    }

    // 3. Date Range Filter
    DateTime now = DateTime.now();
    if (selectedRange.value == 'Today') {
      final start = DateTime(now.year, now.month, now.day, 0, 0, 0);
      final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
      result = result.where((e) => e.timestamp.isAfter(start.subtract(const Duration(milliseconds: 1))) && e.timestamp.isBefore(end.add(const Duration(milliseconds: 1)))).toList();
    } else if (selectedRange.value == 'Yesterday') {
      DateTime yesterday = now.subtract(const Duration(days: 1));
      final start = DateTime(yesterday.year, yesterday.month, yesterday.day, 0, 0, 0);
      final end = DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59, 999);
      result = result.where((e) => e.timestamp.isAfter(start.subtract(const Duration(milliseconds: 1))) && e.timestamp.isBefore(end.add(const Duration(milliseconds: 1)))).toList();
    } else if (selectedRange.value == 'Week') {
      DateTime weekAgo = now.subtract(const Duration(days: 6));
      final start = DateTime(weekAgo.year, weekAgo.month, weekAgo.day, 0, 0, 0);
      result = result.where((e) => e.timestamp.isAfter(start.subtract(const Duration(milliseconds: 1)))).toList();
    } else if (selectedRange.value == 'Month') {
      DateTime monthAgo = now.subtract(const Duration(days: 29));
      final start = DateTime(monthAgo.year, monthAgo.month, monthAgo.day, 0, 0, 0);
      result = result.where((e) => e.timestamp.isAfter(start.subtract(const Duration(milliseconds: 1)))).toList();
    } else if (selectedRange.value == 'Custom' && customStartDate.value != null && customEndDate.value != null) {
      final start = customStartDate.value!;
      final end = customEndDate.value!;
      result = result.where((e) => e.timestamp.isAfter(start.subtract(const Duration(milliseconds: 1))) && e.timestamp.isBefore(end.add(const Duration(milliseconds: 1)))).toList();
    }

    // 4. Call Type Filter
    if (selectedCallType.value == 'Incoming') {
      result = result.where((e) => e.type == CallType.incoming).toList();
    } else if (selectedCallType.value == 'Outgoing') {
      result = result.where((e) => e.type == CallType.outgoing).toList();
    } else if (selectedCallType.value == 'Missed') {
      result = result.where((e) => e.type == CallType.missed).toList();
    } else if (selectedCallType.value == 'Rejected') {
      result = result.where((e) => e.type == CallType.rejected || e.type == CallType.neverAttended || e.type == CallType.notPickupByClient).toList();
    }

    filteredLogs.assignAll(result);
    stats.value = CallLogService.calculateStats(filteredLogs);
  }

  String get dateRangeBannerText {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (selectedRange.value == 'Custom' && customStartDate.value != null && customEndDate.value != null) {
      final start = customStartDate.value!;
      final end = customEndDate.value!;
      return '${start.day}-${months[start.month - 1]}-${start.year} 12:00 AM - ${end.day}-${months[end.month - 1]}-${end.year} 11:59 PM';
    }
    final logs = filteredLogs;
    if (logs.isEmpty) return 'No records found for selected filter';
    final timestamps = logs.map((e) => e.timestamp).toList()..sort();
    final first = timestamps.first;
    final last = timestamps.last;
    return '${first.day}-${months[first.month - 1]}-${first.year} 12:00 AM - ${last.day}-${months[last.month - 1]}-${last.year} 11:59 PM';
  }

  // Card 1: Top Caller
  AnalyticsCardData get topCallerCard {
    if (filteredLogs.isEmpty) {
      return AnalyticsCardData(
        title: 'Top Caller',
        contactName: 'No Calls',
        phoneNumber: '',
        metricText: '0 Calls',
        icon: Icons.person_rounded,
        imageAsset: 'assets/images/top_caller_3d.png',
        accentColor: const Color(0xFF3B82F6),
      );
    }
    final statsVal = stats.value;
    final resolvedName = CallLogService.resolveContactName(statsVal.topCallerNumber, defaultName: statsVal.topCallerName);
    return AnalyticsCardData(
      title: 'Top Caller',
      contactName: resolvedName,
      phoneNumber: statsVal.topCallerNumber,
      metricText: '${statsVal.topCallerCount} Calls',
      icon: Icons.person_rounded,
      imageAsset: 'assets/images/top_caller_3d.png',
      accentColor: const Color(0xFF3B82F6),
    );
  }

  // Card 2: Longest Call
  CallLogItem? get longestCallItem {
    if (filteredLogs.isEmpty) return null;
    return filteredLogs.reduce((curr, next) => curr.durationInSeconds > next.durationInSeconds ? curr : next);
  }

  AnalyticsCardData get longestCallCard {
    final item = longestCallItem;
    if (item == null) {
      return AnalyticsCardData(
        title: 'Longest Call',
        contactName: 'No Calls',
        phoneNumber: '',
        metricText: '0h 0m 0s',
        icon: Icons.timer_rounded,
        imageAsset: 'assets/images/longest_call_3d.png',
        accentColor: const Color(0xFF10B981),
      );
    }
    final resolvedName = CallLogService.resolveContactName(item.number, defaultName: item.name);
    return AnalyticsCardData(
      title: 'Longest Call',
      contactName: resolvedName,
      phoneNumber: item.number,
      metricText: _formatDuration(item.durationInSeconds),
      icon: Icons.timer_rounded,
      imageAsset: 'assets/images/longest_call_3d.png',
      accentColor: const Color(0xFF10B981),
    );
  }

  // Card 3: Highest Total Duration
  AnalyticsCardData get highestTotalDurationCard {
    if (filteredLogs.isEmpty) {
      return AnalyticsCardData(
        title: 'Highest Total Duration',
        contactName: 'No Calls',
        phoneNumber: '',
        metricText: '0h 0m 0s',
        icon: Icons.donut_large_rounded,
        imageAsset: 'assets/images/highest_duration_3d.png',
        accentColor: const Color(0xFFF59E0B),
      );
    }
    final Map<String, int> durations = {};
    final Map<String, String> numbers = {};
    for (var log in filteredLogs) {
      durations[log.name] = (durations[log.name] ?? 0) + log.durationInSeconds;
      numbers[log.name] = log.number;
    }
    String topName = filteredLogs.first.name;
    int maxDur = 0;
    durations.forEach((name, dur) {
      if (dur > maxDur) {
        maxDur = dur;
        topName = name;
      }
    });
    final topNumber = numbers[topName] ?? '';
    final resolvedName = CallLogService.resolveContactName(topNumber, defaultName: topName);
    return AnalyticsCardData(
      title: 'Highest Total Duration',
      contactName: resolvedName,
      phoneNumber: topNumber,
      metricText: _formatDuration(maxDur),
      icon: Icons.donut_large_rounded,
      imageAsset: 'assets/images/highest_duration_3d.png',
      accentColor: const Color(0xFFF59E0B),
    );
  }

  // Card 4: Average Call Duration
  AnalyticsCardData get avgCallDurationCard {
    final logs = filteredLogs;
    if (logs.isEmpty) {
      return AnalyticsCardData(
        title: 'Avg. Call Duration',
        contactName: '0h 0m 0s / call',
        phoneNumber: '0h 0m 0s / day',
        metricText: 'Connected Calls',
        icon: Icons.bar_chart_rounded,
        imageAsset: 'assets/images/avg_duration_3d.png',
        accentColor: const Color(0xFF8B5CF6),
      );
    }
    int totalSec = logs.fold(0, (sum, e) => sum + e.durationInSeconds);
    int connCount = logs.where((e) => e.durationInSeconds > 0).length;
    int avgSec = connCount > 0 ? totalSec ~/ connCount : 0;
    int daysCount = logs.map((e) => '${e.timestamp.year}-${e.timestamp.month}-${e.timestamp.day}').toSet().length;
    int avgPerDay = daysCount > 0 ? totalSec ~/ daysCount : 0;

    return AnalyticsCardData(
      title: 'Avg. Call Duration',
      contactName: '${_formatDuration(avgSec)} / call',
      phoneNumber: '${_formatDuration(avgPerDay)} / day',
      metricText: 'Connected Calls',
      icon: Icons.bar_chart_rounded,
      imageAsset: 'assets/images/avg_duration_3d.png',
      accentColor: const Color(0xFF8B5CF6),
    );
  }

  // Card 5: Top 10 Frequently Talked
  AnalyticsCardData get topFrequentlyTalkedCard {
    if (filteredLogs.isEmpty) {
      return AnalyticsCardData(
        title: 'Top Talked Contact',
        contactName: 'No Calls',
        phoneNumber: '',
        metricText: '0 Calls',
        icon: Icons.groups_rounded,
        imageAsset: 'assets/images/top_talked_3d.png',
        accentColor: const Color(0xFFEC4899),
      );
    }
    final statsVal = stats.value;
    final resolvedName = CallLogService.resolveContactName(statsVal.topCallerNumber, defaultName: statsVal.topCallerName);
    return AnalyticsCardData(
      title: 'Top Talked Contact',
      contactName: resolvedName,
      phoneNumber: statsVal.topCallerNumber,
      metricText: '${statsVal.topCallerCount} Total Calls',
      icon: Icons.groups_rounded,
      imageAsset: 'assets/images/top_talked_3d.png',
      accentColor: const Color(0xFFEC4899),
    );
  }

  // Card 6: Top 10 Call Duration
  AnalyticsCardData get topCallDurationCard {
    final highest = highestTotalDurationCard;
    return AnalyticsCardData(
      title: 'Top Duration Contact',
      contactName: highest.contactName,
      phoneNumber: highest.phoneNumber,
      metricText: highest.metricText,
      icon: Icons.access_time_filled_rounded,
      imageAsset: 'assets/images/top_duration_3d.png',
      accentColor: const Color(0xFF06B6D4),
    );
  }

  /// Helper to resolve target CallLogItem for any card tap
  CallLogItem? getLogItemForCard(AnalyticsCardData card) {
    if (filteredLogs.isEmpty) return null;
    final numStr = card.phoneNumber.isNotEmpty ? card.phoneNumber : card.contactName;
    final cleanTarget = numStr.replaceAll(RegExp(r'[^0-9]'), '');
    final last10 = cleanTarget.length >= 10 ? cleanTarget.substring(cleanTarget.length - 10) : cleanTarget;

    final matched = filteredLogs.firstWhere(
      (e) {
        final cleanE = e.number.replaceAll(RegExp(r'[^0-9]'), '');
        final last10E = cleanE.length >= 10 ? cleanE.substring(cleanE.length - 10) : cleanE;
        return (last10.isNotEmpty && last10E == last10) || e.name == card.contactName || e.number == card.phoneNumber;
      },
      orElse: () => filteredLogs.first,
    );

    return CallLogItem(
      id: matched.id,
      name: card.contactName.isNotEmpty ? card.contactName : matched.name,
      number: matched.number,
      type: matched.type,
      timestamp: matched.timestamp,
      durationInSeconds: matched.durationInSeconds,
      tag: matched.tag,
      note: matched.note,
    );
  }

  static String _formatDuration(int seconds) {
    int h = seconds ~/ 3600;
    int m = (seconds % 3600) ~/ 60;
    int s = seconds % 60;
    return '${h}h ${m}m ${s}s';
  }
}
