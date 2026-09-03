import 'dart:async';
import 'package:call_log/call_log.dart' as cl;
import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/call_log_model.dart';
import '../models/call_stats_model.dart';
import 'mock_call_log_service.dart';
import 'prefs_service.dart';

class CallLogService {
  static final Map<String, String> _notesCache = {};

  /// Save note for a specific call item or number
  static Future<void> saveNote(String callIdOrNumber, String note) async {
    _notesCache[callIdOrNumber] = note;
    await PrefsService.setCallNote(callIdOrNumber, note);
  }

  /// Get note for a specific call item or number
  static String? getNote(String callIdOrNumber) {
    return _notesCache[callIdOrNumber] ?? PrefsService.getCallNote(callIdOrNumber);
  }

  /// Request permissions for reading call logs
  static Future<bool> requestCallLogPermission() async {
    if (kIsWeb) return false;
    final status = await Permission.phone.request();
    if (status.isGranted) {
      await PrefsService.setCallLogPermissionGranted(true);
      return true;
    }
    return false;
  }

  static List<CallLogItem>? _cachedLogs;

  /// Clear in-memory call log cache
  static void clearCache() {
    _cachedLogs = null;
    _contactNameCache = null;
  }

  /// Fetch all call logs asynchronously in background without blocking the UI main thread
  static Future<List<CallLogItem>> fetchCallLogsInBackground({bool forceRefresh = false}) async {
    // Yield to the Flutter event loop to allow initial frame rendering
    await Future.microtask(() {});
    return fetchCallLogs(forceRefresh: forceRefresh);
  }

  static Map<String, String>? _contactNameCache;

  /// Resolve phone number to contact display name using system contacts cache
  static String resolveContactName(String number, {String? defaultName}) {
    if (_contactNameCache == null || _contactNameCache!.isEmpty) {
      return defaultName ?? number;
    }
    final clean = number.replaceAll(RegExp(r'[^0-9]'), '');
    final last10 = clean.length >= 10 ? clean.substring(clean.length - 10) : clean;
    if (_contactNameCache!.containsKey(last10)) {
      return _contactNameCache![last10]!;
    } else if (_contactNameCache!.containsKey(clean)) {
      return _contactNameCache![clean]!;
    }
    return defaultName ?? number;
  }

