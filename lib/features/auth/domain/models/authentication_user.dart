class AuthenticationUser {
  /// El `userId` de Roble: es texto, no un entero.
  String? id;
  final String email;
  final String name;
  final String password;

  /// Los tres viajan en el `extra` del registro de Roble: el perfil del
  /// estudiante no tiene tabla propia.
  final String? academicProgram;
  final int? semester;
  final List<String>? skills;

  AuthenticationUser({
    this.id,
    required this.email,
    required this.name,
    required this.password,
    this.academicProgram,
    this.semester,
    this.skills,
  });

  factory AuthenticationUser.fromJson(Map<String, dynamic> json) {
    return AuthenticationUser(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'name': name, 'password': password};
  }
}
