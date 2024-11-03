// ignore_for_file: camel_case_types, file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_edu_pro/Admins/Project_Details_UI.dart';
import 'package:pin_edu_pro/Services/global.dart';
import 'package:pin_edu_pro/Widgets/Project_card_Widget.dart';
class Projects_Widget extends StatefulWidget {
  const Projects_Widget({super.key});

  @override
  State<Projects_Widget> createState() => _Projects_WidgetState();
}

class _Projects_WidgetState extends State<Projects_Widget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: List.generate(
          project_List.length,
          (index) => Project_car_Widget(
                Project_Model: project_List[index],
                onTap: () {

                  
                  Get.to(Project_Details_UI(
                      proID: project_List[index].Pro_ID,
                      ProjectName: project_List[index].Pro_Name));
                },
              )),
    );
  }
}
