// ignore_for_file: camel_case_types, non_constant_identifier_names, file_names

class student_model {
  int? student_ID;
  String? firstname;
  String? fathername;
  String? lastname;
  String? mothername;
  String? lastMothername;
  String? birthdayDate;
  String? regDate;
  String? enrollDate;
  String? careFirstname;
  String? careLastname;
  String? careRelation;
  String? phoneNumber;
  String? careID;
  String? reasonEnrolment;
  String? timeDroppedOutLearning;
  String? governorate;
  String? district;
  String? gender;
  String? residencyStatus;
  String? typeDisability;
  String? gradeName;
  String? Class_Name;
  String? schoolName;
  int? proID;

  // Constructor
  student_model({
    this.student_ID,
    this.firstname,
    this.fathername,
    this.lastname,
    this.mothername,
    this.lastMothername,
    this.birthdayDate,
    this.regDate,
    this.enrollDate,
    this.careFirstname,
    this.careLastname,
    this.careRelation,
    this.phoneNumber,
    this.careID,
    this.reasonEnrolment,
    this.timeDroppedOutLearning,
    this.governorate,
    this.district,
    this.gender,
    this.residencyStatus,
    this.typeDisability,
    this.gradeName,
    this.Class_Name,
    this.schoolName,
    this.proID,
  });

  // Convert a Student object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'student_ID': student_ID,
      'Firstname': firstname,
      'Fathername': fathername,
      'Lastname': lastname,
      'Mothername': mothername,
      'LastMothername': lastMothername,
      'birthday_date': birthdayDate,
      'reg_date': regDate,
      'enroll_date': enrollDate,
      'CareFirstname': careFirstname,
      'CareLastname': careLastname,
      'Care_relation': careRelation,
      'PhoneNumber': phoneNumber,
      'CareID': careID,
      'Reason_Enrolment': reasonEnrolment,
      'time_dropped_out_learing': timeDroppedOutLearning,
      'Governorate': governorate,
      'District': district,
      'gender': gender,
      'Residency_Status': residencyStatus,
      'Type_disability': typeDisability,
      'Grade_Name': gradeName,
      'Class_Name': Class_Name,
      'school_name': schoolName,
      'pro_ID': proID,
    };
  }

  // Convert a Map object into a Student object
  factory student_model.fromMap(Map<String, dynamic> map) {
    return student_model(
      student_ID: map['student_ID'],
      firstname: map['Firstname'],
      fathername: map['Fathername'],
      lastname: map['Lastname'],
      mothername: map['Mothername'],
      lastMothername: map['LastMothername'],
      birthdayDate: map['birthday_date'],
      regDate: map['reg_date'],
      enrollDate: map['enroll_date'],
      careFirstname: map['CareFirstname'],
      careLastname: map['CareLastname'],
      careRelation: map['Care_relation'],
      phoneNumber: map['PhoneNumber'],
      careID: map['CareID'],
      reasonEnrolment: map['Reason_Enrolment'],
      timeDroppedOutLearning: map['time_dropped_out_learing'],
      governorate: map['Governorate'],
      district: map['District'],
      gender: map['gender'],
      residencyStatus: map['Residency_Status'],
      typeDisability: map['Type_disability'],
      gradeName: map['Grade_Name'],
      Class_Name: map['Class_Name'],
      schoolName: map['school_name'],
      proID: map['pro_ID'],
    );
  }

  // Convert a JSON object into a Student object
  factory student_model.fromJson(Map<String, dynamic> json) {
    return student_model(
      student_ID: json['student_ID'],
      firstname: json['Firstname'],
      fathername: json['Fathername'],
      lastname: json['Lastname'],
      mothername: json['Mothername'],
      lastMothername: json['LastMothername'],
      birthdayDate: json['birthday_date'],
      regDate: json['reg_date'],
      enrollDate: json['enroll_date'],
      careFirstname: json['CareFirstname'],
      careLastname: json['CareLastname'],
      careRelation: json['Care_relation'],
      phoneNumber: json['PhoneNumber'],
      careID: json['CareID'],
      reasonEnrolment: json['Reason_Enrolment'],
      timeDroppedOutLearning: json['time_dropped_out_learing'],
      governorate: json['Governorate'],
      district: json['District'],
      gender: json['gender'],
      residencyStatus: json['Residency_Status'],
      typeDisability: json['Type_disability'],
      gradeName: json['Grade_Name'],
      Class_Name: json['Class_Name'],
      schoolName: json['school_name'],
      proID: json['pro_ID'],
    );
  }

  // Convert a Student object into a JSON object
  Map<String, dynamic> toJson() {
    return {
      'student_ID': student_ID,
      'Firstname': firstname,
      'Fathername': fathername,
      'Lastname': lastname,
      'Mothername': mothername,
      'LastMothername': lastMothername,
      'birthday_date': birthdayDate,
      'reg_date': regDate,
      'enroll_date': enrollDate,
      'CareFirstname': careFirstname,
      'CareLastname': careLastname,
      'Care_relation': careRelation,
      'PhoneNumber': phoneNumber,
      'CareID': careID,
      'Reason_Enrolment': reasonEnrolment,
      'time_dropped_out_learing': timeDroppedOutLearning,
      'Governorate': governorate,
      'District': district,
      'gender': gender,
      'Residency_Status': residencyStatus,
      'Type_disability': typeDisability,
      'Grade_Name': gradeName,
      'Class_Name': Class_Name,
      'school_name': schoolName,
      'pro_ID': proID,
    };
  }
}
