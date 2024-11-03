// ignore_for_file: file_names, camel_case_types, prefer_const_constructors, void_checks, non_constant_identifier_names, deprecated_member_use, unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:pin_edu_pro/Admins/AdminUI.dart';
import 'package:pin_edu_pro/Services/DataServices.dart';
import 'package:pin_edu_pro/Services/global.dart';
import 'package:pin_edu_pro/Services/socket_services.dart';
import 'package:pin_edu_pro/Users/login.dart';
import 'package:pin_edu_pro/Widgets/Projects_Widget.dart';
import 'package:pin_edu_pro/Widgets/statistics_widget.dart';

class Home_UI extends StatefulWidget {
  const Home_UI({super.key, project_List});
  @override
  State<Home_UI> createState() => _Home_UIState();
}

class _Home_UIState extends State<Home_UI> {
  void _logout() async {
    SocketService.connectAndListen();
    Get.offAll(() => const Login());
  }

  Future<void> xxx() async {
    await SQLiteHelper.GetPro();
    if (project_List.isNotEmpty) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    xxx();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
            actions: [
              IconButton(  splashRadius: 25,
                onPressed: () {
                  _logout();
                },
                icon: const Icon(Icons.logout),
              ),
              IconButton(  splashRadius: 25,
                onPressed: () {
                  Get.offAll(() => AdminUI());
                },
                icon: const Icon(Icons.admin_panel_settings),
              ),
            ],
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
            bottom: TabBar(
              tabs: const [
                Tab(
                  icon: Icon(FontAwesomeIcons.chartPie),
                  text: "احصائيات عامة",
                ),
                Tab(
                  icon: Icon(FontAwesomeIcons.p),
                  text: "مشاريع التعليم",
                ),
              ],
            )),
        body: TabBarView(
          children: const [statistics_widget(), Projects_Widget()],
        ),
      ),
    );
  }
}
