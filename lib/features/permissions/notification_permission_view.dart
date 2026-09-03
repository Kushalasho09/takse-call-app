import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'notification_permission_controller.dart';

class NotificationPermissionView extends StatelessWidget {
  const NotificationPermissionView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationPermissionController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 12),
                        // Illustration Section
                        Expanded(
                          flex: 5,
                          child: Container(
                            constraints: const BoxConstraints(maxHeight: 320),
                            child: const _NotificationIllustrationWidget(),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Title & Subtitle Section
                        const Column(
                          children: [
                            Text(
                              'Get Notified!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E293B),
                                height: 1.25,
                                letterSpacing: -0.3,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Allow Task Call to send you\nNotifications.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                                height: 1.3,
                              ),
                            ),
                            SizedBox(height: 12),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                'This helps us to perform important tasks like Lead Reminders, Subscription Updates, Call Synchronization and more.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        // Action Button & Footer Tag
                        Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: Obx(
                                () => ElevatedButton(
                                  onPressed: controller.isLoading.value
                                      ? null
                                      : () => controller.requestPermission(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3352D0),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: controller.isLoading.value
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : const Text(
                                          'Yes, I Agree',
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shield_outlined,
                                  size: 20,
                                  color: Color(0xFF1E293B),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Keep Updated!',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Native Flutter Notification Illustration matching the reference screenshot
class _NotificationIllustrationWidget extends StatelessWidget {
  const _NotificationIllustrationWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background subtle aura glow
          Container(
            width: 230,
            height: 230,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF).withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
          ),
          // Character with notification badges
          SizedBox(
            width: 200,
            height: 250,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Floating speech bubble badges (Top Left of character)
                Positioned(
                  top: 25,
                  left: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Yellow badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB800),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline, size: 14, color: Colors.white),
                            SizedBox(width: 4),
                            Icon(Icons.notifications, size: 12, color: Colors.white),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Blue badge with dots
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3352D0),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.more_horiz, size: 16, color: Colors.white),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Man character standing holding phone
                CustomPaint(
                  size: const Size(180, 240),
                  painter: _ManCharacterPainter(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ManCharacterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final skinPaint = Paint()
      ..color = const Color(0xFFFFC5A8)
      ..style = PaintingStyle.fill;

    final hairPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;

    final shirtPaint = Paint()
      ..color = const Color(0xFFFFC107) // Yellow shirt/sweater
      ..style = PaintingStyle.fill;

    final pantsPaint = Paint()
      ..color = const Color(0xFF2563EB) // Blue trousers
      ..style = PaintingStyle.fill;

    final shoesPaint = Paint()
      ..color = const Color(0xFF3B82F6) // Blue sneakers
      ..style = PaintingStyle.fill;

    final phonePaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;

    final center = size.width * 0.5;

    // Head
    canvas.drawCircle(Offset(center + 10, 50), 18, skinPaint);
    // Hair
    final hairPath = Path()
      ..addOval(Rect.fromCircle(center: Offset(center + 10, 44), radius: 18));
    canvas.drawPath(hairPath, hairPaint);

    // Torso (Yellow Shirt)
    final torsoPath = Path()
      ..moveTo(center - 10, 68)
      ..lineTo(center + 30, 68)
      ..lineTo(center + 25, 125)
      ..lineTo(center - 15, 125)
      ..close();
    canvas.drawPath(torsoPath, shirtPaint);

    // Arms & Holding Phone
    final armPath = Path()
      ..moveTo(center - 10, 75)
      ..lineTo(center - 25, 95)
      ..lineTo(center - 10, 105);
    canvas.drawPath(armPath, skinPaint);

    // Phone in hand
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(center - 32, 92, 14, 24),
        const Radius.circular(3),
      ),
      phonePaint,
    );

    // Legs (Blue Pants)
    // Left leg
    final leftLeg = Path()
      ..moveTo(center - 12, 125)
      ..lineTo(center - 18, 190)
      ..lineTo(center - 5, 190)
      ..lineTo(center + 2, 125)
      ..close();
    canvas.drawPath(leftLeg, pantsPaint);

    // Right leg
    final rightLeg = Path()
      ..moveTo(center + 8, 125)
      ..lineTo(center + 25, 185)
      ..lineTo(center + 36, 185)
      ..lineTo(center + 22, 125)
      ..close();
    canvas.drawPath(rightLeg, pantsPaint);

    // Shoes
    canvas.drawOval(Rect.fromLTWH(center - 24, 188, 22, 12), shoesPaint);
    canvas.drawOval(Rect.fromLTWH(center + 22, 183, 20, 11), shoesPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
