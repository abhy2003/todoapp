class UserModel {
  final String name;
  final String email;
  final String userId;

  UserModel({required this.name, required this.email, required this.userId});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'userId': userId,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'],
      email: map['email'],
      userId: map['userId'],
    );
  }
}
