import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'prefs_service.dart';
import 'session_manager.dart';

class MobileLeadModel {
  final String id;
  final String name;
  final String phoneNumber;
  final String status;
  final List<String> tags;
  final String notes;
  final DateTime? reminderDate;
  final String assignedTo;
  final String assignedToPhone;
  final String companyName;
  final String connectCode;
  final DateTime? lastCallTime;
  final String lastCallType;
  final int lastCallDuration;
  final int attempts;
  final bool isTrashed;
  final DateTime updatedAt;

  MobileLeadModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.status,
    this.tags = const [],
    this.notes = '',
    this.reminderDate,
    required this.assignedTo,
    required this.assignedToPhone,
    required this.companyName,
    required this.connectCode,
    this.lastCallTime,
    this.lastCallType = 'outgoing',
    this.lastCallDuration = 0,
    this.attempts = 1,
    this.isTrashed = false,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'status': status,
      'tags': tags,
      'notes': notes,
      'reminderDate': reminderDate?.millisecondsSinceEpoch,
      'assignedTo': assignedTo,
      'assignedToPhone': assignedToPhone,
      'companyName': companyName,
      'connectCode': connectCode,
      'lastCallTime': lastCallTime?.toIso8601String(),
      'lastCallType': lastCallType,
      'lastCallDuration': lastCallDuration,
      'attempts': attempts,
      'isTrashed': isTrashed,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory MobileLeadModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    DateTime? reminder;
    if (data['reminderDate'] is int) {
      reminder = DateTime.fromMillisecondsSinceEpoch(data['reminderDate'] as int);
    } else if (data['reminderDate'] is Timestamp) {
      reminder = (data['reminderDate'] as Timestamp).toDate();
    }

    DateTime? lastCall;
    if (data['lastCallTime'] != null) {
      lastCall = DateTime.tryParse(data['lastCallTime'].toString());
    }

    return MobileLeadModel(
      id: doc.id,
      name: data['name'] ?? data['phoneNumber'] ?? 'Lead',
      phoneNumber: data['phoneNumber'] ?? '',
      status: data['status'] ?? 'New Inflow',
      tags: (data['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      notes: data['notes'] ?? '',
      reminderDate: reminder,
      assignedTo: data['assignedTo'] ?? 'Agent',
      assignedToPhone: data['assignedToPhone'] ?? '',
      companyName: data['companyName'] ?? '',
      connectCode: data['connectCode'] ?? '',
      lastCallTime: lastCall,
      lastCallType: data['lastCallType'] ?? 'outgoing',
      lastCallDuration: data['lastCallDuration'] is int ? data['lastCallDuration'] : 0,
      attempts: data['attempts'] is int ? data['attempts'] : 1,
      isTrashed: data['isTrashed'] == true,
    );
  }
}

class MobileLeadService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Clean phone number to digits only (e.g. 919876543210 -> 9876543210)
  static String normalizePhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 10) {
      return digits.substring(digits.length - 10);
    }
    return digits;
  }

  /// Create a deterministic lead document ID based on normalized 10-digit phone
  static String generateLeadId(String phoneNumber) {
    final clean = normalizePhone(phoneNumber);
    return 'lead_$clean';
  }

  /// Fetch existing lead by phone number, if already recorded in Firestore
  static Future<MobileLeadModel?> getLeadByPhone(String phoneNumber) async {
    try {
      final docId = generateLeadId(phoneNumber);
      final doc = await _firestore.collection('leads').doc(docId).get();
      if (doc.exists) {
        return MobileLeadModel.fromFirestore(doc);
      }
    } catch (e) {
      debugPrint('Error getting lead by phone: $e');
    }
    return null;
  }

  /// Save or update lead status, notes, tags, and call activity directly in Firestore
  static Future<bool> saveOrUpdateLeadStatus({
    required String phoneNumber,
    required String contactName,
    required String status,
    List<String> tags = const [],
    String notes = '',
    DateTime? reminderDate,
    String callType = 'outgoing',
    int callDuration = 0,
  }) async {
    try {
      final user = SessionManager.currentUser;
      final userName = user?.name.isNotEmpty == true ? user!.name : PrefsService.userName;
      final userPhone = user?.phone.isNotEmpty == true ? user!.phone : PrefsService.userPhone;
      final companyName = user?.companyName.isNotEmpty == true ? user!.companyName : PrefsService.companyName;
      final connectCode = user?.connectCode.isNotEmpty == true ? user!.connectCode : PrefsService.connectCode;

      final docId = generateLeadId(phoneNumber);
      final docRef = _firestore.collection('leads').doc(docId);

      // Check if lead already exists to increment attempts
      final existingDoc = await docRef.get();
      int currentAttempts = 1;
      if (existingDoc.exists) {
        final existingAttempts = existingDoc.data()?['attempts'];
        if (existingAttempts is int) {
          currentAttempts = existingAttempts + 1;
        }
      }

      final cleanName = contactName.trim().isNotEmpty ? contactName.trim() : phoneNumber;

      final payload = {
        'id': docId,
        'name': cleanName,
        'phoneNumber': phoneNumber,
        'status': status,
        'tags': tags,
        'notes': notes,
        'reminderDate': reminderDate?.millisecondsSinceEpoch,
        'assignedTo': userName.isNotEmpty ? userName : 'Telecaller',
        'assignedToPhone': userPhone,
        'companyName': companyName,
        'connectCode': connectCode,
        'lastCallTime': DateTime.now().toIso8601String(),
        'lastCallType': callType,
        'lastCallDuration': callDuration,
        'attempts': currentAttempts,
        'isTrashed': false,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await docRef.set(payload, SetOptions(merge: true));

      // Append call history item in sub-collection
      try {
        await docRef.collection('call_activities').add({
          'timestamp': DateTime.now().toIso8601String(),
          'callType': callType,
          'durationSeconds': callDuration,
          'callerName': userName,
          'callerPhone': userPhone,
          'status': status,
          'notes': notes,
        });
      } catch (_) {}

      // Save local note in CallLogService if available
      try {
        await PrefsService.setCallNote(phoneNumber, notes);
      } catch (_) {}

      debugPrint('✅ [MobileLeadService] Lead successfully saved to Firestore: $docId ($status)');
      return true;
    } catch (e) {
      debugPrint('❌ [MobileLeadService] Error saving lead to Firestore: $e');
      return false;
    }
  }

  /// Real-time stream of leads assigned to this employee / organization
  static Stream<List<MobileLeadModel>> streamMyLeads() {
    return _firestore
        .collection('leads')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MobileLeadModel.fromFirestore(doc))
          .where((l) => !l.isTrashed)
          .toList();
    }).handleError((error) {
      debugPrint('⚠️ [MobileLeadService] Stream error (e.g. offline/rules): $error');
      return <MobileLeadModel>[];
    });
  }
}
