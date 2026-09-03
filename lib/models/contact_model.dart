class ContactItem {
  final String id;
  final String name;
  final String phoneNumber;
  final String email;
  final String company;
  final int totalCalls;
  final DateTime lastCallTime;
  final String? avatarUrl;

  ContactItem({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.company,
    required this.totalCalls,
    required this.lastCallTime,
    this.avatarUrl,
  });
}
