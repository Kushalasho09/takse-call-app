class CallStatsModel {
  final int totalCalls;
  final int incomingCount;
  final int outgoingCount;
  final int missedCount;
  final int rejectedCount;
  final int neverAttendedCount;
  final int notPickupByClientCount;
  final int uniqueCallsCount;
  final int totalDurationSeconds;
  final int incomingDurationSeconds;
  final int outgoingDurationSeconds;
  final String topCallerName;
  final String topCallerNumber;
  final int topCallerCount;

  CallStatsModel({
    required this.totalCalls,
    required this.incomingCount,
    required this.outgoingCount,
    required this.missedCount,
    required this.rejectedCount,
    required this.neverAttendedCount,
    required this.notPickupByClientCount,
    required this.uniqueCallsCount,
    required this.totalDurationSeconds,
    required this.incomingDurationSeconds,
    required this.outgoingDurationSeconds,
    required this.topCallerName,
    required this.topCallerNumber,
    required this.topCallerCount,
  });

  factory CallStatsModel.empty() {
    return CallStatsModel(
      totalCalls: 0,
      incomingCount: 0,
      outgoingCount: 0,
      missedCount: 0,
      rejectedCount: 0,
      neverAttendedCount: 0,
      notPickupByClientCount: 0,
      uniqueCallsCount: 0,
      totalDurationSeconds: 0,
      incomingDurationSeconds: 0,
      outgoingDurationSeconds: 0,
      topCallerName: 'N/A',
      topCallerNumber: '',
      topCallerCount: 0,
    );
  }
}
