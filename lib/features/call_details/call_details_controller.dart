import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/call_log_model.dart';
import '../../services/call_log_service.dart';
import '../../utils/add_contact_bottom_sheet.dart';
import '../routes/app_pages.dart';

class CallDetailsController extends GetxController {
  late CallLogItem item;
  final allLogs = <CallLogItem>[].obs;
  final activeTab = 'Call History'.obs;
  final isLoading = true.obs;

  // Filter state
  final selectedDuration = 'All Time'.obs;
  final selectedCallType = 'All'.obs;
  final selectedSim = 'All SIMs'.obs;
  final selectedDurationLength = 'All'.obs;
  final selectedContactType = 'All'.obs;
  final selectedCategory = 'Duration'.obs;

  // Temporary state for Filter By screen
  final tempDuration = 'All Time'.obs;
  final tempCallType = 'All'.obs;
  final tempSim = 'All SIMs'.obs;
  final tempDurationLength = 'All'.obs;
  final tempContactType = 'All'.obs;

  final customStartDate = Rx<DateTime?>(null);
  final customEndDate = Rx<DateTime?>(null);
  final tempCustomStartDate = Rx<DateTime?>(null);
  final tempCustomEndDate = Rx<DateTime?>(null);

  final durationOptions = [
    'Today',
    'Yesterday',
    'Week',
    'Month',
    'Custom',
    'All Time',
  ];

  final callTypeOptions = [
    'All',
    'Incoming',
    'Outgoing',
    'Missed',
    'Rejected',
  ];

  final simOptions = [
    'All SIMs',
    'SIM 1',
    'SIM 2',
  ];

  final durationLengthOptions = [
    'All',
    '0 Sec (Unanswered)',
    'Short (< 30s)',
    'Medium (30s - 3m)',
    'Long (> 3m)',
  ];

