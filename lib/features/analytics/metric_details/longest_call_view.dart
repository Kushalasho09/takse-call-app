import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/call_log_model.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/filter_bottom_sheets.dart';
import '../../routes/app_pages.dart';
import '../analytics_controller.dart';

class LongestCallView extends StatelessWidget {
  const LongestCallView({super.key});

  String _formatDuration(int seconds) {
    int h = seconds ~/ 3600;
    int m = (seconds % 3600) ~/ 60;
    int s = seconds % 60;
    return '${h}h ${m}m ${s}s';
  }

  String _formatTime(DateTime dt) {
    int hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    String minute = dt.minute.toString().padLeft(2, '0');
    String period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
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
          'Longest Call',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
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

              // Main Contact & Call Info Card (Tapping opens CallDetailsView)
              GetBuilder<AnalyticsController>(
                init: Get.put(AnalyticsController()),
                builder: (analyticsCtrl) {
                  return Obx(() {
                    final item = analyticsCtrl.longestCallItem;
                    if (item == null) {
                      return Container(
                        padding: const EdgeInsets.all(24),
                        alignment: Alignment.center,
                        child: const Text('No call logs available', style: TextStyle(color: Color(0xFF94A3B8))),
                      );
                    }

                    final initial = item.name.isNotEmpty ? item.name[0].toUpperCase() : 'C';
                    final dateStr = '${item.timestamp.day} ${_monthName(item.timestamp.month)} ${item.timestamp.year}';
                    final timeStr = _formatTime(item.timestamp);
                    final typeStr = item.type == CallType.incoming
                        ? 'Incoming'
                        : item.type == CallType.outgoing
                            ? 'Outgoing'
                            : 'Missed';
                    final durStr = _formatDuration(item.durationInSeconds);

                    return GestureDetector(
                      onTap: () {
                        Get.toNamed(
                          AppRoutes.callDetails,
                          arguments: item,
                        );
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF212330),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF2B2D3C), width: 1),
                        ),
                        child: Column(
                          children: [
                            // Centered Large Initial Avatar
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: const Color(0xFF8C909F),
                              child: Text(
                                initial,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Centered Name Title
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: -0.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            const Divider(color: Color(0xFF2B2D3C), height: 1),
                            const SizedBox(height: 18),

                            // Phone Number Row
                            _buildDetailRow(
                              icon: Icons.phone_android_outlined,
                              iconColor: const Color(0xFF3897F0),
                              label: 'Phone Number',
                              valueWidget: Text(
                                item.number,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Date Row
                            _buildDetailRow(
                              icon: Icons.calendar_today_outlined,
                              iconColor: const Color(0xFF3897F0),
                              label: 'Date',
                              valueWidget: Text(
                                dateStr,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Call Time Row
                            _buildDetailRow(
                              icon: Icons.timer_outlined,
                              iconColor: const Color(0xFFCBD5E1),
                              label: 'Call Time',
                              valueWidget: Text(
                                timeStr,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Call Type Row
                            _buildDetailRow(
                              icon: item.type == CallType.incoming
                                  ? Icons.call_received_rounded
                                  : item.type == CallType.outgoing
                                      ? Icons.call_made_rounded
                                      : Icons.call_missed_rounded,
                              iconColor: item.type == CallType.incoming
                                  ? const Color(0xFFA3E635)
                                  : item.type == CallType.outgoing
                                      ? const Color(0xFFF59E0B)
                                      : const Color(0xFFEF4444),
                              label: 'Call Type',
                              valueWidget: Row(
                                children: [
                                  Text(
                                    typeStr,
                                    style: const TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: Colors.white70, width: 1),
                                    ),
                                    child: const Text(
                                      '1',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Total Duration Row
                            _buildDetailRow(
                              icon: Icons.pie_chart_outline_rounded,
                              iconColor: const Color(0xFF3897F0),
                              label: 'Total Duration',
                              valueWidget: Text(
                                durStr,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required Widget valueWidget,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: iconColor,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14.5,
                color: Color(0xFFCBD5E1),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        valueWidget,
      ],
    );
  }
}
