// ignore_for_file: file_names, non_constant_identifier_names

import 'dart:io';

import 'package:pin_edu_pro/Models/Project_Model.dart';
import 'package:pin_edu_pro/Models/School_Model.dart';
import 'package:pin_edu_pro/Services/global.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

class SQLiteHelper {
  static const String _dbName = "Pin_EDU.db";
  Database? _database;

  static String get dbName => _dbName; // Public getter for _dbName
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await initDB();
    return _database!;
  }

  static Future<Database> initDB() async {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      final databaseFactory = databaseFactoryFfi;
      final dbPath = join(await getDatabasesPath(), _dbName);

      return await databaseFactory.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) => _createDb(db),
        ),
      );
    } else if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
      final dbPath = join(await getDatabasesPath(), _dbName);

      return await openDatabase(
        dbPath,
        version: 1,
        onCreate: (db, version) => _createDb(db),
      );
    }
    throw Exception("Unsupported platform");
  }

// انشاء قاعدة البيانات في حال لم تكن موجودة
  static Future<Database> _getDB() async {
    return openDatabase(join(await getDatabasesPath(), _dbName),
        onCreate: (db, version) => _createDb(db), version: 1);
  }

  static void _createDb(Database db) {
    db.execute(
        'CREATE TABLE IF NOT EXISTS classroom (Class_id INTEGER PRIMARY KEY AUTOINCREMENT, Class_name TEXT, Grade_Name TEXT, School_Name TEXT);');
    db.execute(
        'CREATE TABLE IF NOT EXISTS grades (Grade_ID INTEGER PRIMARY KEY AUTOINCREMENT, Grade_name TEXT, School_Name TEXT);');
    db.execute(
        'CREATE TABLE IF NOT EXISTS projects (Pro_ID INTEGER PRIMARY KEY AUTOINCREMENT, Pro_Name TEXT, Pro_Code TEXT);');
    db.execute(
        'CREATE TABLE IF NOT EXISTS school (SchoolID INTEGER PRIMARY KEY AUTOINCREMENT, School_Name TEXT, Des TEXT, School_Code TEXT, Pro_id INTEGER);');
    db.execute(
        'CREATE TABLE IF NOT EXISTS staff (staff_ID INTEGER PRIMARY KEY AUTOINCREMENT, Fullname TEXT, Gender TEXT, Position TEXT,Contract_No TEXT, School_Name TEXT , Pro_ID INTEGER);');
    db.execute(
        'CREATE TABLE IF NOT EXISTS "students" ("student_ID"	INTEGER,	"Firstname"	TEXT,	"Fathername"	TEXT,	"Lastname"	TEXT,	"Mothername"	TEXT,	"LastMothername"	TEXT,	"birthday_date"	TEXT,	"reg_date"	TEXT,	"enroll_date"	TEXT,	"CareFirstname"	TEXT,	"CareLastname"	TEXT,	"Care_relation"	TEXT,	"PhoneNumber"	TEXT,	"CareID"	TEXT,	"Reason_Enrolment"	TEXT,	"time_dropped_out_learing"	TEXT,	"Governorate"	TEXT,	"District"	TEXT,	"gender"	TEXT,	"Residency_Status"	TEXT,	"Type_disability"	TEXT,	"Grade_Name"	TEXT,	"Class_Name"	TEXT,	"school_name"	TEXT, "pro_ID" INTEGER, PRIMARY KEY("student_ID" AUTOINCREMENT));');
    db.execute(
        'CREATE TABLE IF NOT EXISTS attendance (id INTEGER , student_id INTEGER, day_id INTEGER,attend INTEGER,month_ID INTEGER , year_ID INTEGER, PRIMARY KEY( id  AUTOINCREMENT));');
    db.execute(
        'CREATE TABLE IF NOT EXISTS academic_year(id INTEGER , start_date TEXT, end_date TEXT);');
    db.execute(
        'CREATE TABLE IF NOT EXISTS months(id INTEGER ,year_id INTEGER, month TEXT,FOREIGN KEY (year_id) REFERENCES academic_year(id));');
    db.execute('CREATE TABLE IF NOT EXISTS days('
        'id INTEGER PRIMARY KEY AUTOINCREMENT, '
        'month_id INTEGER, '
        'day INTEGER, '
        'date TEXT, '
        'FOREIGN KEY (month_id) REFERENCES months(id)'
        ');');
    db.execute(
        'CREATE TABLE IF NOT EXISTS "totalatte" (	"id"	INTEGER,	"student_id"	INTEGER,	"month_ID"	INTEGER,	"year_ID"	INTEGER,	"attendance_count"	INTEGER,	PRIMARY KEY("id" AUTOINCREMENT));');
    db.execute(
        'CREATE TABLE IF NOT EXISTS droptitel(Drop_ID INTEGER PRIMARY KEY AUTOINCREMENT , Drop_Titel TEXT);');
    db.execute(
        'CREATE TABLE IF NOT EXISTS dropout_student(id INTEGER PRIMARY KEY AUTOINCREMENT ,Student_id INTEGER, Dropout_res TEXT, Class_Name TEXT, Grade_Name TEXT, School_Name TEXT, Dropout_Date TEXT,Return_Date TEXT);');
    db.execute(
        'CREATE TABLE IF NOT EXISTS users("user_id"	INTEGER,	"username"	TEXT,	"password"	TEXT,	"School_Name"	TEXT,	"role"	TEXT,	PRIMARY KEY("user_id" AUTOINCREMENT))');
    db.execute(
        'CREATE TABLE IF NOT EXISTS "temp_reg_student" (	"tmp_id"	INTEGER,	"Firstname"	TEXT,	"Fathername"	TEXT,	"Lastname"	TEXT,	"Mothername"	TEXT,	"LastMothername"	TEXT,	"birthday_date"	TEXT,	"reg_date"	TEXT,	"enroll_date"	TEXT,	"CareFirstname"	TEXT,	"CareLastname"	TEXT,	"Care_relation"	TEXT,	"PhoneNumber"	TEXT,	"CareID"	TEXT,	"Reason_Enrolment"	TEXT,	"time_dropped_out_learing"	TEXT,	"Governorate"	TEXT,	"District"	TEXT,	"gender"	TEXT,	"Residency_Status"	TEXT,	"Type_disability"	TEXT,	"Grade_Name"	TEXT,	"Class_Name"	TEXT,	"school_name"	TEXT,	"status"	TEXT, "User" TEXT	,"pro_ID" INTEGER,PRIMARY KEY("tmp_id" AUTOINCREMENT));');
  }

  static Future<List<project_model?>?> GetPro() async {
    final db = await _getDB();
    final List<Map<String, dynamic>> maps = await db.query('projects');
    project_List =
        List<project_model>.from(maps.map((x) => project_model.fromJson(x)));
    return project_List;
  }

  static Future<List<School_Model?>?> GetSchool(int Pro_ID) async {
    final db = await _getDB();
    final List<Map<String, dynamic>> maps = await db.query(
      'school',
      where: 'Pro_id=?',
      whereArgs: [Pro_ID],
    );
    school_List =
        List<School_Model>.from(maps.map((x) => School_Model.fromJson(x)));

    return school_List;
  }

  static Future<List<School_Model?>?> GetGrade(
      int Pro_ID, String School_ID) async {
    final db = await _getDB();
    final List<Map<String, dynamic>> maps = await db.query(
      'school',
      where: 'Pro_id=?',
      whereArgs: [Pro_ID],
    );
    school_List =
        List<School_Model>.from(maps.map((x) => School_Model.fromJson(x)));

    return school_List;
  }

  Future<List<Map<String, dynamic>>> queryAllRows(String table) async {
    Database db = await database;
    return await db.query(table);
  }

  Future<List<Map<String, dynamic>>> queryAllRowswithcondition(
      String table, String Where, String whereArgs) async {
    Database db = await database;
    return await db.query(table, where: Where, whereArgs: [whereArgs]);
  }

  Future<int> updateDay(Map<String, dynamic> row) async {
    Database db = await database;
    int id = row['id'];
    return await db.update('days', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getAttendanceByMonth(int monthId) async {
    Database db = await database;
    return await db.query('days', where: 'month_id = ?', whereArgs: [monthId]);
  }

  Future<int> insertDay(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('days', row);
  }
}
