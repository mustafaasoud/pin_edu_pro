// ignore_for_file: camel_case_types, non_constant_identifier_names, avoid_print, avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:pin_edu_pro/Services/DataServices.dart';
import 'package:pin_edu_pro/Widgets/appthem.dart'; // Ensure you import your data service

class statistics_widget extends StatefulWidget {
  const statistics_widget({Key? key}) : super(key: key);

  @override
  State<statistics_widget> createState() => _statistics_widgetState();
}

class _statistics_widgetState extends State<statistics_widget> {
  Map<String, double> dataMap = {
    'EDU Projects': 0, // Initialize with default value
  };
  Map<String, double> dataMap2 = {
    'EDU Projects': 0, // Initialize with default value
  };
  Map<String, Map<String, double>> projectGenderCountMap = {};
  Map<String, Map<String, double>> projectGenderCountMapstaff = {};
  @override
  void initState() {
    super.initState();
    fetchStudentDetails();
    FetchGender();
    FetchGenderStaff();
    fetchStaffDetails();
  }

  Future<void> fetchStudentDetails() async {
    final db = await SQLiteHelper().database;
    final res = await db.rawQuery('''
      SELECT projects.Pro_Name,
             COUNT(students.Firstname) AS StudentCount
      FROM projects
      INNER JOIN students ON projects.Pro_ID = students.pro_ID
      GROUP BY projects.Pro_Name;
    ''');
    print(res);
    if (res.isNotEmpty) {
      setState(() {
        dataMap = {
          for (var item in res)
            item['Pro_Name'] as String: (item['StudentCount'] as int).toDouble()
        };
      });
    } else {
      setState(() {
        dataMap = {
          'No Data': 0, // Example of setting a default value
        };
      });
    }
  }
////////

  Future<void> fetchStaffDetails() async {
    final db = await SQLiteHelper().database;
    final res = await db.rawQuery('''
      SELECT projects.Pro_Name,
             COUNT(staff.Fullname) AS Staffcount
      FROM projects
      INNER JOIN staff ON projects.Pro_ID = staff.pro_ID
      GROUP BY projects.Pro_Name;
    ''');
    print(res);
    if (res.isNotEmpty) {
      setState(() {
        dataMap2 = {
          for (var item in res)
            item['Pro_Name'] as String: (item['Staffcount'] as int).toDouble()
        };
      });
    } else {
      setState(() {
        dataMap2 = {
          'No Data': 0, // Example of setting a default value
        };
      });
    }
  }

