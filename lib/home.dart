import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hiichat/firebase/firebaseapis.dart';
import 'package:hiichat/mobile/mobilehome.dart';
import 'package:hiichat/wide/widehome.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'nestedScreen/layoutscreen.dart';
import 'nestedScreen/login/login.dart';
import 'nestedScreen/login/services/emailverification.dart';
import 'package:http/http.dart' as http;

import 'nestedScreen/updatecheck.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String latestVersion = "";
  String currentVersion = "";
  String newAppUrl = "";

  Future<void> currentVersionApp() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    currentVersion = packageInfo.version;
  }

  Future<void> checkLatestVersion(BuildContext context) async {
    const repositoryOwner = 'umairahmadx'; //add your own owner name
    const repositoryName = 'hiichat'; //your repoName
    final response = await http.get(Uri.parse(
      'https://api.github.com/repos/$repositoryOwner/$repositoryName/releases/latest',
    ));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final tagName = data['tag_name'];
      latestVersion = tagName;
      final assets = data['assets'] as List<dynamic>;
      for (final asset in assets) {
        final assetDownloadUrl = asset['browser_download_url'];
        newAppUrl = assetDownloadUrl;
      }

      if (latestVersion != currentVersion) {
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => UpdateCheck(newAppUrl: newAppUrl,)),
            (Route<dynamic> route) => false,
          );
        }
      }
    }
  }

  @override
  void initState() {
    if (Platform.isAndroid) {
      currentVersionApp();
      checkLatestVersion(context);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: LayoutScreenSize(
        mobileScreen: StreamBuilder<User?>(
          stream: AllAPIs.auth.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              _showErrorSnackBar("Error occurred, please login again");
              return const Login();
            }

            if (snapshot.hasData) {
              User? user = snapshot.data;
              if (user != null && user.emailVerified) {
                return const MobileHome();
              } else {
                return const EmailVerification();
              }
            } else {
              return const Login();
            }
          },
        ),
        wideScreen: const WideHome(),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    });
  }
}
