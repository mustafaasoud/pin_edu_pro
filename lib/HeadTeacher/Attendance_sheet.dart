// ignore_for_file: file_names, avoid_print, non_constant_identifier_names, no_leading_underscores_for_local_identifiers, unused_local_variable, prefer_typing_uninitialized_variables, unused_import, unused_element, deprecated_member_use, library_prefixes

import 'dart:io';
import 'package:data_table_2/data_table_2.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as Path;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pin_edu_pro/Models/student_Model.dart';
import 'package:pin_edu_pro/Services/DataServices.dart';
import 'package:pin_edu_pro/Services/global.dart';
import 'package:pin_edu_pro/Services/socket_services.dart';
import 'package:pin_edu_pro/Widgets/appthem.dart';

class AttendanceSheetStudent extends StatefulWidget {
  final List<student_model> studentList;
  final String School_Name;
  final String Grade_Name;
  final String Classroom_Name;

  const AttendanceSheetStudent(
      {required this.studentList,
      required this.Classroom_Name,
      required this.Grade_Name,
      required this.School_Name,
      super.key});

  @override
  State<AttendanceSheetStudent> createState() => _AttendanceSheetStudentState();
}

class _AttendanceSheetStudentState extends State<AttendanceSheetStudent> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  int _selectedYearIndex = 0; // Initialize to -1
  int? monthID;
  List<student_model> Studenttemp = [];
  int? totalStudents;
  List<Map<String, dynamic>> daysInMonth = [];
  Map<String, Map<String, bool>> attendanceData = {};
  List<Map<String, dynamic>> academicYearList = [];
  List<Map<String, dynamic>> monthslist = [];
  List<Map<String, dynamic>> droplist = [];
  List<Map<String, dynamic>> DropOutStudentList = [];
  String? DropoutDateUSer;
  String MonthName = "";
  String? ArabicMonthName;
  @override
  void initState() {
    super.initState();

    getAcademicYear();
    get_droptitle();
    GetrdropoutStudents();
  }

  Future<void> get_droptitle() async {
    try {
      List<Map<String, dynamic>> res =
          await SQLiteHelper().queryAllRows('droptitel');
      for (var row in res) {
        droplist.add({
          'Drop_ID': row['Drop_ID'],
          'Drop_Titel': row['Drop_Titel'],
        });
      }
      // Auto-select the current year if present
      if (droplist.isNotEmpty) {
        setState(() {});
      }
    } catch (e) {
      print("Error fetching droplist: $e");
    }
  }

  Future<void> GetrdropoutStudents() async {
    DropOutStudentList.clear();
    try {
      List<Map<String, dynamic>> res =
          await SQLiteHelper().queryAllRows('dropout_student');
      for (var row in res) {
        DropOutStudentList.add({
          'id': row['id'],
          'Student_id': row['Student_id'],
          'Dropout_res': row['Dropout_res'],
          'Class_Name': row['Class_Name'],
          'Grade_Name': row['Grade_Name'],
          'School_Name': row['School_Name'],
          'Dropout_Date': row['Dropout_Date'],
          'Return_Date': row['Return_Date'],
        });
      }
      setState(() {});
    } catch (e) {
      print("Error fetching droplist: $e");
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
      // Auto-select the current year if present
      if (academicYearList.isNotEmpty) {
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

  int? lastMonthId;
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
        setState(() {
          DropoutDateUSer = monthslist.last['month'];
          lastMonthId = monthslist.last['id'];
          monthID = lastMonthId; // Set monthID to the last month's ID
          getdays(monthID.toString());
        });
      }
    } catch (e) {
      print("Error fetching months: $e");
    }
  }

  getdays(String x) async {
    try {
      daysInMonth.clear();
      List<DateTime> holidays = [
        //  DateTime.parse('2024-01-01')
        //   DateTime.parse('2024-12-25')
      ];
      List<Map<String, dynamic>> res = await SQLiteHelper()
          .queryAllRowswithcondition('days', "month_id = ?", x);
      for (var row in res) {
        DateTime date = DateTime.parse(row['date']);
        if (date.weekday != DateTime.thursday &&
            date.weekday != DateTime.friday &&
            !holidays.contains(date)) {
          daysInMonth.add({
            'id': row['id'],
            'month_id': row['month_id'],
            'day': row['day'],
            'date': date,
          });
        }
      }
      if (daysInMonth.isNotEmpty) {
        await _loadAttendanceData();
        setState(() {});
      }
    } catch (e) {
      print("Error fetching days: $e");
    }
  }

  Future<void> _loadAttendanceData() async {
    try {
      final db = await SQLiteHelper().database;
      for (var student in widget.studentList) {
        int? studentId =
            student.student_ID; // Assuming student model has an id field
        attendanceData[
            '${student.firstname!} ${student.fathername!} ${student.lastname!}'] = {};
        for (var day in daysInMonth) {
          DateTime date = day['date']; // Extract the date field from the map
          String formattedDate = DateFormat('yyyy-MM-dd').format(date);
          List<Map<String, dynamic>> res = await db.query(
            'attendance',
            where: 'student_id = ? AND day_id = ?',
            whereArgs: [studentId, day['id']],
          );
          if (res.isNotEmpty) {
            attendanceData[
                    '${student.firstname!} ${student.fathername!} ${student.lastname!}']![
                formattedDate] = res.first['attend'] == 1;
          } else {
            attendanceData[
                    '${student.firstname!} ${student.fathername!} ${student.lastname!}']![
                formattedDate] = true; // Default value
          }
        }
      }
    } catch (e) {
      print("Error loading attendance data: $e");
    }
  }

  Future<void> saveAttendanceData() async {
    try {
      final db = await SQLiteHelper().database;

      for (var student in widget.studentList) {
        int studentId = student.student_ID!;
        for (var day in daysInMonth) {
          DateTime date = day['date'];
          String formattedDate = DateFormat('yyyy-MM-dd').format(date);
          bool isPresent = attendanceData[
                      '${student.firstname!} ${student.fathername!} ${student.lastname!}']![
                  formattedDate] ??
              false;

          List<Map<String, dynamic>> res = await db.query(
            'attendance',
            where: 'student_id = ? AND day_id = ?',
            whereArgs: [studentId, day['id']],
          );
          if (res.isNotEmpty) {
            if (res.first['attend'] != (isPresent ? 1 : 0)) {
              await db.update(
                'attendance',
                {
                  'attend': isPresent ? 1 : 0,
                },
                where:
                    'student_id = ? AND day_id = ? AND month_ID = ? AND year_ID=?',
                whereArgs: [studentId, day['id'], monthID, _selectedYearIndex],
              );
            }
          } else {
            await db.insert(
              'attendance',
              {
                'student_id': studentId,
                'day_id': day['id'],
                'attend': isPresent ? 1 : 0,
                'month_ID': monthID,
                'year_ID': _selectedYearIndex
              },
            );
          }
        }
      }
      insertTotalAttendance();

      setState(() {});
    } catch (e) {
      print("Error saving attendance data: $e");
    }
  }

  Future<void> insertTotalAttendance() async {
    try {
      final db = await SQLiteHelper().database;
      var res = await db.rawQuery('''
      SELECT student_id, month_ID, year_ID, SUM(attend) AS attendance_count
      FROM attendance
      WHERE year_ID = ?
      GROUP BY student_id, month_ID, year_ID;
    ''', [_selectedYearIndex]);
      for (var row in res) {
        var existingRow = await db.rawQuery('''
        SELECT 1 FROM totalatte
        WHERE student_id = ? AND month_ID = ? AND year_ID = ?
      ''', [
          row['student_id'],
          row['month_ID'],
          row['year_ID'],
        ]);

        if (existingRow.isNotEmpty) {
          await db.rawUpdate('''
          UPDATE totalatte
          SET attendance_count = ?
          WHERE student_id = ? AND month_ID = ? AND year_ID = ?
        ''', [
            row['attendance_count'],
            row['student_id'],
            row['month_ID'],
            row['year_ID'],
          ]);
        } else {
          await db.rawInsert('''
          INSERT INTO totalatte(student_id, month_ID, year_ID, attendance_count)
          VALUES (?, ?, ?, ?)
        ''', [
            row['student_id'],
            row['month_ID'],
            row['year_ID'],
            row['attendance_count'],
          ]);
        }
      }
      synctoserver();
      print('Total attendance records inserted or updated successfully.');
    } catch (e) {
      print('Error inserting or updating total attendance records: $e');
    }
  }

  synctoserver() async {
    List<Map<String, dynamic>> res =
        await SQLiteHelper().queryAllRows("totalatte");
    SocketService.totalAttendanceSocket(res);
  }

  Future<void> Savetodroplist(student, String Reason) async {
    final db = await SQLiteHelper().database;
    List<Map<String, dynamic>> existingRecords = await db.rawQuery(
      "SELECT * FROM dropout_student WHERE student_ID = ?",
      [student.student_ID.toString()],
    );
    if (existingRecords.isNotEmpty) {
      print("Record found for student ID ${student.student_ID}");
    } else {
      await db.rawInsert(
        "INSERT INTO dropout_student (Student_id, Dropout_res, Class_Name, Grade_Name,School_Name, Dropout_Date) VALUES (?, ?, ?, ?, ?, ?)",
        [
          student.student_ID.toString(),
          Reason,
          student.Class_Name.toString(),
          student.gradeName.toString(),
          student.schoolName.toString(),
          DropoutDateUSer,
        ],
      );
      GetrdropoutStudents();
    }
  }

  _buildColumns() {
    List<DataColumn> columns = [];
    columns.add(const DataColumn(
        label: IntrinsicHeight(
      child: Row(
        children: [
          Text('#'),
          Gap(5),
          VerticalDivider(
            indent: 5,
            endIndent: 5,
            thickness: 1,
            width: 1,
            color: Colors.black,
          ),
          Gap(20),
          Text('ID')
        ],
      ),
    ))); // Add a column for row number

    columns.add(DataColumn(
        label: Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        'Student \n Name'.tr,
        textAlign: TextAlign.center,
      ),
    )));
    for (var day in daysInMonth) {
      DateTime date = day['date']; // Assuming 'date' is DateTime type
      columns.add(
        DataColumn(
          label: Column(
            children: [
              const Gap(5),
              Get.locale?.languageCode == 'ar'
                  ? Text(
                      DateFormat('EEEE', 'ar').format(date),
                    )
                  : Text(
                      DateFormat('EEEE', 'en').format(date),
                    ),
              Get.locale?.languageCode == 'ar'
                  ? Text(
                      DateFormat('dd-MM-yyyy', 'ar').format(date),
                      style: const TextStyle(fontSize: 9),
                    )
                  : Text(
                      DateFormat('dd-MM-yyyy', 'en').format(date),
                      style: const TextStyle(fontSize: 9),
                    )
            ],
          ),
        ),
      );
    }

    columns.add(DataColumn(
      label: Text(
        'Total \n attendance'.tr,
        textAlign: TextAlign.center,
      ), // Total Attendance in Arabic
    ));

    return columns;
  }

  List<DataRow> _buildRows() {
    List<DataRow> rows = [];
    List<student_model> filteredStudents = widget.studentList.where((student) {
      return student.firstname!
          .toLowerCase()
          .contains(searchQuery.toLowerCase());
    }).toList();

    int rowIndex = 1; // Initialize row index
    for (var student in filteredStudents) {
      bool isDroppedOut = DropOutStudentList.any((dropout) {
        DateTime dropoutDate = DateTime.parse(dropout['Dropout_Date']);
        DateTime? returnDate = dropout['Return_Date'] != null
            ? DateTime.parse(dropout['Return_Date'])
            : null;

        // Check if student is in dropout list and hasn't returned or returned after today
        return dropout['Student_id'] == student.student_ID &&
            (dropoutDate.isBefore(DateTime.parse(DropoutDateUSer!)) &&
                (returnDate == null ||
                    returnDate.isAfter(DateTime.parse(DropoutDateUSer!))));
      });

      if (isDroppedOut) continue;

      List<DataCell> cells = [];
      cells.add(DataCell(IntrinsicHeight(
        child: Row(
          children: [
            Text(rowIndex.toString()),
            const Gap(5),
            const VerticalDivider(
              indent: 5,
              endIndent: 5,
              thickness: 1,
              width: 1,
              color: Colors.green,
            ),
            const Gap(20),
            Text(student.student_ID.toString())
          ],
        ),
      )));

      cells.add(DataCell(
        InkWell(
          onTap: () {
            _showDropoutDialog(student);
          },
          child: Row(
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Text(
                    '${student.firstname!} ${student.fathername!} ${student.lastname!}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ));

      for (var day in daysInMonth) {
        DateTime date = day['date'];
        bool isPresent = attendanceData[
                    '${student.firstname!} ${student.fathername!} ${student.lastname!}']
                ?[DateFormat('yyyy-MM-dd').format(date)] ??
            false;

        cells.add(
          DataCell(
            Checkbox(
              value: isPresent,
              onChanged: (bool? value) {
                setState(() {
                  attendanceData[
                          '${student.firstname!} ${student.fathername!} ${student.lastname!}']
                      ?[DateFormat('yyyy-MM-dd').format(date)] = value ?? false;
                });
              },
            ),
          ),
        );
      }
      cells.add(DataCell(Text(calculateTotalAttendance(student))));
      rows.add(DataRow(cells: cells));
      rowIndex++;
    }
    setState(() {
      totalStudents = rows.length;
    });
    return rows;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Attendanet Sheet'.tr), // Attendance Sheet in Arabic
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  saveAttendanceData();
                },
                child: const Row(
                  children: [
                    Icon(Icons.sync),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  _generatePdf();
                },
                child: const Row(
                  children: [
                    Icon(FontAwesomeIcons.filePdf),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 5),
              Wrap(
                runAlignment: WrapAlignment.center,
                spacing: 8.0, // Spacing between chips
                children:
                    List<Widget>.generate(academicYearList.length, (int index) {
                  DateTime startDate =
                      DateTime.parse(academicYearList[index]['start_date']);
                  String yearLabel = startDate.year.toString();
                  bool isEnabled = startDate.year == DateTime.now().year;

                  // Disable months that are in the future compared to the current date
                  if (startDate.year == DateTime.now().year) {
                    isEnabled = startDate.month <= DateTime.now().month;
                  }

                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_selectedYearIndex == academicYearList[index]['id'])
                          const Icon(
                            Icons.check,
                            color: Colors.white,
                          ),
                        const SizedBox(
                            width: 4.0), // Space between icon and text
                        Text(
                          yearLabel,
                          style: TextStyle(
                            color: _selectedYearIndex ==
                                    academicYearList[index]['id']
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    selected:
                        _selectedYearIndex == academicYearList[index]['id'],
                    selectedColor: Colors.blue,
                    backgroundColor:
                        isEnabled ? Colors.grey : Colors.grey.withOpacity(0.3),
                    onSelected: isEnabled
                        ? (bool selected) {
                            setState(() {
                              _selectedYearIndex =
                                  academicYearList[index]['id'];
                              if (selected) {
                                getmonth(
                                    academicYearList[index]['id'].toString());
                              }
                            });
                          }
                        : null,
                  );
                }),
              ),
              Text(totalStudents.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                  )),
              Text('Select Month'.tr,
                  style: const TextStyle(
                    fontSize: 16,
                  )), // Select Month in Arabic
              SizedBox(
                width: AppTheme.fullWidth(context),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  runSpacing: 8,
                  spacing: 8,
                  children: List.generate(monthslist.length, (index) {
                    List<String> dateParts =
                        monthslist[index]['month'].split("-");
                    int monthNumber = int.parse(dateParts[1]);
                    Get.locale?.languageCode == 'ar'
                        ? ArabicMonthName = _getMonthName(monthNumber)
                        : ArabicMonthName = _getMonthNameEN(monthNumber);

                    bool isEnabled = monthNumber <= DateTime.now().month;

                    return GestureDetector(
                      onTap: isEnabled
                          ? () {
                              setState(() {
                                DropoutDateUSer =
                                    monthslist[index]['month'].toString();
                                print(DropoutDateUSer);
                                if (lastMonthId == monthslist[index]['id']) {
                                  lastMonthId = null;
                                } else {
                                  MonthName = monthslist[index]['month'];
                                  lastMonthId = monthslist[index]['id'];
                                  monthID = monthslist[index]['id'];
                                  getdays(monthID.toString());
                                }
                                setState(() {
                                  MonthName =
                                      monthslist[index]['month'].toString();
                                  print(MonthName);
                                });
                              });
                            }
                          : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isEnabled
                              ? (lastMonthId == monthslist[index]['id']
                                  ? Colors.blue
                                  : Colors.white)
                              : Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isEnabled
                                ? Colors.blue
                                : Colors.grey.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              lastMonthId == monthslist[index]['id']
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: isEnabled ? Colors.white : Colors.black,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              ArabicMonthName!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isEnabled ? Colors.black : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const Gap(10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: 'Search by ...'.tr,
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
              ),
              Expanded(
                  child: DataTable2(
                      headingTextStyle: const TextStyle(),
                      sortArrowIcon: Icons.arrow_upward,
                      headingRowColor: MaterialStateProperty.all<Color>(
                          const Color.fromARGB(230, 202, 202, 202)),
                      border: TableBorder.symmetric(
                        outside: const BorderSide(width: 0.2),
                      ),
                      fixedLeftColumns: 2,
                      dataRowHeight: 80,
                      minWidth: 2500,
                      columnSpacing: 1,
                      columns: _buildColumns(),
                      rows: _buildRows())),
            ])));
  }

  String? selectedReason;
  var Reason;
  void _showDropoutDialog(student) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose Dropout Reason'.tr),
          content: Wrap(
            children: [
              Text(student.firstname),
              DropdownButtonFormField<String>(
                value: selectedReason,
                items: droplist.map((item) {
                  return DropdownMenuItem<String>(
                    value: item['Drop_ID'].toString(),
                    child: Text(
                      item['Drop_Titel'],
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      softWrap: true,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedReason = value;
                  Reason = droplist.firstWhere(
                      (item) => item['Drop_ID'].toString() == value);
                  print(Reason['Drop_Titel']);
                },
                hint: Text('Dropout Reason'.tr),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel
              },
              child: Text('Cancel'.tr),
            ),
            TextButton(
              onPressed: () {
                Savetodroplist(student, Reason['Drop_Titel']);
                Navigator.of(context).pop(true);
              },
              child: Text('Confirm'.tr),
            ),
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed) {
        // Reset all attendance checkboxes to false for the student
        for (var day in daysInMonth) {
          attendanceData[
                  '${student.firstname!} ${student.fathername!} ${student.lastname!}']
              ?.forEach((key, value) {
            attendanceData[
                    '${student.firstname!} ${student.fathername!} ${student.lastname!}']
                ?[key] = false;
          });
        }
        setState(() {}); // Refresh UI after resetting attendance
      }
    });
  }

  String calculateTotalAttendance(student) {
    int totalAttendance = 0;
    if (attendanceData.containsKey(
            '${student.firstname!} ${student.fathername!} ${student.lastname!}') &&
        attendanceData[
                '${student.firstname!} ${student.fathername!} ${student.lastname!}'] !=
            null) {
      attendanceData[
              '${student.firstname!} ${student.fathername!} ${student.lastname!}']
          ?.forEach((key, value) {
        if (value) {
          totalAttendance++;
        }
      });
    }
    return totalAttendance.toString();
  }

  Future<void> _generatePdf() async {
    int totaAlllMale = 0;
    int totalAllFemale = 0;

    final totalChunks =
        (widget.studentList.length / 15).ceil(); // Total number of chunks/pages

    final pdf = pw.Document();

    // Load font data
    final Uint8List fontData =
        await rootBundle.load('assets/fonts/Beiruti-Regular.ttf').then((value) {
      return value.buffer.asUint8List();
    });
    final ttf = pw.Font.ttf(fontData.buffer.asByteData());

    // Split student list into chunks of 15 students per page
    final List<List<student_model>> chunks =
        List<List<student_model>>.generate(totalChunks, (index) {
      final start = index * 15;
      return widget.studentList.skip(start).take(15).toList();
    });
// Parse the start date
    DateTime startDate = DateTime.parse(MonthName);
    DateTime endDate = DateTime(startDate.year, startDate.month + 1, 0);
    String formattedStartDate = DateFormat('dd,MM,yyyy').format(startDate);
    String formattedEndDate = DateFormat('dd,MM,yyyy').format(endDate);

    int currentPage = 0;

    for (final chunk in chunks) {
      if (chunk.isEmpty) {
        currentPage = 0;
        continue; // Skip adding empty chunks
      }

      int totalMale = 0;
      int totalFemale = 0;

      for (final student in chunk) {
        if (student.gender == "Male") {
          totalMale++;
          totaAlllMale++; // Update the total count for all pages
        } else if (student.gender == "Female") {
          totalFemale++;
          totalAllFemale++; // Update the total count for all pages
        }
      }

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(10), // Adjust margins if needed
          build: (pw.Context context) {
            currentPage++;
            return pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'Project: ENI VI',
                            style: const pw.TextStyle(fontSize: 12),
                          ),
                          pw.Text(
                            'Students Monthly Attendance',
                            style: const pw.TextStyle(fontSize: 12),
                          ),
                          pw.Row(children: [
                            pw.Text(
                              "Total Male :$totalMale",
                              style: const pw.TextStyle(fontSize: 12),
                            ),
                            pw.SizedBox(width: 10),
                            pw.Text(
                              "Total Female : $totalFemale",
                              style: const pw.TextStyle(fontSize: 12),
                            ),
                            pw.SizedBox(width: 10),
                            pw.Text(
                              'End date: $formattedEndDate',
                              style: const pw.TextStyle(fontSize: 12),
                            ),
                            pw.SizedBox(width: 20),
                            pw.Text(
                              'Start date: $formattedStartDate',
                              style: const pw.TextStyle(fontSize: 12),
                            ),
                          ])
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 10),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Class_Name : ${widget.Classroom_Name}',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                      pw.Text(
                        'Grade : ${widget.Grade_Name}',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                      pw.Text(
                        'School Name : ${widget.School_Name}',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 15), // Add space between header and table
                  pw.Table.fromTextArray(
                    headers: [
                      'Student\nCode',
                      'Student\nName',
                      'Gender',
                      ...daysInMonth
                          .map((day) => DateFormat('dd').format(day['date']))
                          .toList(),
                      'Total Of\nAttendance'
                    ],
                    data: chunk.map((student) {
                      return [
                        student.student_ID,
                        '${student.firstname!} ${student.fathername!} ${student.lastname!}',
                        student.gender,
                        ...daysInMonth.map((day) {
                          final date =
                              DateFormat('yyyy-MM-dd').format(day['date']);
                          return attendanceData[
                                          '${student.firstname!} ${student.fathername!} ${student.lastname!}']
                                      ?[date] ==
                                  true
                              ? 'Y'
                              : 'N';
                        }).toList(),
                        calculateTotalAttendance(student),
                      ];
                    }).toList(),
                    cellStyle: pw.TextStyle(font: ttf),
                    headerStyle: const pw.TextStyle(fontSize: 12),
                    cellAlignment: pw.Alignment.center,
                    headerAlignment: pw.Alignment.centerLeft,
                  ),
                  pw.Spacer(),
                  pw.Divider(),
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Text(
                          " Male   : $totaAlllMale",
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                        pw.SizedBox(width: 10),
                        pw.Text(
                          "Female : $totalAllFemale",
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                      ]),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Approved by school director / responsible : -----------------------------------------',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                      pw.Text(
                        'Approved by PIN Staff : --------------------',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  pw.Align(
                    alignment: pw.Alignment.bottomRight,
                    child: pw.Text(
                      'Page $currentPage of $totalChunks',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    // Print total number of male and female students across all pages
    print('Total Males: $totaAlllMale');
    print('Total Females: $totalAllFemale');
    print(widget.School_Name + widget.Grade_Name + widget.Classroom_Name);
    // Save PDF to a temporary directory
    final output = await getTemporaryDirectory();
    final file = File(
        "${output.path}/${widget.School_Name + widget.Grade_Name + widget.Classroom_Name}.pdf");
    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(file.path);
  }
}