  /// Build cache map of clean phone numbers & 10-digit keys to system contact display names.
  /// Uses a single bulk fetch (withProperties: true) to eliminate the N+1 query problem.
  /// Previously: getAll() [summary only] + get(id) per contact = N+1 DB hits → 5-15 min.
  /// Now: getContacts(withProperties: true) = 1 DB hit → 2-4 sec.
  static Future<Map<String, String>> _getContactNameMap() async {
    if (_contactNameCache != null && _contactNameCache!.isNotEmpty) {
      return _contactNameCache!;
    }
    final sw = Stopwatch()..start();
    final Map<String, String> map = {};
    try {
      if (!kIsWeb) {
        var status = await Permission.contacts.status;
        if (!status.isGranted) {
          status = await Permission.contacts.request();
        }
        if (status.isGranted) {
          debugPrint('⏱️ [BENCHMARK] Starting FlutterContacts.getContacts()...');
          final contacts = await FlutterContacts.getContacts(
            withProperties: true,
            withPhoto: false,
          );
          debugPrint('⏱️ [BENCHMARK] FlutterContacts.getContacts() returned ${contacts.length} contacts in ${sw.elapsedMilliseconds} ms');
          for (var c in contacts) {
            if (c.displayName.trim().isNotEmpty) {
              final name = c.displayName.trim();
              for (var p in c.phones) {
                final clean = p.number.replaceAll(RegExp(r'[^0-9]'), '');
                if (clean.isNotEmpty) {
                  map[clean] = name;
                  if (clean.length >= 10) {
                    final last10 = clean.substring(clean.length - 10);
                    map[last10] = name;
                  }
                }
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error mapping contacts: $e');
    }
    if (map.isNotEmpty) {
      _contactNameCache = map;
    }
    debugPrint('⏱️ [BENCHMARK] Contact name map built with ${map.length} mappings in ${sw.elapsedMilliseconds} ms total');
    return map;
  }

  static Future<List<CallLogItem>>? _inFlightCallLogsFuture;

  /// Fetch all call logs from device or fallback to mock data.
  /// Uses in-flight Future deduplication so simultaneous startup calls share 1 native query.
  /// Phase 1: Returns call logs immediately with native entry names (~1 sec).
  /// Phase 2: Resolves contact display names asynchronously in background.
  static Future<List<CallLogItem>> fetchCallLogs({bool forceRefresh = false}) {
    if (!forceRefresh && _cachedLogs != null && _cachedLogs!.isNotEmpty) {
      debugPrint('⏱️ [BENCHMARK] Returning ${_cachedLogs!.length} call logs from in-memory cache (0 ms)');
      return Future.value(_cachedLogs!);
    }
    if (_inFlightCallLogsFuture != null && !forceRefresh) {
      debugPrint('⏱️ [BENCHMARK] Reusing in-flight fetchCallLogs() Future...');
      return _inFlightCallLogsFuture!;
    }
    _inFlightCallLogsFuture = _performFetchCallLogs().whenComplete(() {
      _inFlightCallLogsFuture = null;
    });
    return _inFlightCallLogsFuture!;
  }

  static Future<List<CallLogItem>> _performFetchCallLogs() async {
    final totalSw = Stopwatch()..start();
    debugPrint('⏱️ [BENCHMARK] Starting _performFetchCallLogs()...');
    try {
      if (!kIsWeb) {
        bool hasPermission = await Permission.phone.isGranted;
        if (!hasPermission) {
          final status = await Permission.phone.request();
          hasPermission = status.isGranted;
        }

        final clSw = Stopwatch()..start();
        debugPrint('⏱️ [BENCHMARK] Querying cl.CallLog.get()...');
        final Iterable<cl.CallLogEntry> entries = await cl.CallLog.get();
        debugPrint('⏱️ [BENCHMARK] cl.CallLog.get() returned ${entries.length} raw entries in ${clSw.elapsedMilliseconds} ms');
        
        if (entries.isNotEmpty) {
          final List<CallLogItem> logs = [];
          int index = 0;
          final parseSw = Stopwatch()..start();
          for (var entry in entries) {
            final String numStr = entry.number ?? 'Unknown';
            final String nameStr = (entry.name != null && entry.name!.trim().isNotEmpty)
                ? entry.name!.trim()
                : numStr;

            final DateTime time = entry.timestamp != null
                ? DateTime.fromMillisecondsSinceEpoch(entry.timestamp!)
                : DateTime.now();
            final int duration = entry.duration ?? 0;
            final String id = 'log_${entry.timestamp ?? index}_$index';

            CallType type = CallType.incoming;
            switch (entry.callType) {
              case cl.CallType.incoming:
                type = CallType.incoming;
                break;
              case cl.CallType.outgoing:
                if (duration == 0) {
                  type = CallType.notPickupByClient;
                } else {
                  type = CallType.outgoing;
                }
                break;
              case cl.CallType.missed:
                type = CallType.missed;
                break;
              case cl.CallType.rejected:
                type = CallType.rejected;
                break;
              case cl.CallType.blocked:
                type = CallType.neverAttended;
                break;
              default:
                type = duration > 0 ? CallType.incoming : CallType.missed;
                break;
            }

            final savedNote = getNote(id) ?? getNote(numStr);

            String simId = '1';
            final phoneAccountId = (entry.phoneAccountId ?? '').toLowerCase();
            final simDisplayName = (entry.simDisplayName ?? '').toLowerCase();
            if (phoneAccountId.contains('sim2') ||
                phoneAccountId.contains('sub2') ||
                phoneAccountId.contains('slot1') ||
                simDisplayName.contains('sim 2') ||
                simDisplayName.contains('sim2')) {
              simId = '2';
            } else {
              simId = '1';
            }

            logs.add(CallLogItem(
              id: id,
              name: nameStr,
              number: numStr,
              type: type,
              timestamp: time,
              durationInSeconds: duration,
              simId: simId,
              tag: _guessTagForContact(nameStr, numStr),
              note: savedNote ?? 'Tap here to add notes',
            ));
            index++;
          }
          debugPrint('⏱️ [BENCHMARK] Parsed ${logs.length} call log items in ${parseSw.elapsedMilliseconds} ms');
          _cachedLogs = logs;
          debugPrint('🚀 [BENCHMARK] Fast Call Logs Phase 1 ready in ${totalSw.elapsedMilliseconds} ms!');

          // Phase 2: Enrich contact names asynchronously in background without blocking UI
          _enrichContactNamesInBackground(logs);

          return logs;
        }
      }
    } catch (e) {
      debugPrint('Error reading real call logs: $e');
    }
    // Fallback to mock call logs if on Web, iOS, or if permission denied/empty
    return MockCallLogService.getMockCallLogs();
  }

  /// Asynchronously resolves contact display names from system contacts in background
  static void _enrichContactNamesInBackground(List<CallLogItem> logs) {
    Future.microtask(() async {
      try {
        final Map<String, String> contactNameMap = await _getContactNameMap();
        if (contactNameMap.isEmpty) return;

        bool updated = false;
        for (int i = 0; i < logs.length; i++) {
          final item = logs[i];
          final String numStr = item.number;
          final String cleanNum = numStr.replaceAll(RegExp(r'[^0-9]'), '');
          final String last10 = cleanNum.length >= 10 ? cleanNum.substring(cleanNum.length - 10) : cleanNum;

          if (item.name == numStr || item.name.replaceAll(RegExp(r'[^0-9]'), '') == cleanNum) {
            String? resolved;
            if (contactNameMap.containsKey(last10)) {
              resolved = contactNameMap[last10];
            } else if (contactNameMap.containsKey(cleanNum)) {
              resolved = contactNameMap[cleanNum];
            }
            if (resolved != null && resolved.isNotEmpty && resolved != item.name) {
              logs[i] = CallLogItem(
                id: item.id,
                name: resolved,
                number: item.number,
                type: item.type,
                timestamp: item.timestamp,
                durationInSeconds: item.durationInSeconds,
                simId: item.simId,
                tag: _guessTagForContact(resolved, item.number),
                note: item.note,
              );
              updated = true;
            }
          }
        }
        if (updated) {
          _cachedLogs = logs;
          debugPrint('✨ [BENCHMARK] Contact names enriched asynchronously in background!');
        }
      } catch (e) {
        debugPrint('Error enriching contact names: $e');
      }
    });
  }

  /// Get historical call logs for a specific phone number or contact item.
  /// Never falls back to returning all logs if not found.
  static Future<List<CallLogItem>> getLogsForContact(CallLogItem targetItem, List<CallLogItem> currentAllLogs) async {
    final String numStr = targetItem.number;
    final String cleanNum = numStr.replaceAll(RegExp(r'[^0-9]'), '');
    final String last10 = cleanNum.length >= 10 ? cleanNum.substring(cleanNum.length - 10) : cleanNum;
    final String nameLower = targetItem.name.trim().toLowerCase();

    final filtered = currentAllLogs.where((item) {
      final String itemClean = item.number.replaceAll(RegExp(r'[^0-9]'), '');
      final String itemLast10 = itemClean.length >= 10 ? itemClean.substring(itemClean.length - 10) : itemClean;

      // 1. Match by last 10 digits
      if (last10.isNotEmpty && itemLast10.isNotEmpty && last10 == itemLast10) {
        return true;
      }
      // 2. Match by clean number endsWith
      if (cleanNum.isNotEmpty && itemClean.isNotEmpty && (cleanNum.endsWith(itemClean) || itemClean.endsWith(cleanNum))) {
        return true;
      }
      // 3. Match by contact display name (if valid and not equal to raw number)
      if (nameLower.isNotEmpty && nameLower != cleanNum && item.name.trim().toLowerCase() == nameLower) {
        return true;
      }
      return false;
    }).toList();

    if (filtered.isNotEmpty) {
      return filtered;
    }
    return [targetItem];
  }

  /// Legacy helper for string phone numbers
  static Future<List<CallLogItem>> getLogsForNumber(String number, List<CallLogItem> currentAllLogs) async {
    final dummy = CallLogItem(
      id: '0',
      name: number,
      number: number,
      type: CallType.incoming,
      timestamp: DateTime.now(),
      durationInSeconds: 0,
    );
    return getLogsForContact(dummy, currentAllLogs);
  }

  /// Calculate summary stats dynamically from call log list
  static CallStatsModel calculateStats(List<CallLogItem> logs) {
    if (logs.isEmpty) return CallStatsModel.empty();

    int incomingCount = 0;
    int outgoingCount = 0;
    int missedCount = 0;
    int rejectedCount = 0;
    int neverAttendedCount = 0;
    int notPickupByClientCount = 0;
    int totalSecs = 0;
    int incSecs = 0;
    int outSecs = 0;

    final Set<String> uniqueNumbers = {};
    final Map<String, int> callerCounts = {};

    for (var log in logs) {
      totalSecs += log.durationInSeconds;
      callerCounts[log.name] = (callerCounts[log.name] ?? 0) + 1;

      final clean = log.number.replaceAll(RegExp(r'[^0-9]'), '');
      if (clean.isNotEmpty) {
        final key = clean.length >= 10 ? clean.substring(clean.length - 10) : clean;
        uniqueNumbers.add(key);
      }

      switch (log.type) {
        case CallType.incoming:
          incomingCount++;
          incSecs += log.durationInSeconds;
          break;
        case CallType.outgoing:
          outgoingCount++;
          outSecs += log.durationInSeconds;
          break;
        case CallType.missed:
          missedCount++;
          break;
        case CallType.rejected:
          rejectedCount++;
          break;
        case CallType.neverAttended:
          neverAttendedCount++;
          break;
        case CallType.notPickupByClient:
          notPickupByClientCount++;
          break;
      }
    }

    String topCallerName = logs.first.name;
    String topCallerNumber = logs.first.number;
    int topCount = 0;

    callerCounts.forEach((name, count) {
      if (count > topCount) {
        topCount = count;
        topCallerName = name;
        final matched = logs.firstWhere((element) => element.name == name, orElse: () => logs.first);
        topCallerNumber = matched.number;
      }
    });

    return CallStatsModel(
      totalCalls: logs.length,
      incomingCount: incomingCount,
      outgoingCount: outgoingCount,
      missedCount: missedCount,
      rejectedCount: rejectedCount,
      neverAttendedCount: neverAttendedCount,
      notPickupByClientCount: notPickupByClientCount,
      uniqueCallsCount: uniqueNumbers.isNotEmpty ? uniqueNumbers.length : logs.length,
      totalDurationSeconds: totalSecs,
      incomingDurationSeconds: incSecs,
      outgoingDurationSeconds: outSecs,
      topCallerName: topCallerName,
      topCallerNumber: topCallerNumber,
      topCallerCount: topCount,
    );
  }

  static CallTag _guessTagForContact(String name, String number) {
    final lower = name.toLowerCase();
    if (lower.contains('work') || lower.contains('office') || lower.contains('flutter') || lower.contains('client')) {
      return CallTag.work;
    } else if (lower.contains('spam') || lower.contains('telemarketer')) {
      return CallTag.spam;
    } else if (lower.contains('bhabhi') || lower.contains('fua') || lower.contains('family') || lower.contains('home')) {
      return CallTag.personal;
    }
    return CallTag.work;
  }
}
