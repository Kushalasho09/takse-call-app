import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../utils/app_theme.dart';

class BackgroundPermissionView extends StatelessWidget {
  const BackgroundPermissionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Permissions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.security_rounded, size: 56, color: AppColors.primary),
            const SizedBox(height: 16),
            const Text(
              'Permissions Required',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'To enable call analytics, tracking duration, and lead management, please grant the following permissions:',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 28),
            _permissionTile(
              'Call Logs Permission',
              'Access call history to compute duration, frequency, and metrics.',
              Icons.call,
              () => Permission.phone.request(),
            ),
            const SizedBox(height: 16),
            _permissionTile(
              'Phone State Permission',
              'Detect ongoing calls to record start/end time.',
              Icons.phone_paused_rounded,
              () => Permission.phone.request(),
            ),
            const SizedBox(height: 16),
            _permissionTile(
              'Contacts Permission',
              'Display contact names and company details.',
              Icons.contacts_rounded,
              () => Permission.contacts.request(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _permissionTile(String title, String desc, IconData icon, VoidCallback onRequest) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(desc, style: const TextStyle(fontSize: 12)),
        trailing: OutlinedButton(
          onPressed: onRequest,
          child: const Text('Grant'),
        ),
      ),
    );
  }
}
