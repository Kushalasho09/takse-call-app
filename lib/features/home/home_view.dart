import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/call_log_model.dart';
import '../../utils/animated_loader.dart';
import '../../utils/app_theme.dart';
import '../../utils/date_formatter.dart';
import '../routes/app_pages.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.phone_in_talk, color: AppColors.primary, size: 24),
            SizedBox(width: 8),
            Text('Task Call Overview'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shield_outlined),
            tooltip: 'Permissions',
            onPressed: () => Get.toNamed(AppRoutes.permissions),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: Obx(
        () {
          if (controller.isLoading.value) {
            return const Center(
              child: AppAnimatedPulseLoader(loadingText: 'Loading overview...'),
            );
          }

          final s = controller.stats.value;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Call Stats Cards
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Call Duration Today',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        DateFormatter.formatDuration(s.totalDurationSeconds),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _statMetric('Total Calls', '${s.totalCalls}'),
                          _statMetric('Incoming', '${s.incomingCount}'),
                          _statMetric('Outgoing', '${s.outgoingCount}'),
                          _statMetric('Missed', '${s.missedCount}'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Call Type Breakdowns
                const Text(
                  'Call Breakdown',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _breakdownCard(
                        'Incoming',
                        DateFormatter.formatDuration(s.incomingDurationSeconds),
                        '${s.incomingCount} calls',
                        AppColors.incomingCall,
                        Icons.call_received_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _breakdownCard(
                        'Outgoing',
                        DateFormatter.formatDuration(s.outgoingDurationSeconds),
                        '${s.outgoingCount} calls',
                        AppColors.outgoingCall,
                        Icons.call_made_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Top Caller Spotlight
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.accent.withValues(alpha: 0.15),
                          radius: 24,
                          child: const Icon(Icons.star_rounded, color: AppColors.accent, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Top Connected Contact',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              ),
                              Text(
                                s.topCallerName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                s.topCallerNumber,
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.accentLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${s.topCallerCount} Calls',
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Recent Calls Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Activity',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed(AppRoutes.callLogs),
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...controller.recentCalls.map((call) => _recentCallTile(call)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _breakdownCard(String title, String duration, String subtitle, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 6),
                Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 10),
            Text(duration, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _recentCallTile(CallLogItem call) {
    IconData icon;
    Color iconColor;
    switch (call.type) {
      case CallType.incoming:
        icon = Icons.call_received_rounded;
        iconColor = AppColors.incomingCall;
        break;
      case CallType.outgoing:
        icon = Icons.call_made_rounded;
        iconColor = AppColors.outgoingCall;
        break;
      case CallType.missed:
        icon = Icons.call_missed_rounded;
        iconColor = AppColors.missedCall;
        break;
      case CallType.rejected:
        icon = Icons.block_rounded;
        iconColor = AppColors.rejectedCall;
        break;
      case CallType.neverAttended:
        icon = Icons.phone_disabled_rounded;
        iconColor = AppColors.missedCall;
        break;
      case CallType.notPickupByClient:
        icon = Icons.phone_missed_rounded;
        iconColor = AppColors.missedCall;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => Get.toNamed(AppRoutes.callDetails, arguments: call),
        leading: CircleAvatar(
          backgroundColor: iconColor.withValues(alpha: 0.12),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(call.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(
          '${DateFormatter.formatCallTime(call.timestamp)} • ${DateFormatter.formatDuration(call.durationInSeconds)}',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
      ),
    );
  }
}
