class User {
  final String email;
  final String password;

  User({required this.email, required this.password});
}

List<User> users = [
  User(email: "user1@example.com", password: "password123"),
  User(email: "user2@example.com", password: "password456"),
];