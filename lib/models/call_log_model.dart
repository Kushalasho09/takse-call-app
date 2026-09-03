enum CallType { incoming, outgoing, missed, rejected, neverAttended, notPickupByClient }

enum CallTag { lead, personal, work, spam, support }

class CallLogItem {
  final String id;
  final String name;
  final String number;
  final CallType type;
  final DateTime timestamp;
  final int durationInSeconds; // duration 0 for missed/rejected
  final CallTag tag;
  String? note;
  final String? avatarUrl;

  final String simId; // '1' or '2'

  CallLogItem({
    required this.id,
    required this.name,
    required this.number,
    required this.type,
    required this.timestamp,
    required this.durationInSeconds,
    this.simId = '1',
    this.tag = CallTag.work,
    this.note,
    this.avatarUrl,
  });

  CallLogItem copyWith({
    String? id,
    String? name,
    String? number,
    CallType? type,
    DateTime? timestamp,
    int? durationInSeconds,
    String? simId,
    CallTag? tag,
    String? note,
    String? avatarUrl,
  }) {
    return CallLogItem(
      id: id ?? this.id,
      name: name ?? this.name,
      number: number ?? this.number,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      durationInSeconds: durationInSeconds ?? this.durationInSeconds,
      simId: simId ?? this.simId,
      tag: tag ?? this.tag,
      note: note ?? this.note,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
