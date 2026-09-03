class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String companyName;
  final String connectCode;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.companyName,
    this.connectCode = 'KUS-3926-0820',
  });

  factory UserModel.mock({String name = 'Rohan Sharma', String connectCode = 'ROH-3453-2342'}) {
    return UserModel(
      id: 'usr_101',
      name: name,
      email: 'rohan@apexsolutions.com',
      phone: '+91 88663 69985',
      role: 'Sales Executive',
      companyName: 'Apex Enterprise',
      connectCode: connectCode,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? map['userName'] ?? 'Agent',
      email: map['email'] ?? '',
      phone: map['phone'] ?? map['userPhone'] ?? '',
      role: map['role'] ?? 'Sales Agent',
      companyName: map['companyName'] ?? 'Takse Call Enterprise',
      connectCode: map['connectCode'] ?? id,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'companyName': companyName,
      'connectCode': connectCode,
    };
  }
}
