// ignore_for_file: non_constant_identifier_names, camel_case_types, unused_local_variable, avoid_print, file_names

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:pin_edu_pro/Models/Grade_Model.dart';
import 'package:pin_edu_pro/Services/DataServices.dart';
import 'package:pin_edu_pro/Widgets/appthem.dart';

class Widgate_Grade extends StatefulWidget {
  final String School_Name;

  const Widgate_Grade({required this.School_Name, super.key});

  @override
  State<Widgate_Grade> createState() => _Widgate_GradeState();
}

class _Widgate_GradeState extends State<Widgate_Grade> {
  List<Map<String, dynamic>> gradeCounts = [];
  late List<Grade_Model> Grade_List_Temp = [];
  int totalStudents = 0;

  @override
  void initState() {
    super.initState();
    fetchCounts();
  }

  Future<void> fetchCounts() async {
    List<Grade_Model> grades = await getGrade(widget.School_Name);
    setState(() {
      Grade_List_Temp = grades;
    });
  }

  Future<List<Grade_Model>> getGrade(String school_Name) async {
    final db = await SQLiteHelper().database;
    final List<Map<String, dynamic>> gradeMaps = await db.query(
      'grades',
      where: 'school_Name = ? ',
      whereArgs: [school_Name],
    );

    List<Grade_Model> grades =
        List<Grade_Model>.from(gradeMaps.map((x) => Grade_Model.fromJson(x)));
    grades.sort((a, b) => a.Grade_name.compareTo(b.Grade_name));

    return grades;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            DataTable(
              headingRowColor: MaterialStateColor.resolveWith((states) =>
                  Colors.blue.shade200), // Color for the heading row
              dataRowColor: MaterialStateColor.resolveWith(
                  (states) => Colors.white), // Color for the data rows
              headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white), // Text style for the heading row text
              dataTextStyle: const TextStyle(
                  color: Colors.black), // Text style for the data row text
              columnSpacing:
                  AppTheme.fullWidth(context) / 2, // Spacing between columns
              columns:   [
                DataColumn(label: Text('Grade'.tr)),
                DataColumn(label: Text('total'.tr)),
              ],
              rows: Grade_List_Temp.map((gradeModel) {
                return DataRow(cells: [
                  DataCell(Text(gradeModel.Grade_name)),
                  DataCell(GradeCountWidget(
                    grade_Name: gradeModel.Grade_name,
                    onUpdate: (count) {
                      setState(() {
                        totalStudents += count;
                      });
                    },
                    School_Name: widget.School_Name,
                  )),
                ]);
              }).toList(),
            ),
            const Gap(10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                DottedBorder(
                  color: Colors.black,
                  strokeWidth: 0.5,
                  child: Container(
                    width: 200,
                    color: Colors.amber,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Center(
                      child: Text(
                        '${'total'.tr} $totalStudents',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class GradeCountWidget extends StatefulWidget {
  final String grade_Name;
  final String School_Name;
  final ValueChanged<int> onUpdate;

  const GradeCountWidget({
    required this.grade_Name,
    required this.School_Name,
    required this.onUpdate,
    Key? key,
  }) : super(key: key);

  @override
  State<GradeCountWidget> createState() => _GradeCountWidgetState();
}

class _GradeCountWidgetState extends State<GradeCountWidget> {
  int studentCount = 0;

  @override
  void initState() {
    super.initState();
    fetchStudentCount();
  }

  Future<void> fetchStudentCount() async {
    final db = await SQLiteHelper().database;
    final List<Map<String, dynamic>> countResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM students WHERE Grade_Name = ? and School_Name = ?',
      [widget.grade_Name, widget.School_Name],
    );

    int count = countResult.isNotEmpty ? countResult.first['count'] as int : 0;

    setState(() {
      studentCount = count;
    });

    widget.onUpdate(count); // Notify parent of the student count
  }

  @override
  Widget build(BuildContext context) {
    return Text(studentCount.toString());
  }
}
