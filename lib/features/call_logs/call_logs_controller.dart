import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/call_log_model.dart';
import '../../services/call_log_service.dart';
import '../../services/cloud_sync_service.dart';
import '../../services/post_call_monitor_service.dart';
import '../../utils/add_contact_bottom_sheet.dart';

import '../../models/sim_card_model.dart';
import '../../services/sim_card_service.dart';
import '../../services/prefs_service.dart';

class CallLogsController extends GetxController with WidgetsBindingObserver {
  final allLogs = <CallLogItem>[].obs;
  final filteredLogs = <CallLogItem>[].obs;
  final displayedLogs = <CallLogItem>[].obs;
  final isLoading = true.obs;
  final hasPermission = true.obs;
  
  final selectedFilter = 'All'.obs;
  final searchQuery = ''.obs;

  final availableSims = <SimCardInfo>[].obs;
  final selectedSim = Rx<SimCardInfo>(
    const SimCardInfo(id: 'all', name: 'All SIMs', carrierName: 'All Networks'),
  );

  final ScrollController scrollController = ScrollController();
  final int pageSize = 20;
  final currentPage = 1.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final hasOverlayPermission = true.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    scrollController.addListener(_onScroll);
    loadSimsAndLogs();
    checkOverlayPermission();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkOverlayPermission();
    }
  }

  Future<void> checkOverlayPermission() async {
    final granted = await PostCallMonitorService.isOverlayPermissionGranted();
    hasOverlayPermission.value = granted;
  }

  Future<void> requestOverlayPermission() async {
    await PostCallMonitorService.requestOverlayPermission();
    await Future.delayed(const Duration(milliseconds: 500));
    await checkOverlayPermission();
  }

  Future<void> loadSimsAndLogs() async {
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
      debugPrint('Error loading SIM cards: $e');
    }
  }

  void changeSim(SimCardInfo sim) {
    selectedSim.value = sim;
    PrefsService.setSelectedSimId(sim.id);
    applyFilter();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.hasClients &&
        scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      loadMoreCallLogs();
    }
  }

  Future<void> loadMoreCallLogs() async {
    if (isLoadingMore.value || !hasMore.value) return;
    isLoadingMore.value = true;
    await Future.delayed(const Duration(milliseconds: 300));
    final nextPageIndex = currentPage.value + 1;
    final startIndex = currentPage.value * pageSize;
    if (startIndex < filteredLogs.length) {
      final endIndex = (startIndex + pageSize < filteredLogs.length)
          ? startIndex + pageSize
          : filteredLogs.length;
      displayedLogs.addAll(filteredLogs.sublist(startIndex, endIndex));
      currentPage.value = nextPageIndex;
    }
    hasMore.value = displayedLogs.length < filteredLogs.length;
    isLoadingMore.value = false;
  }

  void resetPagination() {
    currentPage.value = 1;
    if (filteredLogs.isEmpty) {
      displayedLogs.clear();
      hasMore.value = false;
    } else {
      final end = filteredLogs.length > pageSize ? pageSize : filteredLogs.length;
      displayedLogs.assignAll(filteredLogs.sublist(0, end));
      hasMore.value = displayedLogs.length < filteredLogs.length;
    }
    isLoadingMore.value = false;
  }

  Future<void> checkPermissionAndLoad() async {
    try {
      final status = await Permission.phone.status;
      hasPermission.value = status.isGranted || true; // default granted
    } catch (_) {
      hasPermission.value = true;
    }
    loadCallLogs();
  }

  Future<void> requestCallLogPermission() async {
    try {
      final status = await Permission.phone.request();
      hasPermission.value = status.isGranted || true;
    } catch (_) {
      hasPermission.value = true;
    }
    loadCallLogs();
  }

  Future<void> loadCallLogs({bool showLoader = true}) async {
    if (showLoader) isLoading.value = true;
    final sw = Stopwatch()..start();
    debugPrint('⏱️ [UI BENCHMARK] CallLogsController.loadCallLogs() started at ${DateTime.now()}');
    try {
      final logs = await CallLogService.fetchCallLogsInBackground();
      allLogs.assignAll(logs);
      applyFilter();
      debugPrint('🚀 [UI BENCHMARK] CALL LOGS DISPLAYED ON SCREEN! (${displayedLogs.length} displayed / ${allLogs.length} total) in ${sw.elapsedMilliseconds} ms at ${DateTime.now()}');
      
      // Auto sync mobile calls to Cloud Firestore for live Web Admin Dashboard
      CloudSyncService.syncCallLogsToCloud(providedLogs: logs);

      await Future.delayed(const Duration(milliseconds: 100));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshCallLogs() async {
    await loadCallLogs(showLoader: true);
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    applyFilter();
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    applyFilter();
  }

  void applyFilter() {
    var result = List<CallLogItem>.from(allLogs);

    // Apply SIM filter
    if (selectedSim.value.id != 'all') {
      result = result.where((e) => e.simId == selectedSim.value.id).toList();
    }

    // Apply type filter
    if (selectedFilter.value == 'Incoming') {
      result = result.where((e) => e.type == CallType.incoming).toList();
    } else if (selectedFilter.value == 'Outgoing') {
      result = result.where((e) => e.type == CallType.outgoing).toList();
    } else if (selectedFilter.value == 'Missed') {
      result = result.where((e) => e.type == CallType.missed).toList();
    } else if (selectedFilter.value == 'Rejected') {
      result = result.where((e) => e.type == CallType.rejected).toList();
    } else if (selectedFilter.value == 'Never Attended') {
      result = result.where((e) => e.type == CallType.neverAttended).toList();
    } else if (selectedFilter.value == 'Not Pickup by Client') {
      result = result.where((e) => e.type == CallType.notPickupByClient).toList();
    }

    // Apply search
    if (searchQuery.value.trim().isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      result = result.where((e) => e.name.toLowerCase().contains(q) || e.number.contains(q)).toList();
    }

    filteredLogs.value = result;
    resetPagination();
  }

  Future<void> makePhoneCall(String phone) async {
    PostCallMonitorService.markOutgoingCall(phone);
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

  void openLeadStatusDialog(CallLogItem log) {
    PostCallMonitorService.triggerPostCallDialog(
      phoneNumber: log.number,
      contactName: log.name,
      callType: log.type.name,
      durationSeconds: log.durationInSeconds,
    );
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

  Future<void> addContact(BuildContext context, String name, String phone) async {
    await AddContactBottomSheet.show(context, initialName: name, initialPhone: phone);
  }

  Future<void> copyToClipboard(String phone) async {
    await Clipboard.setData(ClipboardData(text: phone));
    Get.snackbar(
      'Copied',
      'Phone number $phone copied to clipboard!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
}
