// ignore_for_file: file_names, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pin_edu_pro/Services/DataServices.dart';

class StudentDetailsUI extends StatefulWidget {
  final int Student_ID;
  const StudentDetailsUI({required this.Student_ID, super.key});

  @override
  State<StudentDetailsUI> createState() => _StudentDetailsUIState();
}

class _StudentDetailsUIState extends State<StudentDetailsUI> {
  bool isEditable = false;
  Map<String, dynamic>? studentData;

  @override
  void initState() {
    super.initState();
    fetchStudentDetails();
  }

  Future fetchStudentDetails() async {
    final db = await SQLiteHelper().database;
    final res = await db.rawQuery('''
      SELECT students.student_ID, students.Fullname, students.Gender, classroom.Class_name, grades.Grade_name, shifts.Shift_Name, school.School_name, projects.Pro_Name
      FROM ((projects 
      INNER JOIN school ON projects.[Pro_ID] = school.[Pro_id]) 
      INNER JOIN students ON school.[SchoolID] = students.[School_ID]) 
      INNER JOIN ((shifts 
      INNER JOIN grades ON shifts.[Shift_ID] = grades.[Shift_ID]) 
      INNER JOIN classroom ON grades.[Grade_ID] = classroom.[Grade_ID]) 
      ON students.[Class_ID] = classroom.[Class_id]
      WHERE students.student_ID = ?;
    ''', [widget.Student_ID]);

    if (res.isNotEmpty) {
      setState(() {
        studentData = res.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (studentData == null) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Student Information"),
          leading: IconButton(
            onPressed: () {
              setState(() {});
            },
            icon: SvgPicture.asset(
              'assets/images/logo/logo.svg',
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(Icons.back_hand),
            ),
          ],
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("معلومات تفصيلية"),
        leading: IconButton(
          onPressed: () {
            setState(() {});
          },
          icon: SvgPicture.asset(
            'assets/images/logo/logo.svg',
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(Icons.back_hand),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTextField(studentData!['Fullname'], "Full Name"),
            buildTextField(studentData!['Gender'], "Gender"),
            buildTextField(studentData!['Class_name'], "Class Name"),
            buildTextField(studentData!['Grade_name'], "Grade Name"),
            buildTextField(studentData!['Shift_Name'], "Shift Name"),
            buildTextField(studentData!['School_name'], "School Name"),
            buildTextField(studentData!['Pro_Name'], "Project Name"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isEditable = !isEditable;
                });
              },
              child: Text(isEditable ? 'Save' : 'Edit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String initialValue, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: initialValue,
        readOnly: !isEditable,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
