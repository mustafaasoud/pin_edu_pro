// ignore_for_file: camel_case_types, non_constant_identifier_names, deprecated_member_use, avoid_print, unused_element

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:pin_edu_pro/HeadTeacher/Group_students_details.dart';
import 'package:pin_edu_pro/Models/staff_Model.dart';

import 'package:pin_edu_pro/Services/DataServices.dart';
import 'package:pin_edu_pro/Services/global.dart';
import 'package:pin_edu_pro/Users/login.dart';
import 'package:pin_edu_pro/Widgets/Widget_for_Schools/widgate_for_Grade.dart';
import 'package:pin_edu_pro/Widgets/appthem.dart';
import 'package:pin_edu_pro/Widgets/drwar.dart';
//import 'package:url_launcher/url_launcher.dart';

class School_details_UI extends StatefulWidget {
  final String school_Name;

  const School_details_UI({required this.school_Name, super.key});

  @override
  State<School_details_UI> createState() => _School_details_UIState();
}

class _School_details_UIState extends State<School_details_UI> {
  TextEditingController searchController = TextEditingController();
  TextEditingController searchStaffController = TextEditingController();
  var scaffoldKey = GlobalKey<ScaffoldState>();
  String searchstaffQuery = '';
  List<staff_model> stafflist = [];
  void _logout() async {
    Get.offAll(() => const Login());
  }

  Future getstaff() async {
    final db = await SQLiteHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'staff',
      where: "school_Name = ?",
      whereArgs: [widget.school_Name],
    );
    stafflist =
        List<staff_model>.from(maps.map((x) => staff_model.fromJson(x)));

    if (stafflist.isNotEmpty) {
      setState(() {});
    }
    return stafflist;
  }

  @override
  void initState() {
    super.initState();
    School_name_Admin = widget.school_Name;
    getstaff();
  }

  // Future<void> _launchURL() async {
  //   const url =
  //       'https://clovekvtisni.sharepoint.com/_layouts/15/sharepoint.aspx'; // Replace with your URL
  //   if (await canLaunch(url)) {
  //     await launch(url);
  //   } else {
  //     throw 'Could not launch $url';
  //   }
  // }
  List<staff_model> get filteredStaffList {
    if (searchstaffQuery.isEmpty) {
      return stafflist;
    } else {
      return stafflist.where((staff) {
        return staff.Fullname.toLowerCase()
            .contains(searchstaffQuery.toLowerCase());
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: drawers(),
        key: scaffoldKey,
        appBar: AppBar(
            backgroundColor: Colors.blueGrey, // Background color for AppBar
            centerTitle: true,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.school_Name,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () {
                  _logout();
                },
                icon: const Icon(Icons.logout),
              ),
              // TextButton(
              //   onPressed: () {
              //     _launchURL();
              //   },
              //   child: Text('SharePoint'),
              // ),
            ],
            bottom: TabBar(
              tabs: [
                Tab(
                  icon: const Icon(FontAwesomeIcons.child),
                  text: "Students".tr,
                ),
                Tab(
                  icon: const Icon(FontAwesomeIcons.userGroup),
                  text: "Staff".tr,
                ),
              ],
            )),
        body: TabBarView(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Gap(10),
                  InkWell(
                    child: Widgate_Grade(
                      School_Name: widget.school_Name,
                    ),
                    onTap: () {
                      Get.to(() => Group_Student_UI(
                            school_Name: widget.school_Name,
                          ));
                    },
                  )
                ],
              ),
            ),
            Column(
              children: [
                const Gap(10),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    controller: searchStaffController,
                    decoration: InputDecoration(
                      labelText: 'Search Staff by Name'.tr,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchstaffQuery = value;
                        filteredStaffList;
                      });
                    },
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: ListView(
                    children: [
                      Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          runSpacing: 1,
                          spacing: 1,
                          children:
                              List.generate(filteredStaffList.length, (index) {
                            final staff = filteredStaffList[index];

                            return GestureDetector(
                                onTap: () {},
                                child: Card(
                                  elevation: 2,
                                  child: Container(
                                    width: AppTheme.fullWidth(context) / 2.2,
                                    height: 250,
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        right: BorderSide(
                                          color: Colors.blueGrey,
                                          width: 5.0,
                                        ),
                                      ),
                                      color: Colors.white,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const Gap(10),
                                        const Icon(FontAwesomeIcons.school),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                staff.Fullname,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Divider(
                                          thickness: 2,
                                          indent: 5,
                                          endIndent: 5,
                                        ),
                                        IntrinsicHeight(
                                          child: Row(
                                            children: [
                                              const Gap(5),
                                              Text(
                                                'Gender'.tr,
                                                textAlign: TextAlign.center,
                                              ),
                                              const Gap(10),
                                              VerticalDivider(
                                                indent: 5,
                                                endIndent: 5,
                                                thickness: 1,
                                                width: 1,
                                                color: AppTheme.card2,
                                              ),
                                              const Gap(5),
                                              Text(
                                                staff.Gender.tr,
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                        IntrinsicHeight(
                                          child: Row(
                                            children: [
                                              const Gap(5),
                                              Text(
                                                'Address'.tr,
                                                textAlign: TextAlign.center,
                                              ),
                                              const Gap(5),
                                              VerticalDivider(
                                                indent: 5,
                                                endIndent: 5,
                                                thickness: 1,
                                                width: 1,
                                                color: AppTheme.card2,
                                              ),
                                              const Gap(5),
                                              const Text(
                                                'Address',
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Gap(5),
                                            Text(
                                              'Job Titel'.tr,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  color: Colors.lightBlue),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          'Job Titel'.tr,
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                        TextButton(
                                            style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        Colors.grey.shade200)),
                                            onPressed: () {},
                                            child: Text(
                                              'More Information'.tr,
                                              style: const TextStyle(
                                                  color: Colors.black),
                                            )),
                                      ],
                                    ),
                                  ),
                                ));
                          })),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
