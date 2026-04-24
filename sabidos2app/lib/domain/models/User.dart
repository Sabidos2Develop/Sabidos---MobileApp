class User {
  final String id;
  final String name;
  final String email;
  final String password;
  final String uid;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.uid,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      uid: json['firebaseUid'],
    );
  }
}
