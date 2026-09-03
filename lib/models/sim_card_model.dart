class SimCardInfo {
  final String id; // 'all', '1', '2'
  final String name; // e.g. "All SIMs", "SIM 1", "SIM 2"
  final String carrierName; // e.g. "Jio 5G", "Airtel 4G", "All Networks"
  final String? phoneNumber;
  final bool isActive;

  const SimCardInfo({
    required this.id,
    required this.name,
    required this.carrierName,
    this.phoneNumber,
    this.isActive = true,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SimCardInfo &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
