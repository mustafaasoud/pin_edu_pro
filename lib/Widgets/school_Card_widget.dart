// ignore_for_file: camel_case_types, must_be_immutable, prefer_const_constructors, file_names, prefer_const_literals_to_create_immutables, non_constant_identifier_names

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pin_edu_pro/Models/School_Model.dart';
import 'package:pin_edu_pro/Services/DataServices.dart';
import 'package:pin_edu_pro/Widgets/appthem.dart';

class school_card_widget extends StatefulWidget {
  final School_Model school_model;
  final VoidCallback onTap;

  const school_card_widget({
    Key? key,
    required this.school_model,
    required this.onTap,
  }) : super(key: key);

  @override
  State<school_card_widget> createState() => _school_card_widgetState();
}

class _school_card_widgetState extends State<school_card_widget> {
  int studentCount = 0;
  int staffcount = 0;

  Future<void> fetchCounts() async {
    studentCount =
        await getStudentCountForSchool(widget.school_model.School_Name);
    staffcount = await getstaffCountForSchool(widget.school_model.School_Name);

    if (mounted) {
      setState(() {});
    }
  }

  Future<int> getStudentCountForSchool(String School_name) async {
    final db = await SQLiteHelper().database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT COUNT(student_ID) AS count FROM students WHERE school_Name = ?',
      [School_name],
    );

    if (maps.isNotEmpty) {
      return maps.first['count'] as int;
    } else {
      return 0;
    }
  }

  Future<int> getstaffCountForSchool(String School_name) async {
    final db = await SQLiteHelper().database;
    final List<Map<String, dynamic>> maps2 = await db.rawQuery(
      'SELECT COUNT(staff_ID) AS count FROM staff WHERE school_Name = ?',
      [School_name],
    );

    if (maps2.isNotEmpty) {
      return maps2.first['count'] as int;
    } else {
      return 0;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCounts();
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.8,
      child: Stack(
        children: <Widget>[
          Card(
            margin: EdgeInsets.all(16.0),
            elevation: 10,
            child: InkWell(
              onTap: widget.onTap,
              child: SizedBox(
                  height: 250,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              FontAwesomeIcons.school,
                              color: Colors.blue,
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Text(
                              widget.school_model.School_Name,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                        Divider(),
                        Text(
                          widget.school_model.Des,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.normal),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              widget.school_model.School_Code,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.card6,
                                  fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                        IntrinsicHeight(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DottedBorder(
                              color: Colors.black,
                              strokeWidth: .2,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    'اجمالي عدد الطلاب : $studentCount',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: AppTheme.card6,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        IntrinsicHeight(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DottedBorder(
                              color: Colors.black,
                              strokeWidth: .2,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    'اجمالي الكادر : $staffcount',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: AppTheme.card6,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
