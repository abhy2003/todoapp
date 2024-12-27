class UserModel {
  final String name;
  final String email;
  final String userId;

  UserModel({required this.name, required this.email, required this.userId});

  // Convert to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'userId': userId,
    };
  }

  // Convert Firestore document to UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'],
      email: map['email'],
      userId: map['userId'],
    );
  }
}
