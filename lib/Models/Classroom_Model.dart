// ignore_for_file: file_names, camel_case_types, non_constant_identifier_names

class classroom_model {
  final int Class_id;
  final String Class_name;
  final String Grade_Name;
  final String School_Name;

  classroom_model({
    required this.Class_id,
    required this.Class_name,
    required this.Grade_Name,
    required this.School_Name,
  });
  factory classroom_model.fromJson(Map<String, dynamic> json) {
    return classroom_model(
      Class_id: json['Class_id'] ?? 0,
      Class_name: json['Class_name'],
      Grade_Name: json['Grade_Name'],
      School_Name: json['School_Name'],
    );
  }
  Map<String, dynamic> toJson() => {
        'Class_id': Class_id,
        'Class_name': Class_name,
        'Grade_ID': Grade_Name,
        'School_ID': School_Name,
      };
}
