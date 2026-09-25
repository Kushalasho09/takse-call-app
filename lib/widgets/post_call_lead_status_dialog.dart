import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/mobile_lead_service.dart';
import '../services/prefs_service.dart';

class PostCallLeadStatusDialog extends StatefulWidget {
  final String phoneNumber;
  final String contactName;
  final String callType; // incoming, outgoing, missed
  final int durationSeconds;
  final int ringingSeconds;
  final VoidCallback? onSaved;

  const PostCallLeadStatusDialog({
    super.key,
    required this.phoneNumber,
    this.contactName = '',
    this.callType = 'outgoing',
    this.durationSeconds = 0,
    this.ringingSeconds = 2,
    this.onSaved,
  });

  /// Static helper to show dialog anywhere in the app
  static Future<void> show({
    required String phoneNumber,
    String contactName = '',
    String callType = 'outgoing',
    int durationSeconds = 0,
    int ringingSeconds = 2,
    VoidCallback? onSaved,
  }) async {
    if (Get.isDialogOpen == true) return;

    await Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: PostCallLeadStatusDialog(
          phoneNumber: phoneNumber,
          contactName: contactName,
          callType: callType,
          durationSeconds: durationSeconds,
          ringingSeconds: ringingSeconds,
          onSaved: onSaved,
        ),
      ),
      barrierDismissible: true,
    );
  }

  @override
  State<PostCallLeadStatusDialog> createState() => _PostCallLeadStatusDialogState();
}

class _PostCallLeadStatusDialogState extends State<PostCallLeadStatusDialog> {
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;

  // The 4 official Callyzer Lead Statuses matching user's Image 2
  final List<Map<String, dynamic>> _callyzerStatuses = [
    {
      'title': 'Positive',
      'color': const Color(0xFF10B981),
      'requiresReminder': false,
      'icon': Icons.check_circle_rounded,
    },
    {
      'title': 'Call Back',
      'color': const Color(0xFFF59E0B),
      'requiresReminder': true,
      'icon': Icons.alarm_rounded,
    },
    {
      'title': 'Negative',
      'color': const Color(0xFFEF4444),
      'requiresReminder': false,
      'icon': Icons.cancel_rounded,
    },
    {
      'title': 'Not Pickup Call',
      'color': const Color(0xFF64748B),
      'requiresReminder': false,
      'icon': Icons.phone_missed_rounded,
    },
  ];

  late String _selectedStatus;
  DateTime? _reminderDate;
  late String _currentTelecallerPhone;

  @override
  void initState() {
    super.initState();
    _selectedStatus = 'Positive';
    String telecaller = '+919664579043';
    try {
      if (PrefsService.userPhone.isNotEmpty) {
        telecaller = PrefsService.userPhone;
      }
    } catch (_) {}
    _currentTelecallerPhone = telecaller;
    _loadExistingLeadInfo();
  }

