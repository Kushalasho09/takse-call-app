import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/automation_service.dart';

class AutomationSettingsView extends StatefulWidget {
  const AutomationSettingsView({super.key});

  @override
  State<AutomationSettingsView> createState() => _AutomationSettingsViewState();
}

class _AutomationSettingsViewState extends State<AutomationSettingsView> {
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isTestingWa = false;

  bool _autoResponseEnabled = true;
  bool _sendSmsEnabled = true;
  bool _sendWhatsappEnabled = true;

  final TextEditingController _smsMessageCtrl = TextEditingController();
  final TextEditingController _waBaseUrlCtrl = TextEditingController(text: AutomationService.defaultBaseUrl);
  final TextEditingController _waTokenCtrl = TextEditingController(text: AutomationService.defaultToken);
  final TextEditingController _waPhoneIdCtrl = TextEditingController(text: AutomationService.defaultPhoneId);
  final TextEditingController _waTemplateCtrl = TextEditingController();
  final TextEditingController _waTextCtrl = TextEditingController();
  final TextEditingController _testPhoneCtrl = TextEditingController(text: '9664579043');

  String? _testStatusMessage;
  bool? _testSuccess;

  bool _phonePermissionGranted = false;
  bool _smsPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _checkPermissions();
  }

  Future<void> _loadSettings() async {
    final prefs = await AutomationService.loadAutomationPrefs();
    setState(() {
      _autoResponseEnabled = prefs['auto_response_enabled'] ?? true;
      _sendSmsEnabled = prefs['send_sms_enabled'] ?? true;
      _sendWhatsappEnabled = prefs['send_whatsapp_enabled'] ?? true;

      _smsMessageCtrl.text = prefs['sms_message'] ?? 'Sorry, I am busy right now. I will call you back shortly.';
      _waBaseUrlCtrl.text = (prefs['whatsapp_base_url']?.toString().isNotEmpty == true)
          ? prefs['whatsapp_base_url']
          : AutomationService.defaultBaseUrl;
      _waTokenCtrl.text = (prefs['whatsapp_access_token']?.toString().isNotEmpty == true)
          ? prefs['whatsapp_access_token']
          : AutomationService.defaultToken;
      _waPhoneIdCtrl.text = (prefs['whatsapp_phone_number_id']?.toString().isNotEmpty == true)
          ? prefs['whatsapp_phone_number_id']
          : AutomationService.defaultPhoneId;
      _waTemplateCtrl.text = prefs['whatsapp_template_name'] ?? '';
      _waTextCtrl.text = prefs['whatsapp_custom_text'] ?? 'Sorry, I missed your call. Will get back to you soon.';

      _isLoading = false;
    });
  }

  Future<void> _checkPermissions() async {
    final phoneStatus = await Permission.phone.status;
    final smsStatus = await Permission.sms.status;

    setState(() {
      _phonePermissionGranted = phoneStatus.isGranted;
      _smsPermissionGranted = smsStatus.isGranted;
    });
  }

  Future<void> _requestPermissions() async {
    final statuses = await AutomationService.requestRequiredPermissions();
    setState(() {
      _phonePermissionGranted = statuses[Permission.phone]?.isGranted ?? false;
      _smsPermissionGranted = statuses[Permission.sms]?.isGranted ?? false;
    });
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isSaving = true;
    });

    final success = await AutomationService.saveAutomationPrefs(
      autoResponseEnabled: _autoResponseEnabled,
      sendSmsEnabled: _sendSmsEnabled,
      smsMessage: _smsMessageCtrl.text.trim(),
      sendWhatsappEnabled: _sendWhatsappEnabled,
      whatsappBaseUrl: _waBaseUrlCtrl.text.trim(),
      whatsappAccessToken: _waTokenCtrl.text.trim(),
      whatsappPhoneNumberId: _waPhoneIdCtrl.text.trim(),
      whatsappTemplateName: _waTemplateCtrl.text.trim(),
      whatsappCustomText: _waTextCtrl.text.trim(),
    );

    setState(() {
      _isSaving = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Automation settings saved successfully!' : 'Failed to save settings.',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _testWhatsApp() async {
    if (_testPhoneCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a test recipient phone number.')),
      );
      return;
    }

    if (_waPhoneIdCtrl.text.trim().isEmpty || _waTokenCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your WhatsApp Phone Number ID and Access Token.')),
      );
      return;
    }

    setState(() {
      _isTestingWa = true;
      _testStatusMessage = null;
      _testSuccess = null;
    });

    final res = await AutomationService.testWhatsAppApi(
      baseUrl: _waBaseUrlCtrl.text.trim(),
      recipientPhone: _testPhoneCtrl.text.trim(),
      phoneNumberId: _waPhoneIdCtrl.text.trim(),
      accessToken: _waTokenCtrl.text.trim(),
      templateName: _waTemplateCtrl.text.trim(),
      customText: _waTextCtrl.text.trim(),
    );

    setState(() {
      _isTestingWa = false;
      _testSuccess = res['success'] == true;
      _testStatusMessage = res['message'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call-Cut Automation Settings'),
        actions: [
          IconButton(
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveSettings,
            tooltip: 'Save Settings',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Permission Status Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.security, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'Required Permissions',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              _phonePermissionGranted ? Icons.check_circle : Icons.cancel,
                              color: _phonePermissionGranted ? Colors.green : Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text('Phone State & Call Log Permission'),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              _smsPermissionGranted ? Icons.check_circle : Icons.cancel,
                              color: _smsPermissionGranted ? Colors.green : Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text('Direct SMS Permission'),
                          ],
                        ),
                        if (!_phonePermissionGranted || !_smsPermissionGranted) ...[
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _requestPermissions,
                            icon: const Icon(Icons.lock_open),
                            label: const Text('Grant Permissions'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Master Toggle Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: SwitchListTile(
                    title: const Text(
                      'Automated Response on Call Cut',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      'Automatically send SMS and WhatsApp message when you decline an incoming call.',
                    ),
                    value: _autoResponseEnabled,
                    onChanged: (val) {
                      setState(() {
                        _autoResponseEnabled = val;
                      });
                    },
                    secondary: const Icon(Icons.autorenew, color: Colors.indigo),
                  ),
                ),
                const SizedBox(height: 16),

                // SMS Settings Section
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Automated SMS Response',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text('Send direct SMS via SIM card on call decline'),
                          value: _sendSmsEnabled,
                          onChanged: (val) {
                            setState(() {
                              _sendSmsEnabled = val;
                            });
                          },
                          secondary: const Icon(Icons.sms, color: Colors.green),
                        ),
                        if (_sendSmsEnabled) ...[
                          const SizedBox(height: 8),
                          TextField(
                            controller: _smsMessageCtrl,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'SMS Message Body',
                              border: OutlineInputBorder(),
                              hintText: 'Enter text to send via SMS...',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // WhatsApp Business API Settings Section
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Automated WhatsApp Response',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text('Send WhatsApp message via WhatsApp Business API'),
                          value: _sendWhatsappEnabled,
                          onChanged: (val) {
                            setState(() {
                              _sendWhatsappEnabled = val;
                            });
                          },
                          secondary: const Icon(Icons.chat, color: Colors.teal),
                        ),
                        if (_sendWhatsappEnabled) ...[
                          const SizedBox(height: 12),
                          TextField(
                            controller: _waBaseUrlCtrl,
                            decoration: const InputDecoration(
                              labelText: 'API Endpoint Base URL',
                              border: OutlineInputBorder(),
                              hintText: 'e.g. https://automate.takse.in/api/v2/whatsapp-business/messages',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _waPhoneIdCtrl,
                            decoration: const InputDecoration(
                              labelText: 'WhatsApp Phone Number ID',
                              border: OutlineInputBorder(),
                              hintText: 'e.g. 1191025657429236',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _waTokenCtrl,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'WhatsApp API Key / Access Token',
                              border: OutlineInputBorder(),
                              hintText: 'e.g. 104805ee6609...',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _waTemplateCtrl,
                            decoration: const InputDecoration(
                              labelText: 'WhatsApp Template Name (Optional)',
                              border: OutlineInputBorder(),
                              hintText: 'e.g. hello_world (leave empty for custom text)',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _waTextCtrl,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Custom WhatsApp Message Text',
                              border: OutlineInputBorder(),
                              hintText: 'Message text if no template is used...',
                            ),
                          ),
                          const SizedBox(height: 16),

                          const Divider(),
                          const SizedBox(height: 8),
                          const Text(
                            'Test WhatsApp Connection',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _testPhoneCtrl,
                                  keyboardType: TextInputType.phone,
                                  decoration: const InputDecoration(
                                    labelText: 'Test Recipient Mobile No',
                                    border: OutlineInputBorder(),
                                    hintText: 'e.g. 9664579043',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: _isTestingWa ? null : _testWhatsApp,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                ),
                                child: _isTestingWa
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Text('Send Test'),
                              ),
                            ],
                          ),
                          if (_testStatusMessage != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _testSuccess == true
                                    ? Colors.green.withAlpha(25)
                                    : Colors.red.withAlpha(25),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _testSuccess == true ? Colors.green : Colors.red,
                                ),
                              ),
                              child: Text(
                                _testStatusMessage!,
                                style: TextStyle(
                                  color: _testSuccess == true ? Colors.green[800] : Colors.red[800],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveSettings,
                  icon: const Icon(Icons.save),
                  label: const Text(
                    'SAVE AUTOMATION SETTINGS',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
    );
  }
}
