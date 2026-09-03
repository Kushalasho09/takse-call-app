import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../services/cloud_sync_service.dart';
import '../../services/prefs_service.dart';
import '../../services/session_manager.dart';
import '../../utils/app_theme.dart';
import '../routes/app_pages.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    super.initState();
    // Auto-check sync status & detect new calls on screen load
    CloudSyncService.checkSyncStatus();
  }

  @override
  Widget build(BuildContext context) {
    final user = SessionManager.currentUser;
    final userName = user?.name.isNotEmpty == true ? user!.name : 'Kushal Asodia';
    final userPhone = user?.phone.isNotEmpty == true ? user!.phone : PrefsService.userPhone;
    final connectCode = user?.connectCode.isNotEmpty == true ? user!.connectCode : PrefsService.connectCode;
    final companyName = user?.companyName.isNotEmpty == true ? user!.companyName : PrefsService.companyName;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Logo Graphic & User Sync Card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1C22),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2A2C38), width: 1),
                ),
                child: Column(
                  children: [
                    // Multi-color top bar strip
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: SizedBox(
                        height: 6,
                        child: Row(
                          children: [
                            Expanded(child: Container(color: const Color(0xFFEF4444))), // Red
                            Expanded(child: Container(color: const Color(0xFFF59E0B))), // Orange
                            Expanded(child: Container(color: const Color(0xFFEAB308))), // Yellow
                            Expanded(child: Container(color: const Color(0xFF84CC16))), // Green
                          ],
                        ),
                      ),
                    ),

                    // User Info & Sync Details Split Row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Row(
                        children: [
                          // Left Column: User details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // SIM & Connect Code Badge
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: Colors.white70, width: 1.2),
                                      ),
                                      child: const Text(
                                        '1',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    if (connectCode.isNotEmpty) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withAlpha(40),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: AppColors.primary.withAlpha(80)),
                                        ),
                                        child: Text(
                                          connectCode,
                                          style: const TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  userName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  userPhone,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white70,
                                    height: 1.2,
                                  ),
                                ),
                                if (companyName.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    companyName,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textMuted,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // Vertical Divider
                          Container(
                            width: 1,
                            height: 70,
                            color: const Color(0xFF2A2C38),
                          ),
                          const SizedBox(width: 16),

                          // Right Column: Last Sync
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.sync_rounded,
                                      color: Color(0xFF10B981),
                                      size: 20,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Active',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF10B981),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Last Cloud Sync',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('d-MMM-yyyy hh:mm a').format(DateTime.now()),
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Prominent Cloud Call Synchronization Card
              _buildCloudSyncSection(),

              const SizedBox(height: 20),

              // Social Media Row (6 White Buttons)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSocialButton(
                    child: const Text(
                      'f',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        fontFamily: 'serif',
                      ),
                    ),
                  ),
                  _buildSocialButton(
                    child: const Text(
                      '𝕏',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  _buildSocialButton(
                    child: const Text(
                      'in',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  _buildSocialButton(
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.black,
                      size: 22,
                    ),
                  ),
                  _buildSocialButton(
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.black,
                      size: 26,
                    ),
                  ),
                  _buildSocialButton(
                    child: const Icon(
                      Icons.language_rounded,
                      color: Colors.black,
                      size: 22,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Battery Optimization Warning Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1C22),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFEF4444), width: 1.5),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFEF4444),
                      size: 26,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'To ensure Task Call continues to function smoothly and efficiently, we recommend disable battery optimization.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {},
                              child: const Text(
                                'Disable Now',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Menu Option Items
              _buildMenuCard(
                icon: Icons.autorenew_rounded,
                title: 'Call-Cut Automation Settings',
                onTap: () => Get.toNamed(AppRoutes.automationSettings),
              ),
              const SizedBox(height: 12),

              _buildMenuCard(
                icon: Icons.edit_calendar_outlined,
                title: 'Call Note Templates',
              ),
              const SizedBox(height: 12),

              _buildMenuCard(
                icon: Icons.chat_outlined,
                title: 'Message Templates',
              ),
              const SizedBox(height: 12),

              _buildMenuCard(
                icon: Icons.devices_other_outlined,
                title: 'Linked Quick Call Extension',
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFF2A2C38), height: 1),
              const SizedBox(height: 16),

              // Logout Menu Card
              _buildLogoutCard(context, connectCode),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutCard(BuildContext context, String connectCode) {
    return GestureDetector(
      onTap: () => _showLogoutDialog(context, connectCode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF26181B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEF4444).withAlpha(80), width: 1),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withAlpha(40),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.logout_rounded,
                size: 22,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Logout / Disconnect Device',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFF87171),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Disconnect SIM call sync from cloud',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: Color(0xFFF87171),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, String connectCode) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1B1C22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 24),
            SizedBox(width: 10),
            Text(
              'Disconnect Device?',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          connectCode.isNotEmpty
              ? 'Are you sure you want to disconnect this device ($connectCode)? You will need to enter the code again to sync call history.'
              : 'Are you sure you want to log out from this device?',
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              SessionManager.logout();
              PrefsService.setConnectCode('');
              Get.offAllNamed(AppRoutes.login);
              Get.snackbar(
                'Logged Out',
                'Device disconnected successfully',
                backgroundColor: const Color(0xFFEF4444),
                colorText: Colors.white,
                snackPosition: SnackPosition.TOP,
                margin: const EdgeInsets.all(16),
                borderRadius: 12,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Disconnect', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({required Widget child}) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(child: child),
    );
  }

  Widget _buildMenuCard({required IconData icon, required String title, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 22,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCloudSyncSection() {
    return ValueListenableBuilder<SyncProgressState>(
      valueListenable: CloudSyncService.state,
      builder: (context, sync, _) {
        final total = sync.totalOnDevice;
        final synced = sync.syncedToCloud;
        final pending = sync.pendingToSync;
        final isSyncing = sync.isSyncing;
        final progress = sync.progress;
        final isAllSynced = !isSyncing && pending == 0 && total > 0;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1B1C22),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isAllSynced
                  ? const Color(0xFF10B981).withAlpha(120)
                  : (pending > 0 ? const Color(0xFFF59E0B).withAlpha(120) : const Color(0xFF2A2C38)),
              width: 1.5,
            ),
            boxShadow: [
              if (isAllSynced)
                BoxShadow(
                  color: const Color(0xFF10B981).withAlpha(30),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isAllSynced
                          ? const Color(0xFF10B981).withAlpha(35)
                          : (isSyncing ? AppColors.primary.withAlpha(35) : const Color(0xFFF59E0B).withAlpha(35)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isAllSynced ? Icons.cloud_done_rounded : (isSyncing ? Icons.sync_rounded : Icons.cloud_upload_rounded),
                      color: isAllSynced ? const Color(0xFF10B981) : (isSyncing ? AppColors.primary : const Color(0xFFF59E0B)),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cloud Call Synchronization',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isSyncing
                              ? 'Uploading call logs in batches...'
                              : (isAllSynced ? 'All phone records synced with web' : '$pending calls waiting for cloud sync'),
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isAllSynced ? const Color(0xFF10B981) : AppColors.textMuted,
                            fontWeight: isAllSynced ? FontWeight.w600 : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (isSyncing) ...[
                    const SizedBox(width: 8),
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),

              // 3 Stats Metric Counters
              Row(
                children: [
                  _syncStatBox('Total on Phone', '$total', Icons.phone_android_rounded, Colors.white),
                  const SizedBox(width: 8),
                  _syncStatBox('Synced to Cloud', '$synced', Icons.cloud_done_outlined, const Color(0xFF10B981)),
                  const SizedBox(width: 8),
                  _syncStatBox('Left to Sync', '$pending', Icons.pending_actions_rounded, pending > 0 ? const Color(0xFFF59E0B) : const Color(0xFF94A3B8)),
                ],
              ),
              const SizedBox(height: 14),

              // Progress Percentage Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Upload Progress',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}% completed',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isAllSynced ? const Color(0xFF10B981) : (isSyncing ? AppColors.primary : Colors.white70),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Linear Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: const Color(0xFF2A2C38),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isAllSynced ? const Color(0xFF10B981) : (isSyncing ? AppColors.primary : const Color(0xFFF59E0B)),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Full Status Message (Dedicated line with multi-line wrap - never overflows)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF14151A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isAllSynced
                        ? const Color(0xFF10B981).withAlpha(50)
                        : (isSyncing ? AppColors.primary.withAlpha(60) : const Color(0xFF2A2C38)),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (isSyncing)
                      const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: SizedBox(
                          width: 13,
                          height: 13,
                          child: CircularProgressIndicator(strokeWidth: 1.8, color: AppColors.primary),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(
                          isAllSynced ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                          size: 15,
                          color: isAllSynced ? const Color(0xFF10B981) : AppColors.textMuted,
                        ),
                      ),
                    Expanded(
                      child: Text(
                        sync.statusMessage,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isAllSynced ? const Color(0xFF10B981) : (isSyncing ? Colors.white : AppColors.textMuted),
                          fontWeight: isAllSynced || isSyncing ? FontWeight.w600 : FontWeight.normal,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // New Calls Detected notification if user has made new calls
              if (sync.newCallsDetected > 0 && !isSyncing) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7).withAlpha(25),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFF59E0B).withAlpha(90)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bolt_rounded, size: 16, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '⚡ ${sync.newCallsDetected} new phone calls detected! Ready to push to web dashboard.',
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFFF59E0B), fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Action Buttons
              if (pending > 0 || isSyncing)
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: isSyncing
                        ? null
                        : () async {
                            await CloudSyncService.syncCallLogsToCloud();
                          },
                    icon: isSyncing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.cloud_upload_rounded, size: 18),
                    label: Text(
                      isSyncing ? 'Syncing Call Logs (${(progress * 100).toInt()}%)...' : 'Sync $pending Calls to Cloud Now',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF10B981).withAlpha(80)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.verified_rounded, size: 16, color: Color(0xFF10B981)),
                            SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'All Calls Synced! 🎉',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF10B981),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () async {
                        await CloudSyncService.checkSyncStatus(forceRefresh: true);
                        Get.snackbar(
                          'Checked for New Calls',
                          'Scanned phone SIM logs for any new calls',
                          backgroundColor: const Color(0xFF1B1C22),
                          colorText: Colors.white,
                          duration: const Duration(seconds: 2),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF262938),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF374151)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.refresh_rounded, size: 16, color: Colors.white70),
                            SizedBox(width: 4),
                            Text('Scan New', style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _syncStatBox(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF14151A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF2A2C38)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 13, color: color),
                const SizedBox(width: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF94A3B8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