  final contactTypeOptions = [
    'All',
    'Saved Contacts',
    'Unknown Numbers',
  ];

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is CallLogItem) {
      item = Get.arguments as CallLogItem;
    } else {
      item = CallLogItem(
        id: '1',
        name: 'KUSHAL ASODIA Flutter',
        number: '+919978217711',
        type: CallType.incoming,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        durationInSeconds: 114,
      );
    }
    resetTempFilters();
    loadContactLogs();
  }

  Future<void> loadContactLogs() async {
    isLoading.value = true;
    try {
      final logs = await CallLogService.fetchCallLogs();
      final contactLogs = await CallLogService.getLogsForContact(item, logs);
      allLogs.assignAll(contactLogs.isNotEmpty ? contactLogs : [item]);
    } finally {
      isLoading.value = false;
    }
  }

  int get totalCallsCount => allLogs.length;

  int get totalDurationSeconds {
    return allLogs.fold(0, (sum, log) => sum + log.durationInSeconds);
  }

  int get incomingCount {
    return allLogs.where((log) => log.type == CallType.incoming).length;
  }

  int get outgoingCount {
    return allLogs.where((log) => log.type == CallType.outgoing).length;
  }

  int get missedCount {
    return allLogs.where((log) => log.type == CallType.missed).length;
  }

  int get rejectedCount {
    return allLogs.where((log) => log.type == CallType.rejected || log.type == CallType.neverAttended || log.type == CallType.notPickupByClient).length;
  }

  int get activeFilterCount {
    int count = 0;
    if (selectedDuration.value != 'All Time') count++;
    if (selectedCallType.value != 'All') count++;
    if (selectedSim.value != 'All SIMs') count++;
    if (selectedDurationLength.value != 'All') count++;
    if (selectedContactType.value != 'All') count++;
    return count;
  }

  String get dateRangeText {
    final logs = filteredLogs;
    if (logs.isEmpty) return 'No call records';
    final timestamps = logs.map((e) => e.timestamp).toList()..sort();
    final first = timestamps.first;
    final last = timestamps.last;

    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final firstStr = '${first.day} ${months[first.month - 1]}';
    final lastStr = '${last.day} ${months[last.month - 1]}';

    final days = last.difference(first).inDays + 1;
    if (first.day == last.day && first.month == last.month && first.year == last.year) {
      return '$lastStr (1 Day)';
    }
    return '$firstStr to $lastStr ($days Days)';
  }

  String get lastCallDateText {
    final logs = allLogs;
    if (logs.isEmpty) return '-';
    final timestamps = logs.map((e) => e.timestamp).toList()..sort();
    final last = timestamps.last;
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${last.day} ${months[last.month - 1]} ${last.year}';
  }

  int get avgPerDayDurationSeconds {
    final logs = allLogs;
    if (logs.isEmpty) return 0;
    final daysCount = logs.map((e) => '${e.timestamp.year}-${e.timestamp.month}-${e.timestamp.day}').toSet().length;
    final totalSec = logs.fold(0, (sum, e) => sum + e.durationInSeconds);
    return daysCount > 0 ? totalSec ~/ daysCount : 0;
  }

  int get tempFilterCount {
    int count = 0;
    if (tempDuration.value != 'All Time') count++;
    if (tempCallType.value != 'All') count++;
    if (tempSim.value != 'All SIMs') count++;
    if (tempDurationLength.value != 'All') count++;
    if (tempContactType.value != 'All') count++;
    return count;
  }

  List<CallLogItem> get filteredLogs {
    return allLogs.where((log) {
      // Call type filter
      if (selectedCallType.value == 'Incoming' && log.type != CallType.incoming) return false;
      if (selectedCallType.value == 'Outgoing' && log.type != CallType.outgoing) return false;
      if (selectedCallType.value == 'Missed' && log.type != CallType.missed) return false;
      if (selectedCallType.value == 'Rejected' &&
          log.type != CallType.rejected &&
          log.type != CallType.neverAttended &&
          log.type != CallType.notPickupByClient) {
        return false;
      }

      // SIM filter
      if (selectedSim.value == 'SIM 1' && log.simId != '1') return false;
      if (selectedSim.value == 'SIM 2' && log.simId != '2') return false;

      // Call Duration Length filter
      if (selectedDurationLength.value == '0 Sec (Unanswered)' && log.durationInSeconds != 0) return false;
      if ((selectedDurationLength.value.startsWith('Short')) && (log.durationInSeconds == 0 || log.durationInSeconds >= 30)) return false;
      if ((selectedDurationLength.value.startsWith('Medium')) && (log.durationInSeconds < 30 || log.durationInSeconds > 180)) return false;
      if ((selectedDurationLength.value.startsWith('Long')) && log.durationInSeconds <= 180) return false;

      // Contact Type filter
      final isUnknown = log.name.trim().isEmpty || log.name == log.number;
      if (selectedContactType.value == 'Saved Contacts' && isUnknown) return false;
      if (selectedContactType.value == 'Unknown Numbers' && !isUnknown) return false;

      // Duration filter
      DateTime now = DateTime.now();
      if (selectedDuration.value == 'Today') {
        final start = DateTime(now.year, now.month, now.day, 0, 0, 0);
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        return log.timestamp.isAfter(start.subtract(const Duration(milliseconds: 1))) &&
            log.timestamp.isBefore(end.add(const Duration(milliseconds: 1)));
      } else if (selectedDuration.value == 'Yesterday') {
        DateTime yesterday = now.subtract(const Duration(days: 1));
        final start = DateTime(yesterday.year, yesterday.month, yesterday.day, 0, 0, 0);
        final end = DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59, 999);
        return log.timestamp.isAfter(start.subtract(const Duration(milliseconds: 1))) &&
            log.timestamp.isBefore(end.add(const Duration(milliseconds: 1)));
      } else if (selectedDuration.value == 'Week') {
        DateTime weekAgo = now.subtract(const Duration(days: 6));
        final start = DateTime(weekAgo.year, weekAgo.month, weekAgo.day, 0, 0, 0);
        return log.timestamp.isAfter(start.subtract(const Duration(milliseconds: 1)));
      } else if (selectedDuration.value == 'Month') {
        DateTime monthAgo = now.subtract(const Duration(days: 29));
        final start = DateTime(monthAgo.year, monthAgo.month, monthAgo.day, 0, 0, 0);
        return log.timestamp.isAfter(start.subtract(const Duration(milliseconds: 1)));
      } else if (selectedDuration.value == 'Custom' && customStartDate.value != null && customEndDate.value != null) {
        final start = customStartDate.value!;
        final end = customEndDate.value!;
        return log.timestamp.isAfter(start.subtract(const Duration(milliseconds: 1))) &&
            log.timestamp.isBefore(end.add(const Duration(milliseconds: 1)));
      }
      return true;
    }).toList();
  }

  void setActiveTab(String tabName) {
    activeTab.value = tabName;
  }

  void resetTempFilters() {
    tempDuration.value = selectedDuration.value;
    tempCallType.value = selectedCallType.value;
    tempSim.value = selectedSim.value;
    tempDurationLength.value = selectedDurationLength.value;
    tempContactType.value = selectedContactType.value;
    tempCustomStartDate.value = customStartDate.value;
    tempCustomEndDate.value = customEndDate.value;
  }

  void resetAllFilters() {
    tempDuration.value = 'All Time';
    tempCallType.value = 'All';
    tempSim.value = 'All SIMs';
    tempDurationLength.value = 'All';
    tempContactType.value = 'All';
    tempCustomStartDate.value = null;
    tempCustomEndDate.value = null;
  }

  void applyFilters() {
    selectedDuration.value = tempDuration.value;
    selectedCallType.value = tempCallType.value;
    selectedSim.value = tempSim.value;
    selectedDurationLength.value = tempDurationLength.value;
    selectedContactType.value = tempContactType.value;
    customStartDate.value = tempCustomStartDate.value;
    customEndDate.value = tempCustomEndDate.value;
    Get.back();
  }

  void setCustomRange(DateTime start, DateTime end) {
    tempDuration.value = 'Custom';
    tempCustomStartDate.value = DateTime(start.year, start.month, start.day, 0, 0, 0);
    tempCustomEndDate.value = DateTime(end.year, end.month, end.day, 23, 59, 59, 999);
  }

  void setDurationDirect(String duration) {
    selectedDuration.value = duration;
    tempDuration.value = duration;
  }

  void setCallTypeDirect(String callType) {
    selectedCallType.value = callType;
    tempCallType.value = callType;
  }

  Future<void> addContact(BuildContext context, String name, String phone) async {
    await AddContactBottomSheet.show(context, initialName: name, initialPhone: phone);
  }

  void openAddNote(CallLogItem logItem) async {
    final result = await Get.toNamed(AppRoutes.addNote, arguments: logItem);
    if (result != null && result is String) {
      logItem.note = result.trim().isNotEmpty ? result.trim() : null;
      await CallLogService.saveNote(logItem.id, result);
      await CallLogService.saveNote(logItem.number, result);
      allLogs.refresh();
    }
  }

  Future<void> makePhoneCall(String phone) async {
    final Uri uri = Uri.parse('tel:$phone');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      Get.snackbar(
        'Phone Call',
        'Dialing $phone...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF2563EB),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> openWhatsApp(String phone) async {
    String cleanNumber = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanNumber.length == 10) {
      cleanNumber = '91$cleanNumber';
    } else if (cleanNumber.startsWith('0') && cleanNumber.length == 11) {
      cleanNumber = '91${cleanNumber.substring(1)}';
    }

    final Uri uri = Uri.parse('https://wa.me/$cleanNumber');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      Get.snackbar(
        'WhatsApp',
        'Opening WhatsApp chat for +$cleanNumber...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF25D366),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> sendSms(String phone) async {
    final Uri uri = Uri.parse('sms:$phone');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      Get.snackbar(
        'SMS',
        'Opening messaging app for $phone...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF3B82F6),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }
}
