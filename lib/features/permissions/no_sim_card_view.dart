import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'no_sim_card_controller.dart';

class NoSimCardView extends StatelessWidget {
  const NoSimCardView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NoSimCardController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => controller.retryCheckSim(),
          behavior: HitTestBehavior.opaque,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Custom SIM Card Icon Box matching screenshot
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1E293B), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.grid_view_rounded,
                      size: 26,
                      color: Color(0xFF3352D0),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'No SIM card installed',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 16),
                Obx(
                  () => controller.isChecking.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF3352D0),
                          ),
                        )
                      : Text(
                          'Tap screen to refresh',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade400,
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
