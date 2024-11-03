// ignore_for_file: non_constant_identifier_names, camel_case_types, file_names

class USer_Model {
  final int user_id;
  final String username;
  final String password;
  final String School_Name;
  final String role;

  USer_Model({
    required this.user_id,
    required this.username,
    required this.password,
    required this.School_Name,
    required this.role,
  });
  factory USer_Model.fromJson(Map<String, dynamic> json) {
    return USer_Model(
      user_id: json['user_id'] ?? 0,
      username: json['username'],
      password: json['password'],
      School_Name: json['School_Name'],
      role: json['role'],
    );
  }
}
