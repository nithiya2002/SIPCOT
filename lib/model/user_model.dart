class UserModel {
  final String email;
  UserModel({required this.email});
  // Convert User to Map for storage
  Map<String, dynamic> toMap() {
    return {'email': email};
  }

  // Create User from Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(email: map['email'] ?? '');
  }
}
