// ignore_for_file: library_private_types_in_public_api, file_names, unused_local_variable, unnecessary_cast, deprecated_member_use, non_constant_identifier_names, unused_import, prefer_const_constructors, use_build_context_synchronously, empty_catches, unused_field

import 'package:dotted_border/dotted_border.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:pin_edu_pro/Models/Classroom_Model.dart';
import 'package:pin_edu_pro/Models/Grade_Model.dart';
import 'package:pin_edu_pro/Models/student_Model.dart';
import 'package:pin_edu_pro/Services/DataServices.dart';
import 'package:pin_edu_pro/Services/global.dart';
import 'package:pin_edu_pro/Services/socket_services.dart';
import 'package:pin_edu_pro/Widgets/appthem.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class NSRR extends StatefulWidget {
  const NSRR({super.key});

  @override
  _NSRR createState() => _NSRR();
}

class _NSRR extends State<NSRR> with SingleTickerProviderStateMixin {
  late TabController tabController;
  final _formKey = GlobalKey<FormState>();
  final FirstnameController = TextEditingController();
  final FathernameController = TextEditingController();
  final LastnameController = TextEditingController();
  final MothernameController = TextEditingController();
  final LastMothernameController = TextEditingController();
  final CareFirstnameController = TextEditingController();
  final CareLastnameController = TextEditingController();
  final Care_relation = TextEditingController();
  final PhoneNumber = TextEditingController();
  final CareID = TextEditingController();

  final time_dropped_out_learing = TextEditingController();

  final _genderController = TextEditingController();
  final Residency_Status = TextEditingController();
  final Type_disability = TextEditingController();
  final _gradeNameController = TextEditingController();
  final _classNameController = TextEditingController();
  List<Map<String, dynamic>> temp_student = [];
  // birthday
  int? _selectedDay_birthday;
  int? _selectedMonth_birthday;
  int? _selectedYear_birthday;
  // regstration
  int? _selectedDay_REG;
  int? _selectedMonth_REG;
  int? _selectedYear_REG;
  // enrollment
  int? _selectedDay_Enrollment;
  int? _selectedMonth_Enrollment;
  int? _selectedYear_Enrollment;
  //
  String? _selectedGrade;
  String? _selectedClassroom;
  String? _selectedCity;
  String? _selectedDistrict;

  final List<String> genderOptions = ['Female', 'Male'];
  String? _selectedGender;

  final List<String> Care_relation_Options = [
    'Father',
    'Mother',
    'Brother',
    'Sister',
    'Uncle',
    'Aunt',
    'Other',
    'Stepfather',
    'Stepmother',
    'Grandmother',
    'Grandfather'
  ];
  String? _selecte_Care_relation = 'Father';

  final List<String> time_dropped_out_learing_Options = [
    'Not out of School',
    'Less than 1 month',
    '1-2 months',
    '3-6 months',
    '7-11 months',
    '1-2 years'
  ];
  String? _selecte_time_dropped_out_learing;

  final List<String> Residency_Status_Options = [
    'Host community',
    'IDP',
    'Returnee',
    'Refugee'
  ];
  String? _selecte_Residency_Status;

  final List<String> Type_disability_Options = [
    'Nothing',
    'Hearing Impairment',
    'Vision Impairment',
    'Physical Disability',
    'Intellectual Disability',
    'Mental health conditions',
    'Communicating difficutly (Speaking)',
    'Autism spectrum disorder',
    'Other',
  ];
  String _selecte_Type_disability = 'Nothing';

  final List<String> Reason_Enrolment_Options = [
    'Closest school/centre available in the area',
    'Best school/center available in the area Closest school/centre available in the area priority a is Education',
    'center available in the area',
    'priority a is Education Best school/center available in the area',
    'Only school/center available in the area',
    'School/center is safest place for the child',
    'Child needs to socialize and play Child is behind in education priority a is Education',
  ];
  String? _selecte_Reason_Enrolment =
      'Closest school/centre available in the area';

