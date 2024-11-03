// ignore_for_file: non_constant_identifier_names, camel_case_types, file_names

class staff_model {
  final int staff_ID;
  final String Fullname;
  final String Gender;
  final String Position;
  final String Contract_No;
  final String School_Name;
  final int Pro_ID;
  staff_model(
      {required this.staff_ID,
      required this.Fullname,
      required this.Gender,
      required this.Position,
      required this.Contract_No,
      required this.School_Name,
      required this.Pro_ID});
  factory staff_model.fromJson(Map<String, dynamic> json) {
    return staff_model(
      staff_ID: json['staff_ID'] ?? 0,
      Fullname: json['Fullname'],
      Gender: json['Gender'],
      Position: json['Position'] ?? "x",
      Contract_No: json['Contract_No'],
      School_Name: json['School_Name'],
      Pro_ID: json['Pro_ID'] ?? 0,
    );
  }
}

class StudentDetails {
  final int studentID;
  final String fullname;
  final String gender;
  final String className;
  final String gradeName;
  final String schoolName;
  final String projectName;

  StudentDetails({
    required this.studentID,
    required this.fullname,
    required this.gender,
    required this.className,
    required this.gradeName,
    required this.schoolName,
    required this.projectName,
  });

  factory StudentDetails.fromMap(Map<String, dynamic> map) {
    return StudentDetails(
      studentID: map['student_ID'],
      fullname: map['Fullname'],
      gender: map['Gender'],
      className: map['Class_name'],
      gradeName: map['Grade_name'],
      schoolName: map['School_name'],
      projectName: map['Pro_Name'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'studentID': studentID,
      'fullname': fullname,
      'gender': gender,
      'className': className,
      'gradeName': gradeName,
      'schoolName': schoolName,
      'projectName': projectName,
    };
  }
}
