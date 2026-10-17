import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/sim_card_model.dart';
import '../../services/cloud_sync_service.dart';
import '../../services/prefs_service.dart';
import '../../services/session_manager.dart';
import '../../services/sim_card_service.dart';
import '../routes/app_pages.dart';

class WorkSimSelectionController extends GetxController {
  final isLoading = false.obs;
  final isSaving = false.obs;
  final availableSims = <SimCardInfo>[].obs;
  final selectedSimId = '1'.obs;
  final isInitialSetup = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Check if launched as initial setup or from settings
    if (Get.arguments != null && Get.arguments['fromSettings'] == true) {
      isInitialSetup.value = false;
    }
    loadSimCards();
  }

  Future<void> loadSimCards() async {
    isLoading.value = true;
    try {
      final physicalSims = await SimCardService.getPhysicalSimCardsOnly();
      availableSims.assignAll(physicalSims);

      // Default selection from saved preferences or first SIM
      final savedSlot = PrefsService.workSimSlot;
      if (savedSlot.isNotEmpty && physicalSims.any((s) => s.id == savedSlot)) {
        selectedSimId.value = savedSlot;
      } else if (physicalSims.isNotEmpty) {
        selectedSimId.value = physicalSims.first.id;
      }
    } catch (e) {
      debugPrint('Error loading SIM cards: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void selectSim(String id) {
    selectedSimId.value = id;
  }

  Future<void> confirmWorkSim() async {
    isSaving.value = true;
    try {
      final chosen = availableSims.firstWhere(
        (s) => s.id == selectedSimId.value,
        orElse: () => SimCardInfo(
          id: selectedSimId.value,
          name: 'SIM ${selectedSimId.value}',
          carrierName: 'Carrier Network',
        ),
      );

      // 1. Save to local preferences
      await PrefsService.setWorkSim(
        slot: chosen.id,
        name: chosen.name,
        carrier: chosen.carrierName,
      );

      // Also set the global analytics filter default to this work SIM
      await PrefsService.setSelectedSimId(chosen.id);

      // 2. Persist to Firestore device record
      final user = SessionManager.currentUser;
      final connectCode = user?.connectCode.isNotEmpty == true ? user!.connectCode : PrefsService.connectCode;
      final userPhone = user?.phone.isNotEmpty == true ? user!.phone : PrefsService.userPhone;
      final cleanPhone = userPhone.replaceAll(RegExp(r'[^0-9]'), '');
      final deviceDocId = cleanPhone.isNotEmpty ? '${connectCode}_$cleanPhone' : connectCode;

      if (connectCode.isNotEmpty) {
        try {
          await FirebaseFirestore.instance.collection('devices').doc(deviceDocId).set({
            'workSimSlot': chosen.id,
            'workSimName': chosen.name,
            'workSimCarrier': chosen.carrierName,
            'simConfiguredAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } catch (e) {
          debugPrint('Notice saving SIM to Firestore devices: $e');
        }
      }

      // 3. Trigger immediate cloud sync for this work SIM
      CloudSyncService.syncCallLogsToCloud();

      // 4. Feedback Snackbar
      Get.snackbar(
        'Work SIM Configured! 🛡️',
        'Official calls on ${chosen.name} will be tracked. Personal SIM calls remain 100% private.',
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        icon: const Icon(Icons.shield_rounded, color: Colors.white),
        duration: const Duration(seconds: 4),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );

      // 5. Navigate to Dashboard or pop back if from Settings
      if (isInitialSetup.value) {
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        Get.back();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to save SIM selection: $e');
    } finally {
      isSaving.value = false;
    }
  }
}
