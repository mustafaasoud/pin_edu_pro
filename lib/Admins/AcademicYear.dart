// ignore_for_file: unused_element, prefer_typing_uninitialized_variables, file_names, library_private_types_in_public_api, non_constant_identifier_names, avoid_print

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:pin_edu_pro/Services/DataServices.dart';
import 'package:pin_edu_pro/Services/socket_services.dart';

class AcademicYearPicker extends StatefulWidget {
  const AcademicYearPicker({super.key});

  @override
  _AcademicYearPickerState createState() => _AcademicYearPickerState();
}

class _AcademicYearPickerState extends State<AcademicYearPicker> {
  final _formKey = GlobalKey<FormState>();
  final _startDayController = TextEditingController();
  final _startMonthController = TextEditingController();
  final _startYearController = TextEditingController();
  final _endDayController = TextEditingController();
  final _endMonthController = TextEditingController();
  final _endYearController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              DottedBorder(
                  strokeWidth: 0.3, child: const Text("بداية العام الدراسي")),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startDayController,
                      decoration: const InputDecoration(
                          labelText: 'يوم بداية السنة',
                          border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال يوم البداية';
                        }
                        return null;
                      },
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: TextFormField(
                      controller: _startMonthController,
                      decoration: const InputDecoration(
                          labelText: 'شهر بداية السنة',
                          border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال شهر البداية';
                        }
                        return null;
                      },
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: TextFormField(
                      controller: _startYearController,
                      decoration: const InputDecoration(
                        labelText: 'سنة بداية السنة',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال سنة البداية';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const Gap(10),
              DottedBorder(
                  strokeWidth: 0.3, child: const Text("نهاية العام الدراسي")),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _endDayController,
                      decoration: const InputDecoration(
                        labelText: 'يوم نهاية السنة',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال يوم النهاية';
                        }
                        return null;
                      },
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: TextFormField(
                      controller: _endMonthController,
                      decoration: const InputDecoration(
                          labelText: 'شهر نهاية السنة',
                          border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال شهر النهاية';
                        }
                        return null;
                      },
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: TextFormField(
                      controller: _endYearController,
                      decoration: const InputDecoration(
                          labelText: 'سنة نهاية السنة',
                          border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال سنة النهاية';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _startDate = DateTime(
                            int.parse(_startYearController.text),
                            int.parse(_startMonthController.text),
                            int.parse(_startDayController.text),
                          );
                          _endDate = DateTime(
                            int.parse(_endYearController.text),
                            int.parse(_endMonthController.text),
                            int.parse(_endDayController.text),
                          );
                        });

                        _createAcademicYear(_startDate!, _endDate!);
                      }
                    },
                    child: const Text('إنشاء سنة دراسية جديدة'),
                  ),
                  const Gap(10),
                  ElevatedButton(
                    onPressed: () {
                      SynMsql_Sqlite();
                    },
                    child: const Row(
                      children: [
                        Icon(
                          Icons.sync,
                        ),
                        Text("مزامنة البيانات"),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _createAcademicYear(DateTime startDate, DateTime endDate) async {
    final db = await SQLiteHelper().database;

    final DateFormat formatter = DateFormat('yyyy-MM-dd');

    int startYear = startDate.year;
    int endYear = endDate.year;

    for (int year = startYear; year <= endYear; year++) {
      DateTime yearStartDate =
          (year == startYear) ? startDate : DateTime(year, 1, 1);
      DateTime yearEndDate =
          (year == endYear) ? endDate : DateTime(year, 12, 31);

      int yearId = await db.insert(
        'academic_year',
        {
          'start_date': yearStartDate.toIso8601String(),
          'end_date': yearEndDate.toIso8601String(),
        },
      );

      int startMonth = yearStartDate.month;
      int endMonth = yearEndDate.month;

      for (int month = startMonth; month <= endMonth; month++) {
        String monthFormatted = formatter.format(DateTime(year, month));
        int monthId = await db.insert('months', {
          'year_id': yearId,
          'month': monthFormatted,
        });

        int daysInMonth = DateTime(year, month + 1, 0).day;
        for (int day = 1; day <= daysInMonth; day++) {
          DateTime currentDate = DateTime(year, month, day);
          String formattedDate = formatter.format(currentDate);
          await db.insert('days', {
            'month_id': monthId,
            'day': day,
            'date': formattedDate,
            'student_id': null,
            'attendance': 0,
          });
        }
      }
    }
  }

  List<Map<String, dynamic>> daysInMonth = [];
  List<Map<String, dynamic>> academicYearList = [];
  List<Map<String, dynamic>> monthslist = [];
  Future<void> SynMsql_Sqlite() async {
    await Future.wait([
      getAcademicYear(),
      getmonth(),
      getdays(),
    ]);
    // Perform any additional actions after all futures complete
  }

  Future<void> getAcademicYear() async {
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
      for (int i = 0; i < academicYearList.length; i++) {
        SocketService.sendYear(academicYearList[i]);
      }
    }
  }

  Future<void> getmonth() async {
    List<Map<String, dynamic>> res =
        await SQLiteHelper().queryAllRows('months');
    for (var row in res) {
      monthslist.add({
        'id': row['id'],
        'year_id': row['year_id'],
        'month': row['month'],
      });
    }
    if (monthslist.isNotEmpty) {
      print(monthslist.length);
      for (int i = 0; i < monthslist.length; i++) {
        SocketService.sendMonths(monthslist[i]);
      }
    }
  }

  Future<void> getdays() async {
    List<Map<String, dynamic>> res = await SQLiteHelper().queryAllRows('days');
    for (var row in res) {
      daysInMonth.add({
        'id': row['id'],
        'month_id': row['month_id'],
        'day': row['day'],
        'date': row['date'],
      });
    }
    if (daysInMonth.isNotEmpty) {
      for (int i = 0; i < daysInMonth.length; i++) {
        SocketService.sendDays(daysInMonth[i]);
      }
    }
  }
}