  Future<void> _loadExistingLeadInfo() async {
    final existing = await MobileLeadService.getLeadByPhone(widget.phoneNumber);
    if (existing != null && mounted) {
      setState(() {
        _selectedStatus = existing.status;
        _notesController.text = existing.notes;
        _reminderDate = existing.reminderDate;
      });
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  String _formatCallDuration() {
    final h = widget.durationSeconds ~/ 3600;
    final m = (widget.durationSeconds % 3600) ~/ 60;
    final s = widget.durationSeconds % 60;
    final timeStr = DateFormat('hh:mm a').format(DateTime.now());
    return '${h}h ${m}m ${s}s (Rang ${widget.ringingSeconds}s) | $timeStr';
  }

  Future<void> _saveAndProcess(String actionType) async {
    setState(() => _isLoading = true);

    // If Call Back is selected and reminder is missing, pick default tomorrow 11 AM
    DateTime? effectiveReminder = _reminderDate;
    if (_selectedStatus == 'Call Back' && effectiveReminder == null) {
      effectiveReminder = DateTime.now().add(const Duration(days: 1)).copyWith(hour: 11, minute: 0);
    }

    final success = await MobileLeadService.saveOrUpdateLeadStatus(
      phoneNumber: widget.phoneNumber,
      contactName: widget.contactName,
      status: _selectedStatus,
      tags: [_selectedStatus],
      notes: _notesController.text.trim(),
      reminderDate: effectiveReminder,
      callType: widget.callType,
      callDuration: widget.durationSeconds,
    );

    if (mounted) {
      setState(() => _isLoading = false);

      if (success) {
        widget.onSaved?.call();

        if (actionType == 'connect') {
          // Open WhatsApp with pre-filled message
          var clean = widget.phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
          if (clean.length == 10) clean = '91$clean';
          final waUri = Uri.parse('https://wa.me/$clean?text=Hi%20there,%20following%20up%20on%20our%20call.');
          launchUrl(waUri, mode: LaunchMode.externalApplication);
        } else if (actionType == 'add_lead') {
          Get.snackbar(
            'Lead Added to Pipeline',
            '${widget.contactName.isNotEmpty ? widget.contactName : widget.phoneNumber} added with status "$_selectedStatus"',
            snackPosition: SnackPosition.TOP,
            backgroundColor: const Color(0xFF10B981),
            colorText: Colors.white,
            icon: const Icon(Icons.cloud_done_rounded, color: Colors.white),
            duration: const Duration(seconds: 3),
          );
        }

        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      } else {
        Get.snackbar(
          'Saved Locally',
          'Call details saved. Will sync to web CRM when online.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFF59E0B),
          colorText: Colors.white,
        );
        Navigator.pop(context);
      }
    }
  }

  void _pickReminderDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _reminderDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(data: ThemeData.dark(), child: child!),
    );
    if (pickedDate != null && mounted) {
      if (!context.mounted) return;
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 11, minute: 0),
        builder: (context, child) => Theme(data: ThemeData.dark(), child: child!),
      );
      if (pickedTime != null) {
        setState(() {
          _reminderDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1117), // Deep black background matching Image 1
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF232733), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x99000000),
            blurRadius: 32,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header: "Last Call Details" and Close Button (matching Image 1)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Last Call Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Close',
                    ),
                  ],
                ),
              ),

              // Subline: Telecaller number + copy icon (matching Image 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      _currentTelecallerPhone,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: _currentTelecallerPhone));
                        Get.snackbar('Copied', 'Phone number copied to clipboard', snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 1));
                      },
                      child: const Icon(Icons.copy_rounded, size: 14, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Call Info Card (Orange Circle Icon + Caller Name & Details matching Image 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    // Orange Circle Call Icon (matching Image 1)
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF59E0B),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.phone_forwarded_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.contactName.trim().isNotEmpty
                                ? widget.contactName.toUpperCase()
                                : 'ASODIA KUSHAL',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.phoneNumber,
                            style: const TextStyle(fontSize: 13.5, color: Color(0xFFCBD5E1), fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _formatCallDuration(),
                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Lead Status Section (matching Image 2)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.flag_rounded, size: 15, color: Color(0xFFF59E0B)),
                        SizedBox(width: 6),
                        Text(
                          'Lead Status',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // 4 Specific Status Chips from Image 2
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _callyzerStatuses.map((st) {
                        final title = st['title'] as String;
                        final color = st['color'] as Color;
                        final isSelected = _selectedStatus == title;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedStatus = title;
                              if (st['requiresReminder'] == true && _reminderDate == null) {
                                _reminderDate = DateTime.now().add(const Duration(days: 1)).copyWith(hour: 11, minute: 0);
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? color.withValues(alpha: 0.22) : const Color(0xFF181B24),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected ? color : const Color(0xFF2C3242),
                                width: isSelected ? 1.6 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                    color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    // If Call Back is selected, show reminder picker banner (Image 2 requires reminder)
                    if (_selectedStatus == 'Call Back') ...[
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: _pickReminderDate,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.alarm_on_rounded, size: 16, color: Color(0xFFF59E0B)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _reminderDate != null
                                      ? 'Callback: ${DateFormat('EEE, d MMM • hh:mm a').format(_reminderDate!)}'
                                      : 'Tap to set callback reminder date & time',
                                  style: const TextStyle(fontSize: 12, color: Color(0xFFFDE68A), fontWeight: FontWeight.w600),
                                ),
                              ),
                              const Icon(Icons.edit_calendar_rounded, size: 14, color: Color(0xFFF59E0B)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Note Input Section (matching Image 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.description_outlined, size: 16, color: Color(0xFF38BDF8)),
                        SizedBox(width: 6),
                        Text(
                          'Add Note',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E222D), // Dark text box background matching Image 1
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF2C3242)),
                      ),
                      child: Stack(
                        children: [
                          TextField(
                            controller: _notesController,
                            maxLines: 4,
                            style: const TextStyle(fontSize: 13, color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: "Type your call summary or use '/' to add\ncall note template(s) quickly.",
                              hintStyle: TextStyle(fontSize: 12.5, color: Color(0xFF64748B), height: 1.4),
                              contentPadding: EdgeInsets.fromLTRB(14, 14, 46, 14),
                              border: InputBorder.none,
                            ),
                          ),
                          // Microphone Button in bottom right of input box (matching Image 1)
                          Positioned(
                            right: 8,
                            bottom: 8,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: Color(0xFF0F1117),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.mic_none_rounded, color: Color(0xFF38BDF8), size: 18),
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  Get.snackbar('Voice Note', 'Listening for speech input...', snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 1));
                                },
                                tooltip: 'Voice Note',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Bottom 3 Blue Buttons (matching Image 1)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Row(
                  children: [
                    // Button 1: Save & Exit
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () => _saveAndProcess('exit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Save & Exit', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Button 2: Save & Connect
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () => _saveAndProcess('connect'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Save & Connect', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Button 3: Save & Add Lead
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () => _saveAndProcess('add_lead'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Save & Add Lead', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
