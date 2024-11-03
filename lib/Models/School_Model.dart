// ignore_for_file: non_constant_identifier_names, camel_case_types, file_names

class School_Model {
  final int SchoolID;
  final String School_Name;
  final String Des;
  final String School_Code;
  final int Pro_id;
  School_Model({
    required this.SchoolID,
    required this.School_Name,
    required this.Des,
    required this.School_Code,
    required this.Pro_id,
  });
  factory School_Model.fromJson(Map<String, dynamic> json) {
    return School_Model(
      SchoolID: json['SchoolID']??0,
      School_Name: json['School_Name'],
      Des: json['Des'],
      School_Code: json['School_Code'],
      Pro_id: json['Pro_id']??0,
    );
  }
}
