// ignore_for_file: unused_local_variable

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pin_edu_pro/Services/DataServices.dart';
import 'package:pin_edu_pro/Services/socket_services.dart';
import 'package:pin_edu_pro/Users/splashUI.dart';
import 'package:pin_edu_pro/localization/translation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> main() async {
  await initializeDateFormatting('ar', null);
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  } else {
    await SQLiteHelper.initDB();
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? langOption = prefs.getString('lang_option') ?? 'English';

  runApp(MyApp(langOption: langOption));
}

class MyApp extends StatefulWidget {
  final String langOption;

  const MyApp({
    Key? key,
    required this.langOption,
  }) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    SocketService.connectAndListen();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      translations: LocaleString(),
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
      theme: ThemeData(
        fontFamily: 'Cairo',
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home:   const SplashUI(),
    );
  }
}
