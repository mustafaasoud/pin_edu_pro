// ignore_for_file: unused_local_variable, avoid_print, non_constant_identifier_names

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:pin_edu_pro/Admins/Home_UI.dart';
import 'package:pin_edu_pro/HeadTeacher/schooldetails.dart';
import 'package:pin_edu_pro/Services/DataServices.dart';
import 'package:pin_edu_pro/Services/global.dart';
import 'package:pin_edu_pro/Services/socket_services.dart';

import 'package:pin_edu_pro/Widgets/appthem.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final List<String> lang_option = [
    'العربية',
    'English',
  ];
  String? _selecte_lang_option;
  TextDirection _textDirection = TextDirection.rtl;
  @override
  void initState() {
    super.initState();
    _loadLangOption(); // Load the saved language option
  }

  void _loadLangOption() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selecte_lang_option = prefs.getString('lang_option') ?? 'English';
      _textDirection = (_selecte_lang_option == 'English')
          ? TextDirection.ltr
          : TextDirection.rtl;
    });
  }

  void _saveLangOption(String lang) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang_option', lang);
    setState(() {
      _textDirection =
          (lang == 'العربية') ? TextDirection.rtl : TextDirection.ltr;
      Get.updateLocale(lang == 'English'
          ? const Locale('en', 'US')
          : const Locale('ar', 'SY'));
    });
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      String username = _usernameController.text;
      String password = _passwordController.text;

      try {
        final db = await SQLiteHelper().database;
        List<Map<String, dynamic>> result = await db.query(
          'users',
          where: 'username = ? AND password = ?',
          whereArgs: [username, password],
        );

        if (result.isNotEmpty) {
          print(result.first['Password']);
          UsernameEntry = result.first['username'];
          Password = result.first['password'];
          School_Name = result.first['School_Name'];
          userRole = result.first['role'];

          SocketService.SocketLogin(result.first['username'].toString(),
              result.first['password'].toString());
          if (userRole == 'admin') {
            Get.offAll(() => const Home_UI());
          } else if (userRole == 'Head Teacher') {
            Get.offAll(() => School_details_UI(
                  school_Name: School_Name!,
                ));
          }
        } else {
          Get.showSnackbar(GetSnackBar(
            barBlur: 1,
            backgroundColor: Colors.red,
            title: "Login Failed".tr,
            message: "Invalid username or password".tr,
            icon: const Icon(
              Icons.error,
              color: Colors.white,
            ),
            duration: const Duration(seconds: 3),
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(10),
          ));
        }
      } catch (error) {
        Get.showSnackbar(GetSnackBar(
          barBlur: 1,
          backgroundColor: Colors.red,
          title: "Error".tr,
          message: error.toString(),
          icon: const Icon(
            Icons.error,
            color: Colors.white,
          ),
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(10),
        ));
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _textDirection, // Set the text direction
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SizedBox(
              height: AppTheme.fullHeight(context) / 1,
              child: ListView(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          height: 200,
                          width: 200,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/images/logo/logo.png"),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                labelText: 'Username'.tr,
                                labelStyle: TextStyle(
                                    fontSize: 14, color: Colors.grey.shade400),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your username'.tr;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: "password".tr,
                                labelStyle: TextStyle(
                                    fontSize: 14, color: Colors.grey.shade400),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter password'.tr;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField2(
                              dropdownStyleData: DropdownStyleData(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              decoration: InputDecoration(
                                labelText: 'Select Lang Option'.tr,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              items: lang_option
                                  .map((lang) => DropdownMenuItem<String>(
                                        value: lang,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Text(
                                            lang,
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ))
                                  .toList(),
                              value: _selecte_lang_option,
                              onChanged: (value) {
                                setState(() {
                                  _selecte_lang_option = value.toString();
                                  _saveLangOption(_selecte_lang_option!);
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Select Lang Option'.tr;
                                }
                                return null;
                              },
                            ),
                            const Gap(10),
                            ElevatedButton(
                              onPressed: _login,
                              child: Text(
                                'Log in'.tr,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const Gap(10),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
