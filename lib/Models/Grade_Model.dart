// ignore_for_file: file_names, camel_case_types, non_constant_identifier_names

class Grade_Model {
  final int Grade_ID;
  final String Grade_name;

  final String School_Name;
  Grade_Model({
    required this.Grade_ID,
    required this.Grade_name,
    required this.School_Name,
  });
  factory Grade_Model.fromJson(Map<String, dynamic> json) {
    return Grade_Model(
      Grade_ID: json['Grade_ID'] ?? 0,
      Grade_name: json['Grade_name'],
      School_Name: json['School_Name'],
    );
  }
}
