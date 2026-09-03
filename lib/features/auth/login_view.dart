import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../utils/animated_loader.dart';
import '../../utils/app_theme.dart';
import '../../utils/connect_code_formatter.dart';
import 'login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(LoginController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Top Icon Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: const Icon(
                        Icons.phonelink_setup_rounded,
                        size: 32,
                        color: AppColors.primary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.accentGreen),
                          SizedBox(width: 4),
                          Text(
                            'SIM Cloud Sync',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Text(
                  controller.isCodeLoginMode.value
                      ? 'Connect Your Device'
                      : 'Sign In with Phone',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  controller.isCodeLoginMode.value
                      ? 'Enter the Device Connect Code provided by your manager on the Web Portal.'
                      : 'Enter your registered phone number to receive a verification OTP.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 32),

                // Switch between Connect Code & Phone Number Tab
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (!controller.isCodeLoginMode.value) controller.toggleLoginMode();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: controller.isCodeLoginMode.value ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Device Connect Code',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: controller.isCodeLoginMode.value ? Colors.white : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (controller.isCodeLoginMode.value) controller.toggleLoginMode();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: !controller.isCodeLoginMode.value ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Mobile Number',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: !controller.isCodeLoginMode.value ? Colors.white : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                if (controller.isCodeLoginMode.value) ...[
                  // Primary: Connect Code Input
                  const Text(
                    'Device Connect Code',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  TextField(
                    controller: controller.connectCodeController,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      ConnectCodeInputFormatter(),
                      LengthLimitingTextInputFormatter(13),
                    ],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                      color: AppColors.accentOrange,
                    ),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: 'KAS-4257-4648',
                      hintStyle: TextStyle(
                        fontSize: 18,
                        letterSpacing: 2,
                        color: AppColors.textSecondary.withValues(alpha: 0.5),
                      ),
                      prefixIcon: const Icon(Icons.qr_code_2_rounded, color: AppColors.accentOrange),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.paste_rounded, color: AppColors.textSecondary, size: 20),
                        tooltip: 'Paste from clipboard',
                        onPressed: () async {
                          final data = await Clipboard.getData(Clipboard.kTextPlain);
                          if (data?.text != null) {
                            controller.connectCodeController.text = data!.text!.trim().toUpperCase();
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Helper Callout Box
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb_outline_rounded, color: AppColors.accentOrange, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Your manager can find your device code at the top of their Takse Call Web Portal (e.g. ROH-3453-2342 or KUS-3926-0820).',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary.withValues(alpha: 0.9),
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Connect Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value ? null : controller.connectWithDeviceCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: controller.isLoading.value
                          ? const AppAnimatedPulseLoader(size: 26, color: Colors.white)
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Connect & Start Syncing', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, size: 20),
                              ],
                            ),
                    ),
                  ),
                ] else ...[
                  // Secondary: Phone Number + OTP Mode
                  const Text(
                    'Mobile Number',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller.phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.phone_outlined, color: AppColors.textSecondary),
                      hintText: '+91 88663 69985',
                    ),
                  ),

                  if (controller.isOtpSent.value) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Verification OTP',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller.otpController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 6),
                      decoration: const InputDecoration(
                        hintText: '123456',
                        prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : (controller.isOtpSent.value ? controller.verifyPhoneOtp : controller.sendPhoneOtp),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: controller.isLoading.value
                          ? const AppAnimatedPulseLoader(size: 26, color: Colors.white)
                          : Text(
                              controller.isOtpSent.value ? 'Verify OTP & Log In' : 'Send Verification OTP',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],

                const SizedBox(height: 28),

                // Quick Demo Pill
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      controller.connectCodeController.text = 'ROH-3453-2342';
                      controller.connectWithDeviceCode();
                    },
                    icon: const Icon(Icons.flash_on_rounded, color: AppColors.accentOrange, size: 18),
                    label: const Text(
                      'Quick Demo: Connect with ROH-3453-2342',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
