import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/call_log_model.dart';
import 'call_log_service.dart';
import 'prefs_service.dart';
import 'session_manager.dart';

class SyncProgressState {
  final int totalOnDevice;
  final int syncedToCloud;
  final int pendingToSync;
  final bool isSyncing;
  final double progress; // 0.0 to 1.0
  final String statusMessage;
  final DateTime? lastSyncTime;
  final int newCallsDetected;

  const SyncProgressState({
    this.totalOnDevice = 0,
    this.syncedToCloud = 0,
    this.pendingToSync = 0,
    this.isSyncing = false,
    this.progress = 0.0,
    this.statusMessage = 'Checking sync status...',
    this.lastSyncTime,
    this.newCallsDetected = 0,
  });

  SyncProgressState copyWith({
    int? totalOnDevice,
    int? syncedToCloud,
    int? pendingToSync,
    bool? isSyncing,
    double? progress,
    String? statusMessage,
    DateTime? lastSyncTime,
    int? newCallsDetected,
  }) {
    return SyncProgressState(
      totalOnDevice: totalOnDevice ?? this.totalOnDevice,
      syncedToCloud: syncedToCloud ?? this.syncedToCloud,
      pendingToSync: pendingToSync ?? this.pendingToSync,
      isSyncing: isSyncing ?? this.isSyncing,
      progress: progress ?? this.progress,
      statusMessage: statusMessage ?? this.statusMessage,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      newCallsDetected: newCallsDetected ?? this.newCallsDetected,
    );
  }
}

