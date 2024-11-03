// ignore_for_file: non_constant_identifier_names, file_names, camel_case_types, duplicate_ignore, avoid_print, empty_catches, deprecated_member_use, unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pin_edu_pro/HeadTeacher/Attendance_sheet.dart';
import 'package:pin_edu_pro/HeadTeacher/New_Student_RegUI.dart';
import 'package:pin_edu_pro/Models/Classroom_Model.dart';
import 'package:pin_edu_pro/Models/Grade_Model.dart';
import 'package:pin_edu_pro/Models/student_Model.dart';
import 'package:pin_edu_pro/Services/DataServices.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:pin_edu_pro/Widgets/appthem.dart';

class Group_Student_UI extends StatefulWidget {
  final String school_Name;

  const Group_Student_UI({
    Key? key,
    required this.school_Name,
  }) : super(key: key);

  @override
  State<Group_Student_UI> createState() => _Group_Student_UIState();
}

class _Group_Student_UIState extends State<Group_Student_UI>
    with SingleTickerProviderStateMixin {
  int? selectedGradeId;
  String? Grade_Name;
  String? classroom_Name;
  int? selectedclassroomID;

  List<Grade_Model> gradeList = [];
  List<classroom_model> classroomList = [];
  List<student_model> studentList = [];
  List<Map<String, dynamic>> DropStudentList = [];
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(() {
      setState(() {});
    });
    fetchCounts();
    dropStudent();
  }

  Future<void> fetchCounts() async {
    await fetchGrades();
    if (gradeList.isNotEmpty) {
      setState(() {});
    }
  }

  Future<void> fetchGrades() async {
    try {
      List<Grade_Model> grades = await getGrades(widget.school_Name);
      grades.sort((a, b) => a.Grade_name.compareTo(b.Grade_name));
      setState(() {
        gradeList = grades;
      });
    } catch (e) {
      print('Error fetching grades: $e');
    }
  }

  Future dropStudent() async {
    final db = await SQLiteHelper().database;
    final List<Map<String, dynamic>> rawList = await db.rawQuery(
        "SELECT DISTINCT dropout_student.Student_id,students.Firstname,students.Fathername,students.Lastname,students.school_name,dropout_student.Dropout_Date,dropout_student.Return_Date,classroom.Class_name,grades.Grade_name FROM dropout_student JOIN students ON dropout_student.Student_id = students.student_ID JOIN classroom ON dropout_student.Class_Name = classroom.Class_name JOIN grades ON dropout_student.Grade_Name = grades.Grade_name;");

    // Remove duplicates
    final Set<Map<String, dynamic>> uniqueStudents = {};
    for (var student in rawList) {
      uniqueStudents.add(student);
    }

    setState(() {
      DropStudentList = uniqueStudents.toList();
    });

    return DropStudentList;
  }

  Future updatedropStudent(student, String DateReturn) async {
    DropStudentList.clear();
    final db = await SQLiteHelper().database;
    await db.update(
      'dropout_student',
      {'Return_Date': DateReturn},
      where: 'Student_id = ?',
      whereArgs: [student['Student_id']],
    );

    setState(() {
      dropStudent();
    });
  }

  Future<List<Grade_Model>> getGrades(String school_Name) async {
    final db = await SQLiteHelper().database;
    final List<Map<String, dynamic>> maps = await db
        .query('grades', where: 'school_Name = ? ', whereArgs: [school_Name]);
    return List<Grade_Model>.from(maps.map((x) => Grade_Model.fromJson(x)));
  }

  //////// classroom
  Future<void> fetchclassromcount(String x) async {
    classroomList.clear();
    await GetClassroom(widget.school_Name, x);
  }

  Future<void> GetClassroom(String school_Name, String xx) async {
    try {
      final db = await SQLiteHelper().database;
      final List<Map<String, dynamic>> maps = await db.query('classroom',
          where: 'school_Name = ? and Grade_Name=?',
          whereArgs: [school_Name, xx]);

      List<classroom_model> classrooms = List<classroom_model>.from(
          maps.map((x) => classroom_model.fromJson(x)));
      classrooms.sort((a, b) => a.Class_name.compareTo(b.Class_name));
      setState(() {
        classroomList = classrooms;
      });
    } catch (error) {
      setState(() {});
    }
  }

  //////// Students
  Future<void> fetchstudents(String x, String xxx) async {
    studentList.clear();
    await Getstudents(widget.school_Name, x, xxx);
  }

  Future<void> Getstudents(String school_Name, String xx, String xxx) async {
    try {
      final db = await SQLiteHelper().database;
      final List<Map<String, dynamic>> maps = await db.query('students',
          where: 'school_name = ?  and Grade_Name=? and Class_Name=?',
          whereArgs: [school_Name, xx, xxx]);

      List<student_model> students =
          List<student_model>.from(maps.map((x) => student_model.fromJson(x)));
      students.sort((a, b) => a.firstname!.compareTo(b.firstname!));
      setState(() {
        studentList = students;
      });
    } catch (error) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          bottom: TabBar(controller: tabController, tabs: [
            Tab(
              text: "Attendance Sheet".tr,
              icon: const Icon(
                FontAwesomeIcons.inbox,
                color: Colors.white,
              ),
            ),
            Tab(
                text: "Drop Out Of School".tr,
                icon: const Icon(
                  FontAwesomeIcons.outdent,
                  color: Colors.white,
                )),
            Tab(
                text: 'Tests'.tr,
                icon: const Icon(
                  FontAwesomeIcons.marker,
                  color: Colors.white,
                )),
          ]),
          centerTitle: true,
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('PIN EDU'),
              Gap(10),
            ],
          ),
          backgroundColor: Colors.blue,
        ),
        floatingActionButton: SpeedDial(
          switchLabelPosition: GetPlatform.isWindows,
          animatedIcon: AnimatedIcons.menu_close,
          backgroundColor: Colors.blue,
          overlayColor: Colors.black,
          children: [
            SpeedDialChild(
              labelWidget: Container(
                width: 170,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.add),
                    Text("Add New Student".tr,
                        style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              //go to reg new student request
              onTap: () => Get.to(() => const NSRR()),
            ),
            SpeedDialChild(
              labelWidget: Container(
                width: 170,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.move_to_inbox),
                    Text("Classroom".tr,
                        style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              onTap: () => print('Move tapped'),
            ),
            SpeedDialChild(
              labelWidget: Container(
                width: 170,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search),
                    Text('Search Student'.tr,
                        style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              onTap: () => print('Search tapped'),
            ),
            SpeedDialChild(
                labelWidget: Container(
                  width: 170,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search),
                      Text('Attendance Sheet'.tr,
                          style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                onTap: () {
                  if (studentList.isEmpty) {
                    Get.showSnackbar(GetSnackBar(
                      title: "Alert".tr,
                      message: 'No Data Found',
                      icon: const Icon(
                        FontAwesomeIcons.stop,
                        color: Colors.red,
                      ),
                      duration: const Duration(seconds: 3),
                    ));
                  } else {
                    Get.to(() => AttendanceSheetStudent(
                          studentList: studentList,
                          Classroom_Name: classroom_Name!,
                          Grade_Name: Grade_Name!,
                          School_Name: widget.school_Name,
                        ));
                  }
                }),
          ],
        ),
        body: TabBarView(controller: tabController, children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                children: [
                  if (gradeList.isNotEmpty)
                    SizedBox(
                      height: 50, // Set height for the ListView
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: gradeList.length,
                        itemBuilder: (context, index) {
                          final grade = gradeList[index];
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: ChoiceChip(
                              label: Text(
                                grade.Grade_name,
                                style: TextStyle(
                                  color: selectedGradeId == grade.Grade_ID
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              selected: selectedGradeId == grade.Grade_ID,
                              selectedColor: Colors.blue,
                              onSelected: (selected) {
                                setState(() {
                                  selectedGradeId = grade.Grade_ID;
                                  Grade_Name = grade.Grade_name;
                                  selectedclassroomID =
                                      null; // Clear classroom selection
                                  studentList.clear(); // Clear student list
                                });
                                fetchclassromcount(grade.Grade_name);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  const Gap(20),
                  if (classroomList.isNotEmpty)
                    SizedBox(
                      height: 50, // Set height for the ListView
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: classroomList.length,
                        itemBuilder: (context, index) {
                          final classroom = classroomList[index];
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: ChoiceChip(
                              label: Text(
                                classroom.Class_name,
                                style: TextStyle(
                                  color:
                                      selectedclassroomID == classroom.Class_id
                                          ? Colors.white
                                          : Colors.black,
                                ),
                              ),
                              selected:
                                  selectedclassroomID == classroom.Class_id,
                              selectedColor: Colors.blue,
                              onSelected: (selected) {
                                setState(() {
                                  classroom_Name = classroom.Class_name;
                                  selectedclassroomID =
                                      selected ? classroom.Class_id : null;
                                  if (selected) {
                                    fetchstudents(
                                        Grade_Name!, classroom.Class_name);
                                  } else {
                                    studentList.clear();
                                  }
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  const Gap(20),
                  if (studentList.isNotEmpty)
                    SizedBox(
                      height: 500, // Set height for the ListView
                      child: ListView.builder(
                        itemCount: studentList.length,
                        itemBuilder: (context, index) {
                          final student = studentList[index];

                          return Card(
                              elevation: 3,
                              color: index % 2 == 0
                                  ? Colors.blue.shade50
                                  : Colors.white,
                              child: ListTile(
                                title: Text(
                                    '${student.firstname!} ${student.fathername!} ${student.lastname!}'),
                                subtitle: IntrinsicHeight(
                                  child: Row(
                                    children: [
                                      Text('${student.gradeName}'),
                                      const Gap(10),
                                      VerticalDivider(
                                        indent: 5,
                                        endIndent: 5,
                                        thickness: 2,
                                        width: 1,
                                        color: AppTheme.card3,
                                      ),
                                      const Gap(10),
                                      Text('${student.Class_Name}'),
                                    ],
                                  ),
                                ),
                                trailing: TextButton(
                                  onPressed: () {},
                                  child: const Text('...'),
                                ),
                              ));
                        },
                      ),
                    )
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                children: [
                  if (DropStudentList.isNotEmpty)
                    Wrap(
                      children: List.generate(DropStudentList.length, (index) {
                        final student = DropStudentList[index];
                        return GestureDetector(
                            onTap: () {
                              _showDropoutDialog(student);
                            },
                            child: Card(
                                elevation: 10,
                                child: Container(
                                    width: AppTheme.fullWidth(context) / 2.2,
                                    height: 250,
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        left: BorderSide(
                                          color: Colors.red,
                                          width: 5.0,
                                        ),
                                      ),
                                      color: Colors.white,
                                    ),
                                    child: Column(children: [
                                      const Gap(10),
                                      Row(
                                        children: [
                                          const Gap(10),
                                          const Icon(FontAwesomeIcons.outdent),
                                          const Gap(10),
                                          Text(
                                              "${student['Firstname']} ${student['Fathername']} ${student['Lastname']}"),
                                        ],
                                      ),
                                      const Gap(10),
                                      const Divider(),
                                      const Gap(10),
                                      Text(student['school_name']),
                                      const Gap(10),
                                      IntrinsicHeight(
                                        child: Card(
                                          color: Colors.teal,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              children: [
                                                const Gap(10),
                                                const Icon(FontAwesomeIcons
                                                    .schoolFlag),
                                                const Gap(10),
                                                Text(
                                                    "${student['Grade_name']} "),
                                                const Gap(10),
                                                VerticalDivider(
                                                  indent: 5,
                                                  endIndent: 5,
                                                  thickness: 1,
                                                  width: 1,
                                                  color: AppTheme.card2,
                                                ),
                                                const Gap(10),
                                                Text(
                                                    "${student['Class_name']} "),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Gap(10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text("Drop out date :".tr),
                                          Text(student['Dropout_Date'])
                                        ],
                                      ),
                                      const Gap(10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text("Return Date :".tr),
                                          Text(student['Return_Date'] ??
                                              'Not return yet'.tr)
                                        ],
                                      ),
                                    ]))));
                      }),
                    )
                ],
              ),
            ),
          ),
          const Text("under construction")
        ]));
  }

  void _showDropoutDialog(student) {
    // Variables to hold the selected date and dropdown value
    DateTime? selectedReturnDate;
    String? Selectdatereturn;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Update Return Date'.tr),
              content: Wrap(
                children: [
                  Row(
                    children: [
                      Text(
                          "${student['Firstname']} ${student['Fathername']} ${student['Lastname']}"),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Drop out date :'.tr),
                      Text(student['Dropout_Date']),
                    ],
                  ),
                  student['Return_Date'] == null
                      ? Row(
                          children: [
                            Text('Return Date :'.tr),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                readOnly: true,
                                decoration: InputDecoration(
                                  hintText: selectedReturnDate != null
                                      ? '${selectedReturnDate!.day}-${selectedReturnDate!.month}-${selectedReturnDate!.year}'
                                      : 'Select Date'.tr,
                                  suffixIcon: const Icon(Icons.calendar_today),
                                ),
                                onTap: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2025),
                                  );
                                  if (pickedDate != null) {
                                    setState(() {
                                      selectedReturnDate = pickedDate;

                                      Selectdatereturn =
                                          DateFormat('yyyy-MM-dd')
                                              .format(pickedDate);

                                      updatedropStudent(
                                          student, Selectdatereturn!);
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Text('Return Date :'.tr),
                            Text(student['Return_Date'] ?? ""),
                          ],
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
                    Navigator.of(context).pop(true); // Confirm
                  },
                  child: Text('Confirm'.tr),
                ),
              ],
            );
          },
        );
      },
    ).then((confirmed) {
      if (confirmed) {
        setState(() {
          // Handle updating logic here, such as refreshing the UI
        });
      }
    });
  }
}
