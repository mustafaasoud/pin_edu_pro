// ignore_for_file: library_prefixes, non_constant_identifier_names, avoid_print, unused_element, unused_field

import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_edu_pro/Services/DataServices.dart';
import 'package:pin_edu_pro/Services/global.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class SocketService {
  static late IO.Socket _socket;
  static Function(double)? progressCallback;
  static Completer<void>? _completer;
  static late StreamController<List<dynamic>> _userStream;

  static Stream<List<dynamic>> get UserStream => _userStream.stream;

  static void connectAndListen() {
    _userStream = StreamController<List<dynamic>>.broadcast();
    _socket = IO.io(
      'http://$URLPage',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );
    _socket.connect();
    _socket.onConnect((_) {});
    _socket.onDisconnect((_) {});
    _socket.on('progress', (progressValue) {
      progressCallback?.call(progressValue['progress'].toDouble());
    });
    _socket.on('fetch_complete', (data) async {
      await _processData(data);
      _completer?.complete();
    });
    _socket.on('updateUsers', (data) {
      addUsersToStream(data);
    });

    setupSocketListeners();
  }

  static void setupSocketListeners() {
    _socket.on('notification', (message) {
      // You can show a dialog or a snackbar to display the notification
      Get.showSnackbar(GetSnackBar(
        barBlur: 1,
        backgroundColor: Colors.blueGrey.shade200,
        title: "Message from the supervisor",
        message: message,
        icon: const Icon(
          Icons.error,
          color: Colors.white,
        ),
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(10),
      ));
    });
  }

  void sendNotification(String targetUser, String message) {
    _socket.emit(
        'sendNotification', {'targetUser': targetUser, 'message': message});
  }

  static void addUsersToStream(List<dynamic> data) {
    onlineuser = data;
    _userStream.sink.add(onlineuser);
    print(onlineuser);
  }

  static void setProgressCallback(Function(double) callback) {
    progressCallback = callback;
  }

  static Future<void> awaitDataCompletion() async {
    _completer = Completer<void>();
    await _completer!.future;
  }

  static Future<void> _processData(data) async {
    try {
      final db = await SQLiteHelper().database;
      await db.transaction((txn) async {
        Batch batch = txn.batch();
        Future<void> insertOrUpdate(String table, List<dynamic> items,
            [String? idColumn]) async {
          for (var item in items) {
            if (idColumn != null) {
              final existingItem = await txn.query(
                table,
                where: '$idColumn = ?',
                whereArgs: [item[idColumn]],
              );
              if (existingItem.isEmpty) {
                batch.insert(table, item);
              } else {
                batch.update(
                  table,
                  item,
                  where: '$idColumn = ?',
                  whereArgs: [item[idColumn]],
                );
              }
            } else {
              batch.insert(
                table,
                item,
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }
          }
        }

        await insertOrUpdate('projects', data['projects'], 'Pro_ID');
        await insertOrUpdate('staff', data['staff']);
        await insertOrUpdate('school', data['school']);
        await insertOrUpdate('grades', data['grades']);
        await insertOrUpdate('classroom', data['classroom']);
        await insertOrUpdate('students', data['students']);
        await insertOrUpdate('droptitel', data['droptitel']);
        await insertOrUpdate('dropout_student', data['dropout_student']);
        await insertOrUpdate('academic_year', data['academic_year'], 'id');
        await insertOrUpdate('months', data['months'], 'id');
        await insertOrUpdate('days', data['days'], 'id');
        await insertOrUpdate('users', data['users']);
        await insertOrUpdate('temp_reg_student', data['temp_reg_student']);
        await batch.commit(noResult: true);
      });
    } catch (e) {
      print('Error inserting data: $e');
    }
  }

  static void SocketLogin(String user, String pass) {
    _socket.emit('login', {'username': user, 'password': pass});
  }

  static void sendYear(Date) {
    _socket.emit('insertYears', Date);
  }

  static void sendMonths(Date) {
    _socket.emit('insertmonths', Date);
  }

  static void sendDays(Date) {
    _socket.emit('insertday', Date);
  }

  static void totalAttendanceSocket(data) {
    String jsonData = jsonEncode(data);
    _socket.emit('insertUpdateAttendance', jsonData);
  }

  static void update_temp_reg_student(data) {
    print(data);
    String jsonData = jsonEncode(data);
    _socket.emit('update_temp_reg_student', jsonData);
  }

  static void dropStudentList(data) {
    String jsonData = jsonEncode(data);
    _socket.emit('drop_student_list', jsonData);
  }

  static void temp_reg_student(data) {
    String jsonData = jsonEncode(data);
    _socket.emit('temp_reg_student', jsonData);
  }

  static void disconnect() {
    _socket.emit('logout');
  }

  static void dispose() {
    _userStream.close();
    _socket.dispose();
    _socket.disconnect();
    _socket.io.close();
  }
}
