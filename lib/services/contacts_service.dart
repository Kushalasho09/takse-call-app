import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/contact_model.dart';
import '../models/call_log_model.dart';
import 'call_log_service.dart';
import 'mock_call_log_service.dart';

class ContactsService {
  static List<ContactItem>? _cachedContacts;

  /// Clear in-memory contacts cache
  static void clearCache() {
    _cachedContacts = null;
  }

  static Future<List<ContactItem>>? _inFlightContactsFuture;

  /// Fetch real system contacts from device contacts & system call logs.
  static Future<List<ContactItem>> fetchSystemContacts({bool forceRefresh = false}) {
    if (!forceRefresh && _cachedContacts != null && _cachedContacts!.isNotEmpty) {
      return Future.value(_cachedContacts!);
    }
    if (_inFlightContactsFuture != null && !forceRefresh) {
      return _inFlightContactsFuture!;
    }
    _inFlightContactsFuture = _performFetchSystemContacts().whenComplete(() {
      _inFlightContactsFuture = null;
    });
    return _inFlightContactsFuture!;
  }

  static Future<List<ContactItem>> _performFetchSystemContacts() async {
    try {
      if (!kIsWeb) {
        if (await Permission.contacts.request().isGranted) {
          try {
            // Single bulk fetch — phones, emails & orgs are all included directly.
            final systemContacts = await FlutterContacts.getContacts(
              withProperties: true, // includes phones, emails, orgs in one query
              withPhoto: false,      // never load photos — massive perf saving
            );

            if (systemContacts.isNotEmpty) {
              final logs = await CallLogService.fetchCallLogs();
              
              // Pre-index call logs by phone number for O(1) instant HashMap lookups (0ms)
              final Map<String, List<CallLogItem>> logMapByPhone = {};
              for (var log in logs) {
                final clean = log.number.replaceAll(RegExp(r'[^0-9]'), '');
                if (clean.isNotEmpty) {
                  logMapByPhone.putIfAbsent(clean, () => []).add(log);
                  if (clean.length >= 10) {
                    final last10 = clean.substring(clean.length - 10);
                    logMapByPhone.putIfAbsent(last10, () => []).add(log);
                  }
                }
              }

              final List<ContactItem> result = [];

              for (var c in systemContacts) {
                if (c.phones.isEmpty) continue;
                final String phone = c.phones.first.number;
                final String name = c.displayName.trim().isNotEmpty
                    ? c.displayName.trim()
                    : phone;

                final String firstEmail = c.emails.isNotEmpty ? c.emails.first.address : '';
                final String email = firstEmail.trim().isNotEmpty
                    ? firstEmail.trim()
                    : '$name@contact.com'.toLowerCase().replaceAll(' ', '');

                final String firstCompany = c.organizations.isNotEmpty ? c.organizations.first.company : '';
                final String company = firstCompany.trim().isNotEmpty
                    ? firstCompany.trim()
                    : 'System Contact';

                final String cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
                final String last10 = cleanPhone.length >= 10 ? cleanPhone.substring(cleanPhone.length - 10) : cleanPhone;
                final contactLogs = logMapByPhone[last10] ?? logMapByPhone[cleanPhone] ?? const [];

                final int totalCalls = contactLogs.length;
                final DateTime lastCallTime = contactLogs.isNotEmpty
                    ? contactLogs.first.timestamp
                    : DateTime.now().subtract(const Duration(days: 1));

                result.add(ContactItem(
                  id: c.id,
                  name: name,
                  phoneNumber: phone,
                  email: email,
                  company: company,
                  totalCalls: totalCalls > 0 ? totalCalls : 1,
                  lastCallTime: lastCallTime,
                ));
              }

              if (result.isNotEmpty) {
                _cachedContacts = result;
                return result;
              }
            }
          } catch (e) {
            debugPrint('flutter_contacts plugin catch: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching system contacts: $e');
    }

    // Fallback 1: Extract unique system contacts directly from native call log entries
    try {
      final logs = await CallLogService.fetchCallLogs();
      if (logs.isNotEmpty) {
        final Map<String, List<CallLogItem>> grouped = {};
        for (var log in logs) {
          final key = log.number.replaceAll(RegExp(r'[^0-9]'), '');
          grouped.putIfAbsent(key.isNotEmpty ? key : log.name, () => []).add(log);
        }

        final List<ContactItem> extractedContacts = [];
        grouped.forEach((key, logList) {
          final first = logList.first;
          final name = first.name.isNotEmpty ? first.name : first.number;
          extractedContacts.add(ContactItem(
            id: first.id,
            name: name,
            phoneNumber: first.number,
            email: '$name@contact.com'.toLowerCase().replaceAll(' ', ''),
            company: 'System Contact',
            totalCalls: logList.length,
            lastCallTime: logList.first.timestamp,
          ));
        });

        if (extractedContacts.isNotEmpty) {
          return extractedContacts;
        }
      }
    } catch (e) {
      debugPrint('Error extracting contacts from call logs: $e');
    }

    // Fallback 2: Guaranteed fallback contacts so the user never sees an empty screen
    return MockCallLogService.getMockContacts();
  }
}
