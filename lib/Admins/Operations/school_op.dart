// ignore_for_file: camel_case_types, non_constant_identifier_names, unused_import, unused_field, empty_catches, avoid_print, unused_element

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:pin_edu_pro/Admins/AdminUI.dart';
import 'package:pin_edu_pro/Services/DataServices.dart';
import 'package:pin_edu_pro/Widgets/appthem.dart';

class school_op_UI extends StatefulWidget {
  const school_op_UI({super.key});

  @override
  State<school_op_UI> createState() => _school_op_UIState();
}

class _school_op_UIState extends State<school_op_UI> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> projectslist = [];
  List<Map<String, dynamic>> schoollist = [];
  List<Map<String, dynamic>> academicYearList = [];
  List<Map<String, dynamic>> monthslist = [];
  String? _selectproject;
  String? _selectschool;
  int _selectedYearIndex = 0;
  String? ArabicMonthName;
  int? lastMonthId;
  Future<void> getprojects() async {
    try {
      List<Map<String, dynamic>> res =
          await SQLiteHelper().queryAllRows('projects');
      for (var row in res) {
        projectslist.add({
          'Pro_ID': row['Pro_ID'],
          'Pro_Name': row['Pro_Name'],
          'Pro_Code': row['Pro_Code'],
        });
      }
      if (projectslist.isNotEmpty) {
        setState(() {
          getschool();
        });
      }
    } catch (e) {
    }
  }

  Future<void> getschool() async {
    try {
      List<Map<String, dynamic>> res =
          await SQLiteHelper().queryAllRows('school');
      for (var row in res) {
        schoollist.add({
          'School_Name': row['School_Name'],
          'School_Code': row['School_Code'],
          'Pro_id': row['Pro_id'],
        });
      }
      if (schoollist.isNotEmpty) {
        setState(() {});
      }
    } catch (e) {
      print("Error fetching projectslist: $e");
    }
  }

  Future<void> getAcademicYear() async {
    try {
      List<Map<String, dynamic>> res =
          await SQLiteHelper().queryAllRows('academic_year');
      for (var row in res) {
        academicYearList.add({
          'id': row['id'],
          'start_date': row['start_date'],
          'end_date': row['end_date'],
        });
      }

      if (academicYearList.isNotEmpty) {
        getprojects();
        DateTime now = DateTime.now();

        setState(() {
          for (var year in academicYearList) {
            DateTime startDate = DateTime.parse(year['start_date']);
            if (startDate.year == now.year) {
              _selectedYearIndex = year['id'];
              getmonth(year['id'].toString());
              break;
            }
          }
        });
      }
    } catch (e) {
      print("Error fetching academic years: $e");
    }
  }

  Future<void> getmonth(String x) async {
    try {
      monthslist.clear();
      List<Map<String, dynamic>> res = await SQLiteHelper()
          .queryAllRowswithcondition('months', "year_id = ?", x);
      for (var row in res) {
        monthslist.add({
          'id': row['id'],
          'year_id': row['year_id'],
          'month': row['month'],
        });
      }
      if (monthslist.isNotEmpty) {
        setState(() {});
      }
    } catch (e) {
      print("Error fetching months: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    getAcademicYear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('School Mangment'.tr), actions: [
        const Gap(10),
        IconButton(
            splashRadius: 25,
            onPressed: () {
              Get.offAll(() => const AdminUI());
            },
            icon: const Icon(Icons.home)),
      ]),
      body: ListView(
        children: [
          const Gap(10),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Flexible(
                  child: DropdownButtonFormField2(
                    dropdownStyleData: DropdownStyleData(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Project Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    items: projectslist
                        .map((pro) => DropdownMenuItem<String>(
                              value: pro['Pro_Name'].toString(),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4.0), // Adjusted padding
                                child: Text(
                                  pro['Pro_Name'].toString(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                    value: _selectproject,
                    onChanged: (value) {
                      setState(() {
                        print(value);
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select project';
                      }
                      return null;
                    },
                  ),
                ),
                const Gap(5),
                Flexible(
                  flex: 2,
                  child: DropdownButtonFormField2(
                    dropdownStyleData: DropdownStyleData(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    decoration: InputDecoration(
                      hintText: 'School Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    items: schoollist
                        .map((school) => DropdownMenuItem<String>(
                              value: school['School_Name'].toString(),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4.0), // Adjusted padding
                                child: Text(
                                  school['School_Name'].toString(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                    value: _selectschool,
                    onChanged: (value) {
                      setState(() {
                        print(value);
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select school';
                      }
                      return null;
                    },
                  ),
                ),
                const Gap(10),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                      onPressed: () {},
                      child: const Row(
                        children: [
                          Gap(10),
                          Icon(FontAwesomeIcons.solidFileExcel),
                          Gap(10),
                          Text('Export To Excel'),
                        ],
                      )),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  _getMonthName(int monthNumber) {
    switch (monthNumber) {
      case 1:
        return 'كانون الثاني';
      case 2:
        return 'شباط';
      case 3:
        return 'آذار';
      case 4:
        return 'نيسان';
      case 5:
        return 'أيار';
      case 6:
        return 'حزيران';
      case 7:
        return 'تموز';
      case 8:
        return 'آب';
      case 9:
        return 'أيلول';
      case 10:
        return 'تشرين الأول';
      case 11:
        return 'تشرين الثاني';
      case 12:
        return 'كانون الأول';
      default:
        return 'كانون الثاني'; // Default to January if the month number is invalid
    }
  }

  _getMonthNameEN(int monthNumber) {
    switch (monthNumber) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return 'January'; // Default to January if the month number is invalid
    }
  }
}
