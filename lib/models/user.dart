class User {
  final int id;
  final String name;
  final String email;
  final String token;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return User(
      id: data['id'],
      name: data['name'],
      email: data['email'],
      token: json['token'],
    );
  }
}
