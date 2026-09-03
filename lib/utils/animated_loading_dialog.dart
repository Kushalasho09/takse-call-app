import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'animated_loader.dart';
import 'app_theme.dart';

class AppAnimatedLoadingDialog extends StatelessWidget {
  final String title;
  final String subtitle;

  const AppAnimatedLoadingDialog({
    super.key,
    this.title = 'Fetching Call Logs...',
    this.subtitle = 'Syncing call history & updating call analytics...',
  });

  static bool _isOpen = false;

  static void show({
    String title = 'Fetching Call Logs...',
    String subtitle = 'Syncing call history & updating call analytics...',
  }) {
    if (_isOpen) return;
    _isOpen = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isOpen && !(Get.isDialogOpen ?? false)) {
        Get.dialog(
          AppAnimatedLoadingDialog(title: title, subtitle: subtitle),
          barrierDismissible: false,
          barrierColor: Colors.black.withValues(alpha: 0.7),
        );
      }
    });
  }

  static void hide() {
    if (_isOpen) {
      _isOpen = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: Container(
          width: 290,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            color: const Color(0xFF1E202B),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF282B3C), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 32,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppAnimatedPulseLoader(size: 64, color: AppColors.primary),
              const SizedBox(height: 22),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 13,
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
