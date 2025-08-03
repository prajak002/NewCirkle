enum UserRole {
  stallVendor,
  topUpCounter,
  admin,
}

class User {
  final String username;
  final UserRole role;
  final Map<String, dynamic>? additionalData;

  User({
    required this.username,
    required this.role,
    this.additionalData,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      role: _parseRole(json['role']),
      additionalData: json['additionalData'],
    );
  }

  static UserRole _parseRole(String? role) {
    if (role == null) return UserRole.stallVendor;
    
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'topup':
      case 'top-up':
      case 'topupcounter':
        return UserRole.topUpCounter;
      case 'stall':
      case 'stallvendor':
      case 'vendor':
      default:
        return UserRole.stallVendor;
    }
  }

  Map<String, dynamic> toJson() => {
    'username': username,
    'role': role.toString().split('.').last,
    if (additionalData != null) 'additionalData': additionalData,
  };
}
