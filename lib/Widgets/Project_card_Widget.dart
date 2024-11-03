// ignore_for_file: camel_case_types, non_constant_identifier_names, file_names, prefer_const_constructors

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:pin_edu_pro/Models/Project_Model.dart';
import 'package:pin_edu_pro/Services/DataServices.dart'; // Import your data service here

class Project_car_Widget extends StatefulWidget {
  final project_model Project_Model;
  final VoidCallback onTap;

  const Project_car_Widget({
    Key? key,
    required this.Project_Model,
    required this.onTap,
  }) : super(key: key);

  @override
  State<Project_car_Widget> createState() => _Project_car_WidgetState();
}

class _Project_car_WidgetState extends State<Project_car_Widget> {
  int studentCount = 0;
  int staffCount = 0;

  @override
  void initState() {
    super.initState();
    fetchCounts();
  }

  Future<void> fetchCounts() async {
    studentCount = await getStudentCountForProject(widget.Project_Model.Pro_ID);
    staffCount = await getStaffCountForProject(widget.Project_Model.Pro_ID);

    if (mounted) {
      setState(() {});
    }
  }

  Future<int> getStudentCountForProject(int Pro_ID) async {
    final db = await SQLiteHelper().database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT COUNT(student_ID) AS count FROM students WHERE pro_ID = ?',
      [Pro_ID],
    );

    if (maps.isNotEmpty) {
      return maps.first['count'] as int;
    } else {
      return 0;
    }
  }

  Future<int> getStaffCountForProject(int Pro_ID) async {
    final db = await SQLiteHelper().database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT COUNT(staff_ID) AS count FROM staff WHERE pro_ID = ?',
      [Pro_ID],
    );

    if (maps.isNotEmpty) {
      return maps.first['count'] as int;
    } else {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 6),
      child: Card(
        color: Colors.blue.shade100,
        elevation: 2,
        child: InkWell(
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    children: [
                      const Icon(Icons.toc),
                      const SizedBox(width: 20),
                      const Text(
                        "#",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w100,
                          color: Color.fromARGB(255, 255, 254, 254),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        widget.Project_Model.Pro_ID.toString(),
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  child: Divider(
                    thickness: 1,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    children: [
                      const Icon(Icons.check_box),
                      const SizedBox(width: 20),
                      const Text(
                        'Project Name',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w100,
                          color: Color.fromARGB(255, 255, 252, 252),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Flexible(
                        child: Text(
                          widget.Project_Model.Pro_Name,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  child: Divider(
                    thickness: 1,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.code),
                    const SizedBox(width: 20),
                    const Text(
                      'Project Code',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w100,
                        color: Color.fromARGB(255, 255, 251, 251),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Flexible(
                      child: Text(
                        widget.Project_Model.Pro_Code,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  child: Divider(
                    thickness: 1,
                  ),
                ),
                const SizedBox(height: 6),
                IntrinsicHeight(
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DottedBorder(
                          color: Colors.black,
                          strokeWidth: 0.5,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  const Icon(
                                    Icons.people,
                                    color: Colors.blueAccent,
                                  ),
                                  Text(
                                    'Staff: $staffCount',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              VerticalDivider(
                                color: Colors.blueGrey,
                                thickness: 2,
                              ),
                              Column(
                                children: [
                                  const Icon(
                                    Icons.school,
                                    color: Colors.green,
                                  ),
                                  Text(
                                    'Student: $studentCount',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 5),
                            ],
                          ),
                        )))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
