// ignore_for_file: camel_case_types, non_constant_identifier_names, file_names

class project_model {
  final int Pro_ID;
  final String Pro_Name;
  final String Pro_Code;
  project_model({
    required this.Pro_ID,
    required this.Pro_Name,
    required this.Pro_Code,
  });
  factory project_model.fromJson(Map<String, dynamic> json) {
    return project_model(
      Pro_ID: json['Pro_ID'],
      Pro_Name: json['Pro_Name'],
      Pro_Code: json['Pro_Code'],
    );
  }
  Map<String, dynamic> toJson() => {
        'Pro_ID': Pro_ID,
        'Pro_Name': Pro_Name,
        'Pro_Code': Pro_Code,
      };
}