  Future<void> FetchGender() async {
    final db = await SQLiteHelper().database;
    final res = await db.rawQuery('''
      SELECT projects.Pro_Name,
             COUNT(students.Firstname) AS StudentCount,
             SUM(CASE WHEN students.Gender = 'Male' THEN 1 ELSE 0 END) AS MaleCount,
             SUM(CASE WHEN students.Gender = 'Female' THEN 1 ELSE 0 END) AS FemaleCount
      FROM projects
      INNER JOIN students ON projects.Pro_ID = students.pro_ID
      GROUP BY projects.Pro_Name;
    ''');
    print(res);
    if (res.isNotEmpty) {
      setState(() {
        projectGenderCountMap = {
          for (var item in res)
            item['Pro_Name'] as String: {
              'Male': (item['MaleCount'] as int).toDouble(),
              'Female': (item['FemaleCount'] as int).toDouble(),
            }
        };
      });
    } else {
      setState(() {
        projectGenderCountMap = {
          'No Data': {
            'Male': 0,
            'Female': 0,
          }
        };
      });
    }
  }

///////
  Future<void> FetchGenderStaff() async {
    final db = await SQLiteHelper().database;
    final res = await db.rawQuery('''
      SELECT projects.Pro_Name,
             COUNT(staff.Fullname) AS staffCount,
             SUM(CASE WHEN staff.Gender = 'Male' THEN 1 ELSE 0 END) AS MaleCount,
             SUM(CASE WHEN staff.Gender = 'Female' THEN 1 ELSE 0 END) AS FemaleCount
      FROM projects
      INNER JOIN staff ON projects.Pro_ID = staff.pro_ID
      GROUP BY projects.Pro_Name;
    ''');
    print(res);
    if (res.isNotEmpty) {
      setState(() {
        projectGenderCountMapstaff = {
          for (var item in res)
            item['Pro_Name'] as String: {
              'Male': (item['MaleCount'] as int).toDouble(),
              'Female': (item['FemaleCount'] as int).toDouble(),
            }
        };
      });
    } else {
      setState(() {
        projectGenderCountMapstaff = {
          'No Data': {
            'Male': 0,
            'Female': 0,
          }
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              toolbarHeight: 10,
              backgroundColor: Colors.blue,
              bottom: const TabBar(
                tabs: [
                  Tab(
                    icon: Icon(Icons.school),
                    text: "الطلاب",
                  ),
                  Tab(
                    icon: Icon(Icons.person),
                    text: "الموظفين",
                  ),
                ],
              ),
            ),
            body: TabBarView(children: [
              StudentStatistics(),
              StaffStatistics(), // Placeholder for staff statistics
            ])));
  }

  Widget StudentStatistics() {
    return ListView(
      children: [
        const Gap(20),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: PieChart(
            dataMap: dataMap,
            animationDuration: const Duration(milliseconds: 800),
            chartLegendSpacing: 32,
            chartRadius: MediaQuery.of(context).size.width / 1.5,
            initialAngleInDegree: 0,
            chartType: ChartType.ring,
            ringStrokeWidth: 10,
            centerText: "EDU Chart",
            legendOptions: const LegendOptions(
              showLegendsInRow: true,
              legendPosition: LegendPosition.left,
              showLegends: true,
              legendTextStyle: TextStyle(
                fontWeight: FontWeight.normal,
              ),
            ),
            chartValuesOptions: const ChartValuesOptions(
              showChartValueBackground: true,
              showChartValues: true,
              showChartValuesInPercentage: false,
              showChartValuesOutside: false,
              decimalPlaces: 1,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: projectGenderCountMap.entries.map((entry) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 50,
                    width: AppTheme.fullWidth(context) / 2,
                    child: Card(
                      elevation: 2,
                      child: Center(
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  PieChart(
                    dataMap: entry.value,
                    animationDuration: const Duration(milliseconds: 800),
                    chartLegendSpacing: 32,
                    chartRadius: MediaQuery.of(context).size.width / 1.5,
                    initialAngleInDegree: 0,
                    chartType: ChartType.ring,
                    ringStrokeWidth: 10,
                    centerText: entry.key,
                    legendOptions: const LegendOptions(
                      showLegendsInRow: true,
                      legendPosition: LegendPosition.left,
                      showLegends: true,
                      legendTextStyle: TextStyle(),
                    ),
                    chartValuesOptions: const ChartValuesOptions(
                      showChartValueBackground: true,
                      showChartValues: true,
                      showChartValuesInPercentage: true,
                      showChartValuesOutside: false,
                      decimalPlaces: 1,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget StaffStatistics() {
    return ListView(
      children: [
        const Gap(20),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: PieChart(
            dataMap: dataMap2,
            animationDuration: const Duration(milliseconds: 800),
            chartLegendSpacing: 32,
            chartRadius: MediaQuery.of(context).size.width / 1.5,
            initialAngleInDegree: 0,
            chartType: ChartType.ring,
            ringStrokeWidth: 10,
            centerText: "EDU Chart",
            legendOptions: const LegendOptions(
              showLegendsInRow: true,
              legendPosition: LegendPosition.left,
              showLegends: true,
              legendTextStyle: TextStyle(
                fontWeight: FontWeight.normal,
              ),
            ),
            chartValuesOptions: const ChartValuesOptions(
              showChartValueBackground: true,
              showChartValues: true,
              showChartValuesInPercentage: false,
              showChartValuesOutside: false,
              decimalPlaces: 1,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: projectGenderCountMapstaff.entries.map((entry) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 50,
                    width: AppTheme.fullWidth(context) / 2,
                    child: Card(
                      elevation: 2,
                      child: Center(
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  PieChart(
                    dataMap: entry.value,
                    animationDuration: const Duration(milliseconds: 800),
                    chartLegendSpacing: 32,
                    chartRadius: MediaQuery.of(context).size.width / 1.5,
                    initialAngleInDegree: 0,
                    chartType: ChartType.ring,
                    ringStrokeWidth: 10,
                    centerText: entry.key,
                    legendOptions: const LegendOptions(
                      showLegendsInRow: true,
                      legendPosition: LegendPosition.left,
                      showLegends: true,
                      legendTextStyle: TextStyle(),
                    ),
                    chartValuesOptions: const ChartValuesOptions(
                      showChartValueBackground: true,
                      showChartValues: true,
                      showChartValuesInPercentage: true,
                      showChartValuesOutside: false,
                      decimalPlaces: 1,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
