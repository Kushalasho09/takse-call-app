import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDuration(int seconds) {
    if (seconds <= 0) return '0s';
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    final int hours = minutes ~/ 60;
    final int remainingMinutes = minutes % 60;

    if (hours > 0) {
      return '${hours}h ${remainingMinutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    } else {
      return '${seconds}s';
    }
  }

  static String formatCallTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final timeString = DateFormat('h:mm a').format(dateTime);

    if (checkDate == today) {
      return 'Today, $timeString';
    } else if (checkDate == yesterday) {
      return 'Yesterday, $timeString';
    } else {
      return DateFormat('MMM d, h:mm a').format(dateTime);
    }
  }

  static String formatDateOnly(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy').format(dateTime);
  }
}
