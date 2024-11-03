// ignore_for_file: non_constant_identifier_names, file_names, camel_case_types, deprecated_member_use

import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pin_edu_pro/Admins/AdminUI.dart';
import 'package:pin_edu_pro/Services/DataServices.dart';
import 'package:pin_edu_pro/Services/socket_services.dart';

class student_temp_status extends StatefulWidget {
  const student_temp_status({super.key});

  @override
  State<student_temp_status> createState() => _student_temp_statusState();
}

class _student_temp_statusState extends State<student_temp_status>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> temp_student = [];
  List<Map<String, dynamic>> filteredStudents = [];
  List<bool> _selectedStudents = [];
  bool _selectAll = false;
  String? _selectedStatus;

  Future<void> res_temp_student() async {
    filteredStudents.clear();
    temp_student.clear();
    final db = await SQLiteHelper().database;
    List<Map<String, dynamic>> rawTempStudent =
        await db.query('temp_reg_student');
    temp_student = rawTempStudent
        .map((student) => Map<String, dynamic>.from(student))
        .toList();
    _selectedStudents = List<bool>.filled(temp_student.length, false);
    filteredStudents = temp_student;
    if (temp_student.isNotEmpty) {
      setState(() {});
    }
  }

  updateAllStudentsStatus(int i) async {
    final db = await SQLiteHelper().database;
    await db.update(
      'temp_reg_student',
      {'status': filteredStudents[i]['status']},
      where: 'tmp_id = ?',
      whereArgs: [filteredStudents[i]['tmp_id']],
    );
  }

  synctoserver() async {
    List<Map<String, dynamic>> res =
        await SQLiteHelper().queryAllRows("temp_reg_student");

    SocketService.update_temp_reg_student(res);
  }

  Future<void> exportToExcel() async {
    // Create a new Excel document
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];
    List<CellValue> dataList = [
      const TextCellValue("tmp_id"),
      const TextCellValue("Firstname"),
      const TextCellValue("Fathername"),
      const TextCellValue("Lastname"),
      const TextCellValue("Mothername"),
      const TextCellValue("LastMothername"),
      const TextCellValue("birthday_date"),
      const TextCellValue("reg_date"),
      const TextCellValue("enroll_date"),
      const TextCellValue("CareFirstname"),
      const TextCellValue("CareLastname"),
      const TextCellValue("Care_relation"),
      const TextCellValue("PhoneNumber"),
      const TextCellValue("CareID"),
      const TextCellValue("Reason_Enrolment"),
      const TextCellValue("time_dropped_out_learing"),
      const TextCellValue("Governorate"),
      const TextCellValue("District"),
      const TextCellValue("gender"),
      const TextCellValue("Residency_Status"),
      const TextCellValue("Type_disability"),
      const TextCellValue("grade"),
      const TextCellValue("classroom"),
      const TextCellValue("school_name"),
      const TextCellValue("status"),
      const TextCellValue("User"),
    ];

    sheetObject.insertRowIterables(dataList, 0);
    for (var student in temp_student) {
      sheetObject.appendRow([
        TextCellValue(student["tmp_id"].toString()),
        TextCellValue(student["Firstname"].toString()),
        TextCellValue(student["Fathername"].toString()),
        TextCellValue(student["Lastname"].toString()),
        TextCellValue(student["Mothername"].toString()),
        TextCellValue(student["LastMothername"].toString()),
        TextCellValue(student["birthday_date"].toString()),
        TextCellValue(student["reg_date"].toString()),
        TextCellValue(student["enroll_date"].toString()),
        TextCellValue(student["CareFirstname"].toString()),
        TextCellValue(student["CareLastname"].toString()),
        TextCellValue(student["Care_relation"].toString()),
        TextCellValue(student["PhoneNumber"].toString()),
        TextCellValue(student["CareID"].toString()),
        TextCellValue(student["Reason_Enrolment"].toString()),
        TextCellValue(student["time_dropped_out_learing"].toString()),
        TextCellValue(student["Governorate"].toString()),
        TextCellValue(student["District"].toString()),
        TextCellValue(student["gender"].toString()),
        TextCellValue(student["Residency_Status"].toString()),
        TextCellValue(student["Type_disability"].toString()),
        TextCellValue(student["grade"].toString()),
        TextCellValue(student["classroom"].toString()),
        TextCellValue(student["school_name"].toString()),
        TextCellValue(student["status"].toString()),
        TextCellValue(student["User"].toString()),
      ]);
    }

    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/temp_student.xlsx";
    final file = File(path);
    await file.writeAsBytes(excel.encode()!);
  }

  TextEditingController search_First_Name_Controller = TextEditingController();
  TextEditingController search_Father_Name_Controller = TextEditingController();
  TextEditingController search_last_Name_Controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    res_temp_student();
  }

  void filterList(String query) {
    setState(() {
      filteredStudents = temp_student.where((student) {
        final firstname = student['Firstname'].toString().toLowerCase();
        final fathername = student['Fathername'].toString().toLowerCase();
        final lastname = student['Lastname'].toString().toLowerCase();
        final searchQuery = query.toLowerCase();
        return firstname.contains(searchQuery) ||
            fathername.contains(searchQuery) ||
            lastname.contains(searchQuery);
      }).toList();
      _selectedStudents = List<bool>.filled(filteredStudents.length, false);
      _selectAll = false;
    });
  }

  void filterByStatus(String? status) {
    setState(() {
      _selectedStatus = status;
      filteredStudents = temp_student.where((student) {
        if (status == null || status.isEmpty) return true;
        return student['status'] == status;
      }).toList();
      _selectedStudents = List<bool>.filled(filteredStudents.length, false);
      _selectAll = false;
    });
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      _selectAll = value ?? false;
      _selectedStudents =
          List<bool>.filled(filteredStudents.length, _selectAll);
    });
  }

  Widget _buildStatusDropdown(int index, String status) {
    Color color;
    switch (status) {
      case 'approved':
        color = Colors.green;
        break;
      case 'denied':
        color = Colors.red;
        break;
      case 'waiting':
      default:
        color = Colors.orange;
        break;
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButton<String>(
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        focusColor: color,
        value: status,
        items: [
          DropdownMenuItem(
            value: 'approved',
            child: Text('approved'.tr),
          ),
          DropdownMenuItem(
            value: 'denied',
            child: Text('denied'.tr),
          ),
          DropdownMenuItem(
            value: 'waiting',
            child: Text('waiting'.tr),
          ),
        ],
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              filteredStudents[index]['status'] = newValue;
            });
          }
        },
        style: const TextStyle(
            color: Colors.black), // Text color inside the dropdown
        dropdownColor: color, // Dropdown background color
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Request'.tr), actions: [
        const Gap(10),
        IconButton(
            splashRadius: 25,
            onPressed: () {
              Get.offAll(() => const AdminUI());
            },
            icon: const Icon(Icons.home)),
        const Gap(10),
        IconButton(
            splashRadius: 25,
            onPressed: () {
              exportToExcel();
            },
            icon: const Icon(FontAwesomeIcons.fileExcel)),
        const Gap(10),
        IconButton(
            splashRadius: 25,
            onPressed: () {
              synctoserver();
            },
            icon: const Icon(FontAwesomeIcons.sync))
      ]),
      body: Column(
        children: [
          const Gap(10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Flexible(
                  flex: 1,
                  child: TextField(
                    controller: search_First_Name_Controller,
                    decoration: InputDecoration(
                      hintText: 'Student First Name'.tr,
                      hintStyle: const TextStyle(
                          fontSize: 15.0,
                          color: Color(0xffA9A9A9),
                          fontWeight: FontWeight.w500),
                      contentPadding: const EdgeInsets.all(15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color.fromARGB(255, 68, 95, 248),
                      ),
                    ),
                    onChanged: filterList,
                  ),
                ),
                const Gap(10),
                Flexible(
                  flex: 1,
                  child: TextField(
                    controller: search_Father_Name_Controller,
                    decoration: InputDecoration(
                      hintText: 'Student Father Name'.tr,
                      hintStyle: const TextStyle(
                          fontSize: 15.0,
                          color: Color(0xffA9A9A9),
                          fontWeight: FontWeight.w500),
                      contentPadding: const EdgeInsets.all(15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color.fromARGB(255, 68, 95, 248),
                      ),
                    ),
                    onChanged: filterList,
                  ),
                ),
                const Gap(10),
                Flexible(
                  flex: 1,
                  child: TextField(
                    controller: search_last_Name_Controller,
                    decoration: InputDecoration(
                      hintText: 'Student Last Name'.tr,
                      hintStyle: const TextStyle(
                          fontSize: 15.0,
                          color: Color(0xffA9A9A9),
                          fontWeight: FontWeight.w500),
                      contentPadding: const EdgeInsets.all(15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color.fromARGB(255, 68, 95, 248),
                      ),
                    ),
                    onChanged: filterList,
                  ),
                ),
              ],
            ),
          ),
          const Gap(10),
          if (temp_student.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        border: TableBorder.all(
                          color: Colors.black, // Border color for cells
                          width: 0.2, // Border width for cells
                        ),
                        columns: [
                          DataColumn(
                            label: Row(
                              children: [
                                Checkbox(
                                  value: _selectAll,
                                  onChanged: _toggleSelectAll,
                                ),
                                const Gap(10),
                                Text("Select All".tr)
                              ],
                            ),
                          ),
                          DataColumn(
                            label: Text('Student Full Name'.tr),
                          ),
                          DataColumn(
                            label: Flexible(
                              flex: 1,
                              child: DropdownButtonFormField2(
                                decoration: InputDecoration(
                                  border: InputBorder.none, // Remove underline
                                  hintText: "Status".tr,
                                  prefixIcon: const Icon(
                                    Icons.menu,
                                    color: Color.fromARGB(255, 44, 176, 216),
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                      value: '',
                                      child: Text(
                                        'All',
                                      )),
                                  DropdownMenuItem(
                                      value: 'approved',
                                      child: Text('approved')),
                                  DropdownMenuItem(
                                      value: 'denied', child: Text('denied')),
                                  DropdownMenuItem(
                                      value: 'waiting', child: Text('waiting')),
                                ],
                                value: _selectedStatus,
                                onChanged: filterByStatus,
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select Status';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          const DataColumn(
                            label: Text('UpDate'),
                          ),
                        ],
                        rows: List<DataRow>.generate(
                          filteredStudents.length,
                          (index) {
                            // Determine the row color based on the status
                            Color rowColor;
                            switch (filteredStudents[index]['status']) {
                              case 'approved':
                                rowColor = Colors.green.withOpacity(0.2);
                                break;
                              case 'denied':
                                rowColor = Colors.red.withOpacity(0.2);
                                break;
                              case 'waiting':
                              default:
                                rowColor = Colors.orange.withOpacity(0.2);
                                break;
                            }

                            return DataRow(
                              color: MaterialStateProperty.resolveWith<Color?>(
                                (Set<MaterialState> states) {
                                  return rowColor; // Use the determined row color
                                },
                              ),
                              cells: [
                                DataCell(
                                  Checkbox(
                                    value: _selectedStudents[index],
                                    onChanged: (bool? value) {
                                      setState(() {
                                        _selectedStudents[index] =
                                            value ?? false;

                                        if (!_selectedStudents[index]) {
                                          _selectAll = false;
                                        } else if (_selectedStudents
                                            .every((element) => element)) {
                                          _selectAll = true;
                                        }
                                      });
                                    },
                                  ),
                                ),
                                DataCell(
                                  Text(filteredStudents[index]['Firstname'] +
                                      " " +
                                      filteredStudents[index]['Fathername'] +
                                      " " +
                                      filteredStudents[index]['Lastname']),
                                ),
                                DataCell(
                                  _buildStatusDropdown(
                                      index, filteredStudents[index]['status']),
                                ),
                                DataCell(
                                  IconButton(
                                    splashRadius: 20,
                                    onPressed: () {
                                      updateAllStudentsStatus(index);
                                    },
                                    icon: const Icon(Icons.save),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    )),
              ),
            ),
        ],
      ),
    );
  }
}