class CloudSyncService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static bool _isSyncing = false;

  /// Live observable sync state for UI components
  static final ValueNotifier<SyncProgressState> state = ValueNotifier(const SyncProgressState());

  static bool get isSyncing => _isSyncing;

  /// Check current count of calls on device vs in Firestore cloud
  static Future<SyncProgressState> checkSyncStatus({bool forceRefresh = false}) async {
    try {
      final user = SessionManager.currentUser;
      final connectCode = user?.connectCode.isNotEmpty == true 
          ? user!.connectCode 
          : PrefsService.connectCode;

      final logs = await CallLogService.fetchCallLogsInBackground(forceRefresh: forceRefresh);
      final totalLocal = logs.length;

      int cloudCount = 0;
      DateTime? lastSync;

      if (connectCode.isNotEmpty) {
        final clean = connectCode.replaceAll('-', '');
        final codes = {connectCode, clean}.toList();

        // 1. Fetch exact cloud count
        try {
          final countSnap = await _firestore
              .collection('call_logs')
              .where('connectCode', whereIn: codes)
              .count()
              .get();
          cloudCount = countSnap.count ?? 0;
        } catch (_) {
          final snap = await _firestore
              .collection('call_logs')
              .where('connectCode', whereIn: codes)
              .get();
          cloudCount = snap.docs.length;
        }

        // 2. Fetch last sync timestamp and device record
        try {
          final phone = user?.phone ?? PrefsService.userPhone;
          final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
          final deviceDocId = cleanPhone.isNotEmpty ? '${connectCode}_$cleanPhone' : connectCode;
          final devDoc = await _firestore.collection('devices').doc(deviceDocId).get();
          if (devDoc.exists && devDoc.data()?['lastSyncAt'] is Timestamp) {
            lastSync = (devDoc.data()!['lastSyncAt'] as Timestamp).toDate();
          }
        } catch (_) {}
      }

      final pending = totalLocal > cloudCount ? (totalLocal - cloudCount) : 0;
      final newCalls = pending > 0 ? pending : 0;

      String msg = 'All $totalLocal calls synced';
      if (pending > 0) {
        msg = '$pending calls waiting to sync';
      } else if (totalLocal == 0) {
        msg = 'No calls found on device';
      }

      final newState = SyncProgressState(
        totalOnDevice: totalLocal,
        syncedToCloud: cloudCount,
        pendingToSync: pending,
        isSyncing: _isSyncing,
        progress: totalLocal == 0 ? 1.0 : (cloudCount / totalLocal).clamp(0.0, 1.0),
        statusMessage: msg,
        lastSyncTime: lastSync ?? DateTime.now(),
        newCallsDetected: newCalls,
      );

      state.value = newState;
      return newState;
    } catch (e) {
      debugPrint('checkSyncStatus error: $e');
      return state.value;
    }
  }

  /// Synchronizes call logs from local mobile storage to Firebase Firestore
  static Future<int> syncCallLogsToCloud({List<CallLogItem>? providedLogs}) async {
    if (_isSyncing) return 0;
    _isSyncing = true;

    try {
      final user = SessionManager.currentUser;
      final connectCode = user?.connectCode.isNotEmpty == true 
          ? user!.connectCode 
          : PrefsService.connectCode;

      if (connectCode.isEmpty) {
        debugPrint('⚠️ [CloudSync] Cannot sync: Device Connect Code is missing');
        _isSyncing = false;
        return 0;
      }

      final userName = user?.name.isNotEmpty == true ? user!.name : 'Mobile Agent';
      final userPhone = user?.phone.isNotEmpty == true ? user!.phone : PrefsService.userPhone;
      final company = user?.companyName.isNotEmpty == true ? user!.companyName : PrefsService.companyName;

      // 1. Fetch latest call logs from device if not provided
      final allLogs = providedLogs ?? await CallLogService.fetchCallLogsInBackground();
      
      // Strict Work SIM Filtering: Only sync calls that occurred on the designated official company SIM.
      // Calls from any Personal SIM are strictly excluded and never uploaded.
      final logs = CallLogService.filterLogsByWorkSim(allLogs);
      
      if (logs.isEmpty) {
        debugPrint('⚠️ [CloudSync] No local call logs matching Work SIM (slot: ${PrefsService.workSimSlot}). Personal calls ignored.');
        _isSyncing = false;
        return 0;
      }

      state.value = state.value.copyWith(
        isSyncing: true,
        totalOnDevice: logs.length,
        statusMessage: 'Preparing to sync ${logs.length} work calls...',
      );

      debugPrint('🚀 [CloudSync] Uploading ${logs.length} official work calls (SIM slot: ${PrefsService.workSimSlot}) for: $connectCode ($userName)...');

      // 2. Batch write to Firestore in chunks of 400 (Firestore max is 500 per batch)
      const int chunkSize = 400;
      final now = FieldValue.serverTimestamp();
      int totalCommitted = 0;
      final totalBatches = (logs.length / chunkSize).ceil();

      for (int i = 0; i < logs.length; i += chunkSize) {
        final batchIndex = (i ~/ chunkSize) + 1;
        final chunk = logs.skip(i).take(chunkSize).toList();
        final batch = _firestore.batch();

        state.value = state.value.copyWith(
          statusMessage: 'Syncing batch $batchIndex of $totalBatches ($totalCommitted / ${logs.length} uploaded)...',
          progress: logs.isEmpty ? 1.0 : (totalCommitted / logs.length),
        );

        for (var log in chunk) {
          final cleanNumber = log.number.replaceAll(RegExp(r'[^0-9]'), '');
          final docId = '${connectCode}_${log.timestamp.millisecondsSinceEpoch}_$cleanNumber';
          final docRef = _firestore.collection('call_logs').doc(docId);

          batch.set(docRef, {
            'id': docId,
            'connectCode': connectCode,
            'employeeName': userName,
            'employeePhone': userPhone,
            'companyName': company,
            'name': log.name.isNotEmpty ? log.name : log.number,
            'number': log.number,
            'type': log.type.name, // incoming, outgoing, missed, rejected, etc.
            'duration': log.durationInSeconds,
            'timestamp': log.timestamp.millisecondsSinceEpoch,
            'date': log.timestamp.toIso8601String(),
            'simSlot': 'SIM ${log.simId}',
            'tag': log.tag.name,
            'note': log.note,
            'syncedAt': now,
          }, SetOptions(merge: true));
        }

        await batch.commit();
        totalCommitted += chunk.length;

        state.value = state.value.copyWith(
          syncedToCloud: totalCommitted,
          pendingToSync: logs.length > totalCommitted ? (logs.length - totalCommitted) : 0,
          progress: (totalCommitted / logs.length).clamp(0.0, 1.0),
          statusMessage: 'Uploaded $totalCommitted of ${logs.length} calls...',
        );

        debugPrint('📦 [CloudSync] Committed batch $batchIndex of $totalBatches: $totalCommitted / ${logs.length} logs uploaded');
      }

      // 3. Update device document status in Firestore
      final cleanPhone = userPhone.replaceAll(RegExp(r'[^0-9]'), '');
      final deviceDocId = cleanPhone.isNotEmpty ? '${connectCode}_$cleanPhone' : connectCode;
      final deviceRef = _firestore.collection('devices').doc(deviceDocId);
      await deviceRef.set({
        'connectCode': connectCode,
        'userName': userName,
        'userPhone': userPhone,
        'companyName': company,
        'status': 'active',
        'deviceModel': 'Android Phone (Live Synced)',
        'workSimSlot': PrefsService.workSimSlot,
        'workSimName': PrefsService.workSimName,
        'workSimCarrier': PrefsService.workSimCarrier,
        'lastSyncAt': now,
        'totalCallsCount': logs.length,
        'syncedCallsCount': logs.length,
        'pendingCallsCount': 0,
        'lastCallTimestamp': logs.first.timestamp.millisecondsSinceEpoch,
      }, SetOptions(merge: true));

      final nowTime = DateTime.now();
      state.value = state.value.copyWith(
        isSyncing: false,
        syncedToCloud: totalCommitted,
        pendingToSync: 0,
        progress: 1.0,
        newCallsDetected: 0,
        statusMessage: 'All $totalCommitted calls synced successfully! 🎉',
        lastSyncTime: nowTime,
      );

      debugPrint('✅ [CloudSync] Successfully synced all $totalCommitted call logs to cloud for $connectCode!');
      _isSyncing = false;
      return totalCommitted;
    } catch (e) {
      debugPrint('❌ [CloudSync] Error syncing call logs to Firestore: $e');
      state.value = state.value.copyWith(
        isSyncing: false,
        statusMessage: 'Sync error: $e',
      );
      _isSyncing = false;
      return 0;
    }
  }
}
