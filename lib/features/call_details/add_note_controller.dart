import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/call_log_model.dart';

class AddNoteController extends GetxController {
  late CallLogItem item;
  final noteController = TextEditingController();
  final isRecording = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is CallLogItem) {
      item = Get.arguments as CallLogItem;
      noteController.text = item.note ?? '';
    } else {
      item = CallLogItem(
        id: '1',
        name: 'KUSHAL ASODIA Flutter',
        number: '+919978217711',
        type: CallType.incoming,
        timestamp: DateTime(2026, 7, 29, 23, 9),
        durationInSeconds: 114,
      );
    }
  }

  void toggleMic() {
    isRecording.value = !isRecording.value;
    if (isRecording.value) {
      Get.snackbar(
        'Voice Input',
        'Listening... Speak your note',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF232530),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void saveNote() {
    item.note = noteController.text.trim().isEmpty ? null : noteController.text.trim();
    Get.back(result: item.note);
    Get.snackbar(
      'Saved',
      'Note added successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF232530),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void cancel() {
    Get.back();
  }

  @override
  void onClose() {
    noteController.dispose();
    super.onClose();
  }
}
