class UserModel {
  const UserModel({
    required this.name,
    required this.email,
    required this.password,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        name: json['name'] as String,
        email: json['email'] as String,
        password: json['password'] as String,
      );

  final String name;
  final String email;
  final String password;

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
      };

  UserModel copyWith({String? name, String? password}) => UserModel(
        name: name ?? this.name,
        email: email,
        password: password ?? this.password,
      );
}
