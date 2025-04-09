class User {
  final String email;
  final String password;
  final String pin;

  User({required this.email, required this.password, required this.pin});
}

List<User> users = [
  User(email: "user1@example.com", password: "password123", pin: "1234"),
  User(email: "user2@example.com", password: "password456", pin: "5678"),
  User(email: "admin", password: "haslo", pin: "123"),
];