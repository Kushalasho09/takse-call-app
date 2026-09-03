import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class AutomationService {
  static const MethodChannel _automationChannel = MethodChannel('com.callyzer.app/automation');
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String defaultBaseUrl = 'https://automate.takse.in/api/v2/whatsapp-business/messages';
  static const String defaultPhoneId = '1191025657429236';
  static const String defaultToken = '104805ee6609f510973f6c20997a3a715d5b750386459085cfc14a24064937d2';

  static Future<Map<String, dynamic>> loadAutomationPrefs() async {
    try {
      final Map<dynamic, dynamic>? prefs =
          await _automationChannel.invokeMethod('getAutomationPrefs');
      if (prefs != null) {
        return Map<String, dynamic>.from(prefs);
      }
    } catch (e) {
      debugPrint('Error loading native automation prefs: $e');
    }
    return {
      'auto_response_enabled': true,
      'send_sms_enabled': true,
      'sms_message': 'Sorry, I am busy right now. I will call you back shortly.',
      'send_whatsapp_enabled': true,
      'whatsapp_base_url': defaultBaseUrl,
      'whatsapp_access_token': defaultToken,
      'whatsapp_phone_number_id': defaultPhoneId,
      'whatsapp_template_name': '',
      'whatsapp_custom_text': 'Sorry, I missed your call. Will get back to you soon.',
    };
  }

  static Future<bool> saveAutomationPrefs({
    required bool autoResponseEnabled,
    required bool sendSmsEnabled,
    required String smsMessage,
    required bool sendWhatsappEnabled,
    required String whatsappBaseUrl,
    required String whatsappAccessToken,
    required String whatsappPhoneNumberId,
    required String whatsappTemplateName,
    required String whatsappCustomText,
  }) async {
    try {
      final payload = {
        'auto_response_enabled': autoResponseEnabled,
        'send_sms_enabled': sendSmsEnabled,
        'sms_message': smsMessage,
        'send_whatsapp_enabled': sendWhatsappEnabled,
        'whatsapp_base_url': whatsappBaseUrl,
        'whatsapp_access_token': whatsappAccessToken,
        'whatsapp_phone_number_id': whatsappPhoneNumberId,
        'whatsapp_template_name': whatsappTemplateName,
        'whatsapp_custom_text': whatsappCustomText,
      };

      // 1. Sync to Native Android SharedPreferences for background BroadcastReceiver
      await _automationChannel.invokeMethod('updateAutomationPrefs', payload);

      // 2. Sync to Firebase Firestore for cloud backing
      await _firestore.collection('settings').doc('call_automation').set(
        {
          ...payload,
          'updated_at': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      return true;
    } catch (e) {
      debugPrint('Error saving automation prefs: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> testWhatsAppApi({
    required String baseUrl,
    required String recipientPhone,
    required String phoneNumberId,
    required String accessToken,
    required String templateName,
    required String customText,
  }) async {
    try {
      var formattedNo = recipientPhone.replaceAll(RegExp(r'[^0-9]'), '');
      if (formattedNo.length == 10) {
        formattedNo = '91$formattedNo';
      }

      final String targetUrlStr = baseUrl.contains('graph.facebook.com')
          ? 'https://graph.facebook.com/v18.0/$phoneNumberId/messages'
          : (baseUrl.isEmpty ? defaultBaseUrl : baseUrl);

      final url = Uri.parse(targetUrlStr);
      final Map<String, dynamic> body = {
        'phone_number_id': phoneNumberId,
        'phone_id': phoneNumberId,
        'messaging_product': 'whatsapp',
        'to': formattedNo,
      };

      if (templateName.trim().isNotEmpty) {
        body['type'] = 'template';
        body['template'] = {
          'name': templateName.trim(),
          'language': {'code': 'en_US'},
        };
      } else {
        body['type'] = 'text';
        body['text'] = {'body': customText.trim()};
      }

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${accessToken.trim()}',
          'x-api-key': accessToken.trim(),
          'api-key': accessToken.trim(),
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Success! WhatsApp test message sent to +$formattedNo.',
        };
      } else {
        try {
          final respBody = jsonDecode(response.body);
          final errMsg = respBody['error']?['message'] ?? respBody['message'] ?? response.body;
          return {
            'success': false,
            'message': 'WhatsApp API Error [${response.statusCode}]: $errMsg',
          };
        } catch (_) {
          return {
            'success': false,
            'message': 'WhatsApp API Response [${response.statusCode}]: ${response.body}',
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to connect to WhatsApp API: $e',
      };
    }
  }

  static Future<Map<Permission, PermissionStatus>> requestRequiredPermissions() async {
    final statuses = await [
      Permission.phone,
      Permission.sms,
    ].request();

    return statuses;
  }
}
