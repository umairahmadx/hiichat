import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hiichat/firebase/firebaseapis.dart';
import 'package:hiichat/mobile/mobilehome.dart';
import 'package:hiichat/wide/widehome.dart';
import 'nestedScreen/layoutscreen.dart';
import 'nestedScreen/login/login.dart';
import 'nestedScreen/login/services/emailverification.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
