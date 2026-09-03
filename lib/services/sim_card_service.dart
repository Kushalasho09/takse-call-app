import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/sim_card_model.dart';
import 'prefs_service.dart';

class SimCardService {
  static const MethodChannel _channel = MethodChannel('com.callyzer.app/sim_info');

  /// Check whether a SIM card is installed on the device.
  static Future<bool> isSimInstalled() async {
    return PrefsService.isSimCardInstalled;
  }

  /// Detect actual available SIM cards directly from device SubscriptionManager.
  static Future<List<SimCardInfo>> getAvailableSimCards() async {
    final bool hasSim = await isSimInstalled();
    if (!hasSim) return [];

    final List<SimCardInfo> resultSims = [
      const SimCardInfo(
        id: 'all',
        name: 'All SIMs',
        carrierName: 'All Networks',
      ),
    ];

    try {
      if (!kIsWeb && Platform.isAndroid) {
        final List<dynamic>? rawSims = await _channel.invokeMethod<List<dynamic>>('getSimCards');
        if (rawSims != null && rawSims.isNotEmpty) {
          for (var item in rawSims) {
            if (item is Map) {
              final int slotIndex = (item['simSlotIndex'] as int? ?? 0);
              final String simId = '${slotIndex + 1}'; // '1' or '2'
              final String rawDisplayName = (item['displayName'] as String?)?.trim() ?? '';
              final String rawCarrierName = (item['carrierName'] as String?)?.trim() ?? '';
              final String? phoneNumber = (item['number'] as String?)?.trim();

              final String carrier = rawCarrierName.isNotEmpty
                  ? rawCarrierName
                  : (rawDisplayName.isNotEmpty ? rawDisplayName : 'SIM $simId');

              final String name = rawDisplayName.isNotEmpty
                  ? (rawDisplayName.startsWith('SIM') ? rawDisplayName : 'SIM $simId ($rawDisplayName)')
                  : 'SIM $simId';

              resultSims.add(
                SimCardInfo(
                  id: simId,
                  name: name,
                  carrierName: carrier,
                  phoneNumber: (phoneNumber != null && phoneNumber.isNotEmpty) ? phoneNumber : null,
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching native SIM cards via MethodChannel: $e');
    }

    // Fallback default list if no active physical SIM cards returned by Platform Channel
    if (resultSims.length == 1) {
      resultSims.add(
        const SimCardInfo(id: '1', name: 'SIM 1', carrierName: 'Primary SIM'),
      );
    }

    return resultSims;
  }
}