  int age = 0;
  List<Grade_Model> gradeList = [];
  List<classroom_model> classroomList = [];
  List<int> days = List.generate(31, (index) => index + 1);
  List<int> Month = List.generate(12, (index) => index + 1);
  final int currentYear = DateTime.now().year;
  void _calculateAge() {
    if (_selectedDay_birthday != null &&
        _selectedMonth_birthday != null &&
        _selectedYear_birthday != null) {
      DateTime birthDate = DateTime(_selectedYear_birthday!,
          _selectedMonth_birthday!, _selectedDay_birthday!);
      DateTime today = DateTime.now();
      age = today.year - birthDate.year;

      if (birthDate.isAfter(today.subtract(Duration(days: age * 365)))) {
        age--;
      }
      setState(() {});
      if (age < 5) {
        _showUnder5Dialog();
      }
    }
  }

  void _showUnder5Dialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Age Verification'),
          content: const Text(
              'The student is under 5 years old. Please verify the age.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      insert_temp_student().then((_) {
        res_temp_student();
        _clearForm();
        setState(() {});
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      });
    }
  }

  Future<void> res() async {
    final db = await SQLiteHelper().database;
    List<Map<String, dynamic>> resgrade = await db
        .query('grades', where: 'School_Name = ?', whereArgs: [School_Name]);
    gradeList =
        List<Grade_Model>.from(resgrade.map((x) => Grade_Model.fromJson(x)));
    gradeList.sort((a, b) => a.Grade_name.compareTo(b.Grade_name));
  }

  Future<void> GetClassroom() async {
    try {
      final db = await SQLiteHelper().database;
      final List<Map<String, dynamic>> maps = await db.query('classroom',
          where: 'school_Name = ? and Grade_Name=?',
          whereArgs: [School_Name, _selectedGrade]);
      classroomList = List<classroom_model>.from(
          maps.map((x) => classroom_model.fromJson(x)));
      classroomList.sort((a, b) => a.Class_name.compareTo(b.Class_name));
      setState(() {});
    } catch (error) {}
  }

  Future<void> res_temp_student() async {
    final db = await SQLiteHelper().database;
    temp_student = await db.query('temp_reg_student',
        where: 'School_Name = ?', whereArgs: [School_Name]);
    if (temp_student.isNotEmpty) {
      setState(() {});
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    FirstnameController.clear();
    _genderController.clear();
    _gradeNameController.clear();
    _classNameController.clear();
    setState(() {
      _selectedDay_birthday = null;
      _selectedMonth_birthday = null;
      _selectedYear_birthday = null;
      _selectedDay_REG = null;
      _selectedMonth_REG = null;
      _selectedYear_REG = null;
      _selectedGrade = null;
      _selectedClassroom = null;
      _selectedGender = null;
    });
  }

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this, initialIndex: 1);
    super.initState();
    res();
    res_temp_student();
    FathernameController.addListener(() {
      CareFirstnameController.text = FathernameController.text;
    });
    LastnameController.addListener(() {
      CareLastnameController.text = LastnameController.text;
    });
  }

  // Future<bool> studentExists(String fullname) async {
  //   final db = await SQLiteHelper().database;
  //   final List<Map<String, dynamic>> result = await db.query(
  //     'students',
  //     where: 'Fullname = ?',
  //     whereArgs: [fullname],
  //   );
  //   return result.isNotEmpty;
  // }

  Future<void> insert_temp_student() async {
    final db = await SQLiteHelper().database;
 //    final bool exists = await studentExists(FirstnameController.text);
 
      final Map<String, dynamic> studentData = {
        'Firstname': FirstnameController.text,
        'Fathername': FathernameController.text,
        'Lastname': LastnameController.text,
        'Mothername': MothernameController.text,
        'LastMothername': LastMothernameController.text,
        'birthday_date':
            '$_selectedYear_birthday-$_selectedMonth_birthday-$_selectedDay_birthday',
        'reg_date': '$_selectedYear_REG-$_selectedMonth_REG-$_selectedDay_REG',
        'enroll_date':
            '$_selectedYear_Enrollment-$_selectedMonth_Enrollment-$_selectedDay_Enrollment',
        'CareFirstname': CareFirstnameController.text,
        'CareLastname': CareLastnameController.text,
        'Care_relation': _selecte_Care_relation,
        'PhoneNumber': PhoneNumber.text,
        'CareID': CareID.text,
        'Reason_Enrolment': _selecte_Reason_Enrolment,
        'time_dropped_out_learing': _selecte_time_dropped_out_learing,
        'Governorate': _selectedCity,
        'District': _selectedDistrict,
        'gender': _selectedGender,
        'Residency_Status': _selecte_Residency_Status,
        'Type_disability': _selecte_Type_disability,
        'Grade_Name': _selectedGrade,
        'classroom': _selectedClassroom,
        'school_name': School_Name,
        'status': 'waiting',
        'User': UsernameEntry,
        'pro_ID':'1'

      };
      await db.insert(
        'temp_reg_student',
        studentData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      SocketService.temp_reg_student(studentData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student data inserted successfully')),
      );
    
  }

  @override
  void dispose() {
    FirstnameController.dispose();
    _genderController.dispose();
    _classNameController.dispose();
    _gradeNameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
            title: Text('الطلبات :$UsernameEntry '),
            bottom:   TabBar(
              tabs: [
                Tab(
                  icon: Icon(FontAwesomeIcons.add, color: Colors.white),
                  text: "New Student".tr,
                ),
                Tab(
                  icon: Icon(FontAwesomeIcons.add, color: Colors.redAccent),
                  text:  'New Grade'.tr,
                ),
                Tab(
                  icon: Icon(FontAwesomeIcons.add,
                      color: Colors.lightGreenAccent),
                  text: 'New Classroom'.tr,
                ),
                Tab(
                  icon: Icon(
                    FontAwesomeIcons.paste,
                    color: Colors.amber,
                  ),
                  text: "Request".tr,
                ),
              ],
            )),
        body: TabBarView(children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8),
            child: Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  Row(
                    children: const [
                      Icon(
                        Icons.arrow_drop_down,
                        color: Colors.green,
                        size: 25,
                      ),
                      Gap(10),
                      Text(
                        'Student Personal Information',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Gap.expand(10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: TextFormField(
                          keyboardType: TextInputType.name,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the First Name';
                            }
                            return null;
                          },
                          controller: FirstnameController,
                          decoration: InputDecoration(
                            hintText: 'First Name',
                            hintStyle: const TextStyle(
                                fontSize: 15.0,
                                color: Color(0xffA9A9A9),
                                fontWeight: FontWeight.w500),
                            contentPadding: const EdgeInsets.all(15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      Gap(10),
                      Flexible(
                        child: TextFormField(
                          onFieldSubmitted: (value) {},
                          keyboardType: TextInputType.name,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the Father First Name';
                            }
                            return null;
                          },
                          controller: FathernameController,
                          decoration: InputDecoration(
                            hintText: 'Father First Name',
                            hintStyle: const TextStyle(
                                fontSize: 15.0,
                                color: Color(0xffA9A9A9),
                                fontWeight: FontWeight.w500),
                            contentPadding: const EdgeInsets.all(15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      Gap(10),
                      Flexible(
                        child: TextFormField(
                          keyboardType: TextInputType.name,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the Last Name';
                            }
                            return null;
                          },
                          controller: LastnameController,
                          decoration: InputDecoration(
                            hintText: 'Last Name',
                            hintStyle: const TextStyle(
                                fontSize: 15.0,
                                color: Color(0xffA9A9A9),
                                fontWeight: FontWeight.w500),
                            contentPadding: const EdgeInsets.all(15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(20),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: TextFormField(
                            keyboardType: TextInputType.name,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the Mother Fisrt Name';
                              }
                              return null;
                            },
                            controller: MothernameController,
                            decoration: InputDecoration(
                              hintText: 'Mother Name',
                              hintStyle: const TextStyle(
                                  fontSize: 15.0,
                                  color: Color(0xffA9A9A9),
                                  fontWeight: FontWeight.w500),
                              contentPadding: const EdgeInsets.all(15),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        Gap(10),
                        Expanded(
                          child: TextFormField(
                            keyboardType: TextInputType.name,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the Mother Last Name';
                              }
                              return null;
                            },
                            controller: LastMothernameController,
                            decoration: InputDecoration(
                              hintText: 'Mother Last Name',
                              hintStyle: const TextStyle(
                                  fontSize: 15.0,
                                  color: Color(0xffA9A9A9),
                                  fontWeight: FontWeight.w500),
                              contentPadding: const EdgeInsets.all(15),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        )
                      ]),
                  Gap(10),
                  Row(
                    children: [
                      Icon(
                        Icons.date_range,
                        color: Colors.red,
                        size: 25,
                      ),
                      Gap(10),
                      Text(
                        'Birthday',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      Gap(AppTheme.fullWidth(context) - 125),
                      Text(age.toString()),
                    ],
                  ),
                  Gap(10),
                  Row(
                    children: [
                      Flexible(
                        child: DropdownButtonFormField2(
                          dropdownStyleData: DropdownStyleData(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Day',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          items: days
                              .map((day) => DropdownMenuItem<int>(
                                    value: day,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4.0), // Adjusted padding
                                      child: Text(
                                        day.toString(),
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList(),
                          value: _selectedDay_birthday,
                          onChanged: (value) {
                            setState(() {
                              _selectedDay_birthday = value;
                              _calculateAge();
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a day';
                            }
                            return null;
                          },
                        ),
                      ),
                      Gap(5), // Reduced gap
                      Flexible(
                        child: DropdownButtonFormField2(
                          dropdownStyleData: DropdownStyleData(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Month',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          items: Month.map((month) => DropdownMenuItem<int>(
                                value: month,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0), // Adjusted padding
                                  child: Text(
                                    month.toString(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              )).toList(),
                          value: _selectedMonth_birthday,
                          onChanged: (value) {
                            setState(() {
                              _selectedMonth_birthday = value;
                              _calculateAge();
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a Month';
                            }
                            return null;
                          },
                        ),
                      ),
                      Gap(5), // Reduced gap
                      Flexible(
                        child: DropdownButtonFormField2(
                          dropdownStyleData: DropdownStyleData(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Year',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          items: List.generate(currentYear - 2006 + 1,
                              (index) => currentYear - index).map((year) {
                            return DropdownMenuItem<int>(
                              value: year,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 2.0), // Adjusted padding
                                child: Text(
                                  year.toString(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          value: _selectedYear_birthday,
                          onChanged: (value) {
                            setState(() {
                              _selectedYear_birthday = value;
                              _calculateAge();
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a Year';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  Gap(20),
                  Row(
                    children: [
                      Flexible(
                        child: DropdownButtonFormField2(
                          dropdownStyleData: DropdownStyleData(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          decoration: InputDecoration(
                            labelText: 'Gender',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          items: genderOptions
                              .map((gender) => DropdownMenuItem<String>(
                                    value: gender,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Text(
                                        gender,
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList(),
                          value: _selectedGender,
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value as String?;
                              _genderController.text = _selectedGender ?? '';
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a gender';
                            }
                            return null;
                          },
                        ),
                      ),
                      Gap(10),
                      Flexible(
                        child: DropdownButtonFormField2(
                          dropdownStyleData: DropdownStyleData(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          decoration: InputDecoration(
                            labelText: 'Residency',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          items: Residency_Status_Options.map(
                              (Res_Status_Options) => DropdownMenuItem<String>(
                                    value: Res_Status_Options,
                                    child: Text(
                                      Res_Status_Options,
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  )).toList(),
                          value: _selecte_Residency_Status,
                          onChanged: (value) {
                            setState(() {
                              _selecte_Residency_Status = value as String?;
                              Residency_Status.text =
                                  _selecte_Residency_Status ?? '';
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'select a Residency_Status';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  Gap(20),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField2(
                          dropdownStyleData: DropdownStyleData(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          decoration: InputDecoration(
                            labelText: 'Type of disability',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          items: Type_disability_Options.map(
                              (disability) => DropdownMenuItem<String>(
                                    value: disability,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Text(
                                        disability,
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  )).toList(),
                          value: _selecte_Type_disability,
                          onChanged: (value) {
                            setState(() {
                              _selecte_Type_disability = value as String;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'select Type of disability';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  Gap(20),
                  Row(
                    children: const [
                      Icon(
                        Icons.private_connectivity_outlined,
                        color: Colors.green,
                        size: 25,
                      ),
                      Gap(10),
                      Text(
                        "Phone Number And ID Information",
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      Flexible(
                        child: TextFormField(
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter PhoneNumber';
                            }
                            return null;
                          },
                          controller: PhoneNumber,
                          decoration: InputDecoration(
                            hintText: 'Phone Number',
                            hintStyle: const TextStyle(
                                fontSize: 15.0,
                                color: Color(0xffA9A9A9),
                                fontWeight: FontWeight.w500),
                            contentPadding: const EdgeInsets.all(15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      Gap(10),
                      Flexible(
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter ID';
                            }
                            return null;
                          },
                          controller: CareID,
                          decoration: InputDecoration(
                            hintText: 'ID',
                            hintStyle: const TextStyle(
                                fontSize: 15.0,
                                color: Color(0xffA9A9A9),
                                fontWeight: FontWeight.w500),
                            contentPadding: const EdgeInsets.all(15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Gap(10),
                  Row(
                    children: const [
                      Icon(
                        Icons.arrow_drop_down,
                        color: Colors.green,
                        size: 25,
                      ),
                      Gap(10),
                      Text(
                        "Caregiver's  Personal Information",
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),

// معلومات مقدم الرعاية
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: TextFormField(
                          keyboardType: TextInputType.name,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the Caregiver First Name';
                            }
                            return null;
                          },
                          controller: CareFirstnameController,
                          decoration: InputDecoration(
                            hintText: 'Caregiver First Name',
                            hintStyle: const TextStyle(
                                fontSize: 15.0,
                                color: Color(0xffA9A9A9),
                                fontWeight: FontWeight.w500),
                            contentPadding: const EdgeInsets.all(15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      Gap(10),
                      Expanded(
                        child: TextFormField(
                          keyboardType: TextInputType.name,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the Caregiver Last Name';
                            }
                            return null;
                          },
                          controller: CareLastnameController,
                          decoration: InputDecoration(
                            hintText: 'Caregiver Last Name',
                            hintStyle: const TextStyle(
                                fontSize: 15.0,
                                color: Color(0xffA9A9A9),
                                fontWeight: FontWeight.w500),
                            contentPadding: const EdgeInsets.all(15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Gap(10),

                  /// Caregiver relation
                  Row(
                    children: [
                      Flexible(
                        child: DropdownButtonFormField2(
                          dropdownStyleData: DropdownStyleData(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          decoration: InputDecoration(
                            labelText: "Choose a Caregiver Relation",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          items: Care_relation_Options.map(
                            (String Care_relation) => DropdownMenuItem<String>(
                              value: Care_relation,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(Care_relation),
                              ),
                            ),
                          ).toList(),
                          value: _selecte_Care_relation,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selecte_Care_relation = newValue;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a Caregiver relation';
                            }
                            return null;
                          },
                        ),
                      )
                    ],
                  ),
                  Gap(20),

                  Row(
                    children: [
                      Flexible(
                        child: DropdownButtonFormField2(
                          dropdownStyleData: DropdownStyleData(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          decoration: InputDecoration(
                            labelText: "Choose a City",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          items: syriaCitiesAndDistricts.keys
                              .map((String city) => DropdownMenuItem<String>(
                                    value: city,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Text(city),
                                    ),
                                  ))
                              .toList(),
                          value: _selectedCity,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCity = newValue;
                              _selectedDistrict = null;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Choose a City';
                            }
                            return null;
                          },
                        ),
                      ),
                      Gap(5),
                      Flexible(
                        child: DropdownButtonFormField2(
                          isExpanded: true,
                          dropdownStyleData: DropdownStyleData(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          decoration: InputDecoration(
                            labelText: "Choose a District",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          items: _selectedCity != null
                              ? syriaCitiesAndDistricts[_selectedCity!]!
                                  .map((String district) {
                                  return DropdownMenuItem<String>(
                                      value: district,
                                      child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: RichText(
                                              text: TextSpan(children: [
                                            TextSpan(
                                                style: TextStyle(
                                                    color: Colors.black),
                                                text: district),
                                          ]))));
                                }).toList()
                              : [],
                          value: _selectedDistrict,
                          onChanged: (value) {
                            setState(() {
                              _selectedDistrict = value.toString();
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please Choose a District';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  Gap(20),
                  Row(
                    children: [
                      Flexible(
                        child: DropdownButtonFormField2(
                          isExpanded: true,
                          dropdownStyleData: DropdownStyleData(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          decoration: InputDecoration(
                            labelText: "Choose a Reason_Enrolment",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          items: Reason_Enrolment_Options.map(
                              (String Reason_Enrolment) {
                            return DropdownMenuItem<String>(
                                value: Reason_Enrolment,
                                child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: RichText(
                                        text: TextSpan(children: [
                                      TextSpan(
                                          style: TextStyle(color: Colors.black),
                                          text: Reason_Enrolment),
                                    ]))));
                          }).toList(),
                          value: _selecte_Reason_Enrolment,
                          onChanged: (value) {
                            setState(() {
                              _selecte_Reason_Enrolment = value.toString();
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please Choose a Reason Enrolment';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  Gap(10),
                  Row(
                    children: const [
                      Icon(
                        Icons.school,
                        color: Colors.blueGrey,
                        size: 25,
                      ),
                      Gap(10),
                      Text(
                        'Grade and Classroom',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Gap(5),
                  Row(
                    children: [
                      Flexible(
                        child: DropdownButtonFormField2(
                          dropdownStyleData: DropdownStyleData(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          decoration: InputDecoration(
                            labelText: 'Grade',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          items: gradeList
                              .map((Grade) => DropdownMenuItem<String>(
                                    value: Grade.Grade_name,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Text(
                                        Grade.Grade_name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList(),
                          value: _selectedGrade,
                          onChanged: (value) {
                            setState(() {
                              _selectedGrade = value;
                              _gradeNameController.text = _selectedGrade!;
                              GetClassroom();
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a grade';
                            }
                            return null;
                          },
                        ),
                      ),
                      Gap(10),
                      Flexible(
                        child: DropdownButtonFormField2(
                          dropdownStyleData: DropdownStyleData(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          decoration: InputDecoration(
                            labelText: 'classroom',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          items: classroomList
                              .map((classroom) => DropdownMenuItem<String>(
                                    value: classroom.Class_name,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Text(
                                        classroom.Class_name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList(),
                          value: _selectedClassroom,
                          onChanged: (value) {
                            setState(() {
                              _selectedClassroom = value;
                              _classNameController.text = _selectedClassroom!;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a classroom';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  Gap(20),
                  Row(
                    children: [
                      Flexible(
                        child: DropdownButtonFormField2(
                          dropdownStyleData: DropdownStyleData(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          decoration: InputDecoration(
                            labelText: 'time dropped out learing Options',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          items: time_dropped_out_learing_Options
                              .map((dropped) => DropdownMenuItem<String>(
                                    value: dropped,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Text(
                                        dropped,
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList(),
                          value: _selecte_time_dropped_out_learing,
                          onChanged: (value) {
                            setState(() {
                              _selecte_time_dropped_out_learing =
                                  value.toString();
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a time dropped out learing Options';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  Gap(10),
                  Row(
                    children: const [
                      Icon(
                        Icons.arrow_drop_down,
                        color: Colors.green,
                        size: 25,
                      ),
                      Text(
                        'Student Regstration date',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: Colors.green,
                        size: 25,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: DropdownButtonFormField<int>(
                          decoration: InputDecoration(
                            hintText: 'Day',
                            hintStyle: const TextStyle(
                              fontSize: 14.0,
                              color: Color(0xffA9A9A9),
                              fontWeight: FontWeight.w500,
                            ),
                            contentPadding: const EdgeInsets.all(15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          value: _selectedDay_REG,
                          items: days.map((day) {
                            return DropdownMenuItem<int>(
                              value: day,
                              child: Text(day.toString()),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedDay_REG = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a day';
                            }
                            return null;
                          },
                        ),
                      ),
                      Gap(10),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          decoration: InputDecoration(
                            hintText: 'Month',
                            hintStyle: const TextStyle(
                              fontSize: 14.0,
                              color: Color(0xffA9A9A9),
                              fontWeight: FontWeight.w500,
                            ),
                            contentPadding: const EdgeInsets.all(15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          value: _selectedMonth_REG,
                          items: Month.map((month) {
                            return DropdownMenuItem<int>(
                              value: month,
                              child: Text(month.toString()),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedMonth_REG = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a month';
                            }
                            return null;
                          },
                        ),
                      ),
                      Gap(10),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          decoration: InputDecoration(
                            hintText: 'Year',
                            hintStyle: const TextStyle(
                              fontSize: 14.0,
                              color: Color(0xffA9A9A9),
                              fontWeight: FontWeight.w500,
                            ),
                            contentPadding: const EdgeInsets.all(15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          value: _selectedYear_REG,
                          items: List.generate(currentYear - currentYear + 1,
                              (index) => currentYear - index).map((year) {
                            return DropdownMenuItem<int>(
                              value: year,
                              child: Text(year.toString()),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedYear_REG = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a year';
                            }
                            return null;
                          },
                        ),
                      ),
                      const Gap(10),
                    ],
                  ),
                  Gap(10),
                  Row(
                    children: const [
                      Icon(
                        Icons.arrow_drop_down,
                        color: Colors.green,
                        size: 25,
                      ),
                      Text(
                        'Student Enroll date',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: Colors.green,
                        size: 25,
                      ),
                    ],
                  ),
                  Gap(10),
                  Row(
                    children: [
                      Flexible(
                        child: DropdownButtonFormField<int>(
                          decoration: InputDecoration(
                            hintText: 'Day',
                            hintStyle: const TextStyle(
                              fontSize: 14.0,
                              color: Color(0xffA9A9A9),
                              fontWeight: FontWeight.w500,
                            ),
                            contentPadding: const EdgeInsets.all(15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          value: _selectedDay_Enrollment,
                          items: days.map((day) {
                            return DropdownMenuItem<int>(
                              value: day,
                              child: Text(day.toString()),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedDay_Enrollment = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select Enrollment Day';
                            }
                            return null;
                          },
                        ),
                      ),
                      Gap(10),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          decoration: InputDecoration(
                            hintText: 'Month',
                            hintStyle: const TextStyle(
                              fontSize: 14.0,
                              color: Color(0xffA9A9A9),
                              fontWeight: FontWeight.w500,
                            ),
                            contentPadding: const EdgeInsets.all(15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          value: _selectedMonth_Enrollment,
                          items: Month.map((month) {
                            return DropdownMenuItem<int>(
                              value: month,
                              child: Text(month.toString()),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedMonth_Enrollment = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select Enrollment month';
                            }
                            return null;
                          },
                        ),
                      ),
                      Gap(10),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          decoration: InputDecoration(
                            hintText: 'Year',
                            hintStyle: const TextStyle(
                              fontSize: 14.0,
                              color: Color(0xffA9A9A9),
                              fontWeight: FontWeight.w500,
                            ),
                            contentPadding: const EdgeInsets.all(15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          value: _selectedYear_Enrollment,
                          items: List.generate(currentYear - currentYear + 1,
                              (index) => currentYear - index).map((year) {
                            return DropdownMenuItem<int>(
                              value: year,
                              child: Text(year.toString()),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedYear_Enrollment = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select Enrollment year';
                            }
                            return null;
                          },
                        ),
                      ),
                      const Gap(10),
                    ],
                  ),
                  Gap(10),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
          Container(),
          Container(),
          Container(),
        ]),
      ),
    );
  }
}
