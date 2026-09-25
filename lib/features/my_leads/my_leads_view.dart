import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/mobile_lead_service.dart';
import '../../services/post_call_monitor_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/post_call_lead_status_dialog.dart';

class MyLeadsView extends StatefulWidget {
  const MyLeadsView({super.key});

  @override
  State<MyLeadsView> createState() => _MyLeadsViewState();
}

class _MyLeadsViewState extends State<MyLeadsView> {
  String _activeTab = 'all'; // 'due', 'scheduled', 'all'

  Color _getStatusColor(String status) {
    switch (status) {
      case 'New Inflow':
        return const Color(0xFF3B82F6);
      case 'Follow Up':
        return const Color(0xFFF59E0B);
      case 'Contacted':
        return const Color(0xFF6366F1);
      case 'Demo Scheduled':
        return const Color(0xFF06B6D4);
      case 'Quotation Sent':
        return const Color(0xFF8B5CF6);
      case 'Closed - Won':
        return const Color(0xFF10B981);
      case 'Closed - Lost':
        return const Color(0xFFEF4444);
      case 'Not Interested':
      default:
        return const Color(0xFF64748B);
    }
  }

  void _showAddLeadDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    String selectedStatus = 'New Inflow';

    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF151821),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                children: [
                  Icon(Icons.person_add_alt_1_rounded, color: Color(0xFF2563EB), size: 22),
                  SizedBox(width: 8),
                  Text('Add New Lead', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Lead Full Name',
                  labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFF1E2433),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Phone Number (10 digits)',
                  labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  prefixText: '+91 ',
                  prefixStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  filled: true,
                  fillColor: const Color(0xFF1E2433),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Get.back(), child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8)))),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final name = nameCtrl.text.trim();
                      final phone = phoneCtrl.text.trim();
                      if (phone.isEmpty) {
                        Get.snackbar('Validation', 'Please enter a phone number', backgroundColor: const Color(0xFFEF4444), colorText: Colors.white);
                        return;
                      }
                      Get.back();
                      await MobileLeadService.saveOrUpdateLeadStatus(
                        phoneNumber: phone,
                        contactName: name.isNotEmpty ? name : phone,
                        status: selectedStatus,
                        notes: 'Created via mobile app',
                      );
                      Get.snackbar('Success', 'Lead added and synced to cloud!', backgroundColor: const Color(0xFF10B981), colorText: Colors.white);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
                    child: const Text('Save Lead'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        heroTag: 'my_leads_fab',
        onPressed: _showAddLeadDialog,
        backgroundColor: const Color(0xFF2563EB),
        shape: const CircleBorder(),
        elevation: 6,
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<MobileLeadModel>>(
          stream: MobileLeadService.streamMyLeads(),
          builder: (context, snapshot) {
            final allLeads = snapshot.data ?? [];

            final dueLeads = allLeads.where((l) => l.reminderDate != null && l.reminderDate!.isBefore(now)).toList();
            final scheduledLeads = allLeads.where((l) => l.reminderDate != null && l.reminderDate!.isAfter(now)).toList();

            List<MobileLeadModel> displayedLeads;
            switch (_activeTab) {
              case 'due':
                displayedLeads = dueLeads;
                break;
              case 'scheduled':
                displayedLeads = scheduledLeads;
                break;
              case 'all':
              default:
                displayedLeads = allLeads;
                break;
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Header & Refresh Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Leads',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.cloud_done_rounded, size: 14, color: Color(0xFF10B981)),
                            SizedBox(width: 4),
                            Text('Live Cloud', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Sub-Tabs Header (Due (X) | Scheduled (X) | My Leads (X))
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      _buildTabButton('Due (${dueLeads.length})', 'due'),
                      const SizedBox(width: 8),
                      _buildTabButton('Scheduled (${scheduledLeads.length})', 'scheduled'),
                      const SizedBox(width: 8),
                      _buildTabButton('My Leads (${allLeads.length})', 'all'),
                    ],
                  ),
                ),

                // Lead List or Empty State
                Expanded(
                  child: displayedLeads.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.cardBorder, width: 1),
                                ),
                                child: const Icon(
                                  Icons.touch_app_outlined,
                                  size: 44,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _activeTab == 'due'
                                    ? 'No Due Scheduled leads data available'
                                    : (_activeTab == 'scheduled'
                                        ? 'No upcoming scheduled leads'
                                        : 'No leads in pipeline yet.\nTap + to add or make calls to record leads!'),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF94A3B8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                          itemCount: displayedLeads.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final lead = displayedLeads[index];
                            final statusColor = _getStatusColor(lead.status);

                            return InkWell(
                              onTap: () {
                                PostCallLeadStatusDialog.show(
                                  phoneNumber: lead.phoneNumber,
                                  contactName: lead.name,
                                  callType: lead.lastCallType,
                                  durationSeconds: lead.lastCallDuration,
                                );
                              },
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1B1D26),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFF282B3C)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: statusColor.withValues(alpha: 0.2),
                                          child: Text(
                                            lead.name.isNotEmpty ? lead.name[0].toUpperCase() : 'L',
                                            style: TextStyle(fontWeight: FontWeight.bold, color: statusColor, fontSize: 16),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                lead.name,
                                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                lead.phoneNumber,
                                                style: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Status Badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: statusColor.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                                          ),
                                          child: Text(
                                            lead.status,
                                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (lead.notes.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF14161F),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'Note: ${lead.notes}',
                                          style: const TextStyle(fontSize: 12, color: Color(0xFFCBD5E1), fontStyle: FontStyle.italic),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Attempts: ${lead.attempts} • ${lead.lastCallTime != null ? DateFormat('d MMM, hh:mm a').format(lead.lastCallTime!) : 'Never'}',
                                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                        ),
                                        Row(
                                          children: [
                                            // Call button
                                            IconButton(
                                              icon: const Icon(Icons.phone_outlined, size: 20, color: Color(0xFF3B82F6)),
                                              constraints: const BoxConstraints(),
                                              padding: const EdgeInsets.symmetric(horizontal: 6),
                                              onPressed: () {
                                                PostCallMonitorService.markOutgoingCall(lead.phoneNumber);
                                                launchUrl(Uri.parse('tel:${lead.phoneNumber}'), mode: LaunchMode.externalApplication);
                                              },
                                              tooltip: 'Call Lead',
                                            ),
                                            // Update Lead Status button
                                            IconButton(
                                              icon: const Icon(Icons.flag_circle_rounded, size: 20, color: Color(0xFFF59E0B)),
                                              constraints: const BoxConstraints(),
                                              padding: const EdgeInsets.symmetric(horizontal: 6),
                                              onPressed: () {
                                                PostCallLeadStatusDialog.show(
                                                  phoneNumber: lead.phoneNumber,
                                                  contactName: lead.name,
                                                  callType: lead.lastCallType,
                                                  durationSeconds: lead.lastCallDuration,
                                                );
                                              },
                                              tooltip: 'Update Lead Status',
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, String tabKey) {
    final isSelected = _activeTab == tabKey;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _activeTab = tabKey),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1E2638) : const Color(0xFF1B1D26),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.primary : const Color(0xFF282B3C),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12.5,
                color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
