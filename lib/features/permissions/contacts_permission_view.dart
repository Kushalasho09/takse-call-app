import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'contacts_permission_controller.dart';

class ContactsPermissionView extends StatelessWidget {
  const ContactsPermissionView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ContactsPermissionController());

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
                            child: const _ContactsIllustrationWidget(),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Title & Subtitle Section
                        const Column(
                          children: [
                            Text(
                              'Access to Your Contacts',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E293B),
                                height: 1.25,
                                letterSpacing: -0.3,
                              ),
                            ),
                            SizedBox(height: 16),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                'Task Call needs to access your contacts to display the names and allow you to easily analyze your call data. Unfortunately, we would not be able to continue if deny access to you contacts. We assure you that your contacts will not be uploaded to any cloud server. We store data within your device.',
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
                        // Action Button & Safe Tag
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
                                          "Let's do it",
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
                                  'We are safe!',
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

/// Native Flutter Contacts Illustration matching the design screenshot
class _ContactsIllustrationWidget extends StatelessWidget {
  const _ContactsIllustrationWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Circular shape
          Container(
            width: 250,
            height: 250,
            decoration: const BoxDecoration(
              color: Color(0xFFEBF3FE),
              shape: BoxShape.circle,
            ),
          ),
          // Left hand sleeve/arm background
          Positioned(
            left: 20,
            bottom: 25,
            child: Transform.rotate(
              angle: -0.2,
              child: Container(
                width: 70,
                height: 110,
                decoration: BoxDecoration(
                  color: const Color(0xFF93C5FD),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          // Phone frame with Contacts list
          Container(
            width: 145,
            height: 220,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFF1D4ED8), width: 3.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Column(
                children: [
                  // App bar mock
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    color: const Color(0xFFF8FAFC),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Contacts',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            Icon(Icons.more_vert, size: 12, color: Colors.grey),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: const Row(
                            children: [
                              SizedBox(width: 4),
                              Icon(Icons.search, size: 10, color: Colors.grey),
                              SizedBox(width: 4),
                              Text('Search', style: TextStyle(fontSize: 8, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  // Contact Items list
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        physics: const NeverScrollableScrollPhysics(),
                        children: const [
                          _ContactRowMock(name: 'Alex Miller', phone: '+1 234 567 890'),
                          _ContactRowMock(name: 'Chris Wilson', phone: '+1 234 567 891'),
                          _ContactRowMock(name: 'Emma Davis', phone: '+1 234 567 892'),
                          _ContactRowMock(name: 'Benjamin Frank', phone: '+1 234 567 893'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Custom Painter overlay for hands holding the phone
          CustomPaint(
            size: const Size(260, 260),
            painter: _HandsPainter(),
          ),
        ],
      ),
    );
  }
}

class _ContactRowMock extends StatelessWidget {
  final String name;
  final String phone;

  const _ContactRowMock({required this.name, required this.phone});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: Color(0xFF3B82F6),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                name.substring(0, 1),
                style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  phone,
                  style: const TextStyle(fontSize: 6, color: Color(0xFF94A3B8)),
                  maxLines: 1,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text('Total Calls', style: TextStyle(fontSize: 5, color: Color(0xFF2563EB))),
          ),
        ],
      ),
    );
  }
}

class _HandsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final handPaint = Paint()
      ..color = const Color(0xFFFFB796) // Warm peach skin tone
      ..style = PaintingStyle.fill;

    final darkHandPaint = Paint()
      ..color = const Color(0xFFFFA07A)
      ..style = PaintingStyle.fill;

    final shirtPaint = Paint()
      ..color = const Color(0xFF93C5FD)
      ..style = PaintingStyle.fill;

    // Left hand holding phone edge
    final leftHandPath = Path();
    leftHandPath.moveTo(size.width * 0.28, size.height * 0.35);
    leftHandPath.quadraticBezierTo(size.width * 0.22, size.height * 0.38, size.width * 0.24, size.height * 0.60);
    leftHandPath.quadraticBezierTo(size.width * 0.26, size.height * 0.70, size.width * 0.38, size.height * 0.68);
    leftHandPath.quadraticBezierTo(size.width * 0.30, size.height * 0.50, size.width * 0.28, size.height * 0.35);
    canvas.drawPath(leftHandPath, handPaint);

    // Left cuff
    final cuffPath = Path();
    cuffPath.moveTo(size.width * 0.22, size.height * 0.60);
    cuffPath.lineTo(size.width * 0.15, size.height * 0.72);
    cuffPath.lineTo(size.width * 0.28, size.height * 0.85);
    cuffPath.lineTo(size.width * 0.36, size.height * 0.70);
    cuffPath.close();
    canvas.drawPath(cuffPath, shirtPaint);

    // Right hand tapping screen
    final rightHandPath = Path();
    rightHandPath.moveTo(size.width * 0.62, size.height * 0.45);
    rightHandPath.quadraticBezierTo(size.width * 0.78, size.height * 0.55, size.width * 0.82, size.height * 0.72);
    rightHandPath.quadraticBezierTo(size.width * 0.72, size.height * 0.80, size.width * 0.58, size.height * 0.65);
    rightHandPath.quadraticBezierTo(size.width * 0.56, size.height * 0.52, size.width * 0.62, size.height * 0.45);
    canvas.drawPath(rightHandPath, darkHandPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
