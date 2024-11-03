// ignore_for_file: non_constant_identifier_names, camel_case_types, avoid_print, prefer_const_constructors, file_names, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:pin_edu_pro/HeadTeacher/schooldetails.dart';
import 'package:pin_edu_pro/Models/School_Model.dart';
 
import 'package:pin_edu_pro/Services/DataServices.dart';
import 'package:pin_edu_pro/Widgets/school_CArd_widget.dart';

class Project_Details_UI extends StatefulWidget {
  final int proID;
  final String ProjectName;
  const Project_Details_UI(
      {required this.proID, required this.ProjectName, super.key});

  @override
  State<Project_Details_UI> createState() => _Project_Details_UIState();
}

class _Project_Details_UIState extends State<Project_Details_UI> {
  bool isLoading = true;
  String? errorMessage;
  late List<School_Model> school_List_temp = [];
  Future<void> GEtSchools(int Pro_ID) async {
    try {
      final db = await SQLiteHelper().database;
      final List<Map<String, dynamic>> maps = await db.query(
        'school',
        where: 'Pro_id=?',
        whereArgs: [Pro_ID],
      );
      setState(() {
        school_List_temp =
            List<School_Model>.from(maps.map((x) => School_Model.fromJson(x)));
        isLoading = false;
    
      });
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    GEtSchools(widget.proID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('PIN EDU'),
            Gap(10),
            SvgPicture.asset(
              'assets/images/logo/logo.svg', // path to your SVG file
              height: 24.0,
              width: 24.0,
              color: Colors.white, // optional: to color the SVG icon
            ),
          ],
        ),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text('Error: $errorMessage'))
              : school_List_temp.isEmpty
                  ? Center(child: Text('No schools found.'))
                  : ListView.builder(
                      itemCount: school_List_temp.length,
                      itemBuilder: (context, index) {
                        return school_card_widget(
                            school_model: school_List_temp[index],
                            onTap: () {
                              Get.to(() => School_details_UI(
                                  school_Name:
                                      school_List_temp[index].School_Name));
                            });
                      },
                    ),
    );
  }
}
