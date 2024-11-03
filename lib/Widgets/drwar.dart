// ignore_for_file: unused_element, prefer_const_constructors, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, deprecated_member_use, unused_import

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_edu_pro/Admins/Home_UI.dart';
import 'package:pin_edu_pro/HeadTeacher/schooldetails.dart';
import 'package:pin_edu_pro/Services/global.dart';
import 'package:pin_edu_pro/Services/socket_services.dart';
import 'package:pin_edu_pro/Users/login.dart';

import 'package:pin_edu_pro/Widgets/appthem.dart';

Widget drawers() {
  return Drawer(
    elevation: 20,
    child: Container(
      color: AppTheme.card4,
      child: GestureDetector(
        onTap: () {
          Get.back();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8, top: 8),
              child: IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(0xffFDCF09),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 35,
                        backgroundImage:
                            AssetImage('assets/images/logo/logo.png'),
                      ),
                    ),
                    VerticalDivider(
                      thickness: 1,
                      width: 1,
                      color: AppTheme.card2,
                    ),
                    Text(
                      UsernameEntry!,
                      style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              color: Colors.white,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(250, 30),
                primary: Colors.amber,
                onPrimary: const Color(0xFFFFFFFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {},
              child: Text('Languge'.tr),
            ),
            Divider(
              color: Colors.white,
            ),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton.icon(
                  label: Text(
                    'List School People in neeed'.tr,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.normal),
                  ),
                  onPressed: () {},
                  icon: Icon(
                    Icons.shop,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton.icon(
                  label: Text(
                    'Contact US'.tr,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.normal),
                  ),
                  onPressed: () {},
                  icon: Icon(
                    Icons.call_rounded,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton.icon(
                  label: Text(
                    'About This Application'.tr,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.normal),
                  ),
                  onPressed: () {
                    Get.dialog(
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Material(
                                  child: Column(
                                    children: [
                                      Text(
                                        "PIN EDU APP",
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        height: 300,
                                        child: SingleChildScrollView(
                                          child: Text(
                                            textAlign: TextAlign.center,
                                            " ",
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                minimumSize: const Size(0, 45),
                                                primary: Colors.amber,
                                                onPrimary:
                                                    const Color(0xFFFFFFFF),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              onPressed: () {
                                                Get.back();
                                              },
                                              child: Text(
                                                'Close'.tr,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.info,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton.icon(
                  label: Text(
                    "Log Out".tr,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.normal),
                  ),
                  onPressed: () {
                    SocketService.connectAndListen();
                    Get.offAll(() => const Login());
                  },
                  icon: Icon(
                    Icons.logout,
                    color: Colors.white,
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
