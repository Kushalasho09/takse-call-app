import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/call_log_model.dart';
import '../../utils/app_theme.dart';
import 'add_note_controller.dart';

class AddNoteView extends GetView<AddNoteController> {
  const AddNoteView({super.key});

  String _formatDuration(int seconds) {
    int h = seconds ~/ 3600;
    int m = (seconds % 3600) ~/ 60;
    int s = seconds % 60;
    return '${h}h ${m}m ${s}s';
  }

  String _formatDateTime(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    String monthStr = months[dt.month - 1];
    int hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    String minute = dt.minute.toString().padLeft(2, '0');
    String period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${dt.day} $monthStr ${dt.year} | $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    Get.put(AddNoteController());
    final item = controller.item;
    final initial = item.name.isNotEmpty ? item.name[0].toUpperCase() : 'C';

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
          'Add Note',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Selected Call Summary Card (Matching Image 2)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1D1F2B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF282B3C), width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Circle Avatar Initial
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFF52576B),
                      child: Text(
                        initial,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Info Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Contact Name & Duration Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.pie_chart_outline_rounded,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatDuration(item.durationInSeconds),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // Phone Number
                          Text(
                            item.number,
                            style: const TextStyle(
                              fontSize: 13.5,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Call Status & SIM Badge
                          Row(
                            children: [
                              Icon(
                                item.type == CallType.incoming
                                    ? Icons.call_received_rounded
                                    : item.type == CallType.outgoing
                                        ? Icons.call_made_rounded
                                        : Icons.call_missed_rounded,
                                size: 14,
                                color: item.type == CallType.incoming
                                    ? const Color(0xFFA3E635)
                                    : item.type == CallType.outgoing
                                        ? const Color(0xFFF59E0B)
                                        : const Color(0xFFEF4444),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item.type == CallType.incoming
                                    ? 'Incoming'
                                    : item.type == CallType.outgoing
                                        ? 'Outgoing'
                                        : 'Missed',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: item.type == CallType.incoming
                                      ? const Color(0xFFA3E635)
                                      : item.type == CallType.outgoing
                                          ? const Color(0xFFF59E0B)
                                          : const Color(0xFFEF4444),
                                ),
                              ),
                              const SizedBox(width: 6),
                              // SIM Badge [1]
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
                          const SizedBox(height: 6),

                          // Timestamp
                          Text(
                            _formatDateTime(item.timestamp),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Add Note Section Title
              const Text(
                'Add Note',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              // Multi-line Text Area Box with Embedded Mic Button
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF212431),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2E3245), width: 1),
                ),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                child: Column(
                  children: [
                    TextField(
                      controller: controller.noteController,
                      maxLines: 5,
                      minLines: 4,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        height: 1.4,
                      ),
                      decoration: const InputDecoration(
                        hintText: "Type your call summary or use '/' to add call note template(s) quickly.",
                        hintStyle: TextStyle(
                          color: Color(0xFF80889C),
                          fontSize: 14.5,
                          height: 1.4,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Mic Icon Button on Bottom Right
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: controller.toggleMic,
                        child: Obx(
                          () => Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: controller.isRecording.value
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF2563EB),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (controller.isRecording.value
                                          ? const Color(0xFFEF4444)
                                          : const Color(0xFF2563EB))
                                      .withAlpha(80),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              controller.isRecording.value ? Icons.stop_rounded : Icons.mic_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Action Buttons Row (Save & Cancel)
              Row(
                children: [
                  // Save Button
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: controller.saveNote,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Cancel Button
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: controller.cancel,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
