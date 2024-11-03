// ignore_for_file: file_names, library_private_types_in_public_api, unused_field

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_edu_pro/Services/socket_services.dart';
import 'package:pin_edu_pro/Users/login.dart';
import 'package:pin_edu_pro/Widgets/appthem.dart';
import 'package:wave_loading_indicator/wave_progress_widget.dart';

class SplashUI extends StatefulWidget {
  const SplashUI({super.key});
  @override
  _SplashUIState createState() => _SplashUIState();
}

class _SplashUIState extends State<SplashUI> {
  double _progress = 0.0;
  String _progressMessage = 'Starting...';

  double normalizeProgress(double progress) {
    // Ensure progress is between 0 and 100
    return progress < 0 ? 0 : (progress > 100 ? 100 : progress);
  }

  Future<void> progressord() async {
    // Update callback to handle only double progress
    SocketService.setProgressCallback((progress) {
      setState(() {
        _progress = normalizeProgress(progress);
        _progressMessage = 'Fetching data: ${_progress.toStringAsFixed(2)}%';
      });
    });

    SocketService.awaitDataCompletion().then((_) async {
      Get.offAll(() => const Login());
    });
  }

  @override
  void initState() {
    super.initState();
    progressord();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade800,
      body: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          Positioned(
            bottom: 100,
            left: 0,
            child: Container(
              height: AppTheme.fullHeight(context) * 1.2,
              width: AppTheme.fullWidth(context) * 2,
              margin: const EdgeInsets.all(100.0),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(.2),
                radius: 5,
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 10,
            child: Container(
              height: AppTheme.fullHeight(context) * 1.2,
              width: AppTheme.fullWidth(context) * 2,
              margin: const EdgeInsets.all(100.0),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(.2),
                radius: 5,
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 10,
            child: Container(
              height: AppTheme.fullHeight(context) * 1.2,
              width: AppTheme.fullWidth(context) * 2,
              margin: const EdgeInsets.all(100.0),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(.2),
                radius: 5,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 10,
            child: Container(
              height: AppTheme.fullHeight(context) * 1.2,
              width: AppTheme.fullWidth(context) * 2,
              margin: const EdgeInsets.all(100.0),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(.2),
                radius: 5,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 50,
            child: Container(
              height: AppTheme.fullHeight(context) * 5,
              width: AppTheme.fullWidth(context) * 2,
              margin: const EdgeInsets.all(100.0),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(.2),
                radius: 5,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: AppTheme.fullHeight(context) / 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  "assets/images/logo/logo.png",
                  height: 150,
                  width: 150,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: AppTheme.fullHeight(context) / 20),
              WaveProgress(
                size: 180,
                borderColor: Colors.white10,
                foregroundWaveColor: Colors.blueAccent,
                backgroundWaveColor: Colors.blue.shade50,
                progress: _progress,
              ),
              Text(
                '${'Downloading data'.tr}    ${_progress.toStringAsFixed(2)}%',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
