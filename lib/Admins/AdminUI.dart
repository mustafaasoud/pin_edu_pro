// ignore_for_file: non_constant_identifier_names, file_names, avoid_print, unused_field, prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:pin_edu_pro/Admins/Home_UI.dart';
import 'package:pin_edu_pro/Admins/Operations/school_op.dart';
import 'package:pin_edu_pro/Admins/TempStudents/Student_temp_status.dart';
import 'package:pin_edu_pro/Services/DataServices.dart';
import 'package:pin_edu_pro/Services/global.dart';
import 'package:pin_edu_pro/Services/socket_services.dart';
import 'package:pin_edu_pro/Widgets/appthem.dart';

class AdminUI extends StatefulWidget {
  const AdminUI({Key? key}) : super(key: key);

  @override
  State<AdminUI> createState() => _AdminUIState();
}

class _AdminUIState extends State<AdminUI> {
  List<Map<String, dynamic>> allUserList = [];
  List<Map<String, dynamic>> updatedUserList = [];

  Future<void> updateUsers() async {
    final db = await SQLiteHelper().database;
    allUserList = await db.query('users');
    updatedUserList = allUserList.map((user) {
      bool isOnline =
          onlineuser.any((online) => online['username'] == user['username']);
      return {...user, 'isOnline': isOnline};
    }).toList();
    if (updatedUserList.isNotEmpty) {
      setState(() {});
    }
  }

  @override
  void initState() {
    updateUsers();
    SocketService.UserStream.listen((onlineuser) {
      setState(() {
        updateUsers();
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              splashRadius: 25,
              onPressed: () {
                Get.offAll(() => const Home_UI());
              },
              icon: const Icon(Icons.home))
        ],
        title: const Text('لوحة تحكم المستخدم'),
      ),
      body: ListView(
        children: [
          if (updatedUserList.isEmpty)
            const Center(child: Text('No connected users.'))
          else
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: updatedUserList.length,
                itemBuilder: (context, index) {
                  // تحديد حالة الاتصال للمستخدم
                  bool isOnline = updatedUserList[index]['isOnline'];

                  // تعيين الأيقونة واللون بناءً على حالة الاتصال
                  Icon icon = Icon(
                    isOnline ? Icons.online_prediction : Icons.offline_bolt,
                    color: isOnline ? Colors.green : Colors.red,
                  );
                  Color? chipColor =
                      isOnline ? Colors.lightGreenAccent : Colors.grey[300];

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        if (updatedUserList[index]['username'] !=
                            UsernameEntry) {
                          SocketService().sendNotification(
                              updatedUserList[index]['username'],
                              "The student has been registered successfully\nYou can go and verify his registration");
                        }
                      },
                      child: Chip(
                        backgroundColor: chipColor,
                        avatar: icon,
                        elevation: 2,
                        label: Text(updatedUserList[index]['username']),
                      ),
                    ),
                  );
                },
              ),
            ),
          const Gap(10),
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              management_card(
                'School management',
                AppTheme.card1,
                () {
                  Get.offAll(() => const school_op_UI());
                },
              ),
              management_card(
                'Grade management',
                AppTheme.card2,
                () {},
              ),
              management_card(
                'Classroom management',
                AppTheme.card3,
                () {},
              ),
              management_card(
                'Students management',
                AppTheme.card4,
                () {
                  Get.offAll(() => const student_temp_status());
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget management_card(
      String TEXTBOX, Color color, VoidCallback onPressCallback) {
    return SizedBox(
      height: 250,
      width: 175,
      child: Card(
        color: color,
        margin: const EdgeInsets.only(
            left: 10.0, right: 5.0, top: 20.0, bottom: 20.0),
        elevation: 10.0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: InkWell(
          onTap: onPressCallback,
          child: Align(
            alignment: Alignment.center,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Text(
                    TEXTBOX,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
