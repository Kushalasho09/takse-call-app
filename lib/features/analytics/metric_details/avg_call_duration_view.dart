import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/filter_bottom_sheets.dart';
import '../../../models/call_log_model.dart';
import '../../routes/app_pages.dart';
import '../analytics_controller.dart';

class AvgCallDurationView extends StatelessWidget {
  const AvgCallDurationView({super.key});

  String _formatDuration(int seconds) {
    int h = seconds ~/ 3600;
    int m = (seconds % 3600) ~/ 60;
    int s = seconds % 60;
    return '${h}h ${m}m ${s}s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Average Call Duration of Connected Calls',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Filters Pill Row (Interactive)
              Row(
                children: [
                  // Filter Pill (2) -> Opens FilterByView
                  _buildFilterPill(
                    onTap: () => Get.toNamed(AppRoutes.filterBy),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(
                              Icons.filter_alt_outlined,
                              size: 18,
                              color: Colors.white,
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF2563EB),
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 12,
                                  minHeight: 12,
                                ),
                                child: const Text(
                                  '2',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Filter',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Today Dropdown Pill -> Opens Duration Bottom Sheet
                  _buildFilterPill(
                    onTap: () => FilterBottomSheets.showDurationBottomSheet(context, selected: 'Today'),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Today',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF2563EB),
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Ex. No.:Yes Dropdown Pill -> Opens Call Type Bottom Sheet
                  Expanded(
                    child: _buildFilterPill(
                      onTap: () => FilterBottomSheets.showCallTypeBottomSheet(context),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Ex. No.:Yes',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Color(0xFF2563EB),
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Calendar Range Banner
              Row(
                children: const [
                  Icon(
                    Icons.calendar_today_outlined,
                    color: Color(0xFF2563EB),
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '29-Jul-2026 12:00 AM - 29-Jul-2026 11:59 PM',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Dynamic Call Duration Metrics Cards
              GetBuilder<AnalyticsController>(
                init: Get.put(AnalyticsController()),
                builder: (analyticsCtrl) {
                  return Obx(() {
                    final logs = analyticsCtrl.filteredLogs;
                    final totalSec = logs.fold(0, (sum, e) => sum + e.durationInSeconds);
                    final daysCount = logs.isEmpty ? 1 : logs.map((e) => '${e.timestamp.year}-${e.timestamp.month}-${e.timestamp.day}').toSet().length;
                    final avgPerDaySec = daysCount > 0 ? totalSec ~/ daysCount : 0;

                    final incomingLogs = logs.where((e) => e.type == CallType.incoming).toList();
                    final outgoingLogs = logs.where((e) => e.type == CallType.outgoing).toList();

                    final incomingSec = incomingLogs.fold(0, (sum, e) => sum + e.durationInSeconds);
                    final outgoingSec = outgoingLogs.fold(0, (sum, e) => sum + e.durationInSeconds);

                    final incomingConnCount = incomingLogs.where((e) => e.durationInSeconds > 0).length;
                    final outgoingConnCount = outgoingLogs.where((e) => e.durationInSeconds > 0).length;
                    final totalConnCount = logs.where((e) => e.durationInSeconds > 0).length;

                    final avgIncomingSec = incomingConnCount > 0 ? incomingSec ~/ incomingConnCount : 0;
                    final avgOutgoingSec = outgoingConnCount > 0 ? outgoingSec ~/ outgoingConnCount : 0;
                    final avgTotalSec = totalConnCount > 0 ? totalSec ~/ totalConnCount : 0;

                    return Column(
                      children: [
                        // Card 1: Average Duration per Day of Connected Call
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFF212330),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF2B2D3C), width: 1),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Average Duration per Day\nof Connected Call',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _formatDuration(avgPerDaySec),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              const Divider(color: Color(0xFF2B2D3C), height: 1),
                              const SizedBox(height: 14),

                              _buildSimpleRow('No of Days', '$daysCount'),
                              const SizedBox(height: 12),
                              _buildSimpleRow('Total Duration', _formatDuration(totalSec)),
                              const SizedBox(height: 12),
                              _buildSimpleRow('Avg. Duration', _formatDuration(avgPerDaySec), isBold: true),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Card 2: Average Duration per Call of Connected Call
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFF212330),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF2B2D3C), width: 1),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Average Duration per Call\nof Connected Call',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _formatDuration(avgTotalSec),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              const Divider(color: Color(0xFF2B2D3C), height: 1),
                              const SizedBox(height: 14),

                              // Table Columns Header
                              Row(
                                children: const [
                                  Expanded(child: SizedBox()),
                                  SizedBox(
                                    width: 80,
                                    child: Text(
                                      'No of Calls',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFFCBD5E1),
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: Text(
                                      'Duration',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFFCBD5E1),
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 90,
                                    child: Text(
                                      'Avg.\nDuration',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFFCBD5E1),
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // Incoming Row
                              _buildCallTableRow(
                                icon: Icons.call_received_rounded,
                                iconColor: const Color(0xFFA3E635),
                                title: 'Incoming',
                                titleColor: const Color(0xFFA3E635),
                                calls: '${incomingLogs.length}',
                                duration: _formatDuration(incomingSec),
                                avgDuration: _formatDuration(avgIncomingSec),
                              ),
                              const SizedBox(height: 14),

                              // Outgoing Row
                              _buildCallTableRow(
                                icon: Icons.call_made_rounded,
                                iconColor: const Color(0xFFF59E0B),
                                title: 'Outgoing',
                                titleColor: const Color(0xFFF59E0B),
                                calls: '${outgoingLogs.length}',
                                duration: _formatDuration(outgoingSec),
                                avgDuration: _formatDuration(avgOutgoingSec),
                              ),
                              const SizedBox(height: 16),

                              // Total Calls Row
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Total Calls',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: Text(
                                      '${logs.length}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: Text(
                                      _formatDuration(totalSec),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 90,
                                    child: Text(
                                      _formatDuration(avgTotalSec),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterPill({required Widget child, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1D26),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF2563EB), width: 1.2),
        ),
        child: child,
      ),
    );
  }

  Widget _buildSimpleRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFFCBD5E1),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildCallTableRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Color titleColor,
    required String calls,
    required String duration,
    required String avgDuration,
  }) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: titleColor,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 80,
          child: Text(
            calls,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(
          width: 80,
          child: Text(
            duration,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(
          width: 90,
          child: Text(
            avgDuration,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
