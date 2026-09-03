import 'package:get/get.dart';
import '../../models/call_log_model.dart';
import '../../models/call_stats_model.dart';
import '../../services/call_log_service.dart';

class HomeController extends GetxController {
  final stats = CallStatsModel.empty().obs;
  final recentCalls = <CallLogItem>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    isLoading.value = true;
    try {
      final logs = await CallLogService.fetchCallLogs();
      stats.value = CallLogService.calculateStats(logs);
      recentCalls.assignAll(logs.take(4).toList());
    } finally {
      isLoading.value = false;
    }
  }
}
