import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../firebase/firebaseapis.dart';
import '../../../home.dart';
import '../signup.dart';

class EmailVerification extends StatefulWidget {
  const EmailVerification({super.key});

  @override
  EmailVerificationState createState() => EmailVerificationState();
}

class EmailVerificationState extends State<EmailVerification> {
  bool _isButtonDisabled = false; // Flag to disable the button
  int _remainingTime = 30; // Countdown timer
  Timer? _timer; // Timer instance
  bool isLoading = false;

  void _startTimer() {
    setState(() {
      _isButtonDisabled = true; // Disable button when clicked
      _remainingTime = 30; // Reset timer to 30 seconds
    });

    // Start a 30-second timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--; // Decrease remaining time
        });
      } else {
        // Stop the timer when it reaches zero
        _timer?.cancel();
        setState(() {
          _isButtonDisabled = false; // Re-enable button
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sendEmailVerification();
    });
  }

  Future<void> sendEmailVerification() async {
    User? user = AllAPIs.auth.currentUser;
    if (user != null && !user.emailVerified) {
      try {
        await user.sendEmailVerification();
        if (mounted) {
          _showSnackBar("Verification email has been successfully sent.");
        }
      } catch (e) {
        _showSnackBar("Error sending verification email: $e");
      }
    }
  }

  Future<void> checkEmailVerification() async {
    setState(() {
      isLoading = true;
    });
    User? user = AllAPIs.auth.currentUser;
    if (user != null) {
      await user.reload(); // Refresh user data
      user = AllAPIs.auth.currentUser; // Get the updated user

      if (user != null && user.emailVerified) {
        await AllAPIs.firestore
            .collection('user')
            .doc(user.uid)
            .update({
          'emailVerified': user.emailVerified,
        });
        if (mounted) {
          _showSnackBar("Verification successfully verified");
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (Route<dynamic> route) => false,
          );
        }
      } else {
        setState(() {
          isLoading = false;
        });
        if (mounted) {
          _showSnackBar("Email Not Verified");
        }
      }
    }
  }

  Future<void> deleteUser() async {
    User? user = AllAPIs.auth.currentUser;

    if (user != null) {
      // Show confirmation dialog before deletion
      bool? confirm = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              "Wrong Email",
            ),
            content: const Text("Are you sure you want to continue?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // No
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true), // Yes
                child: const Text("Yes"),
              ),
            ],
          );
        },
      );

      if (confirm == true) {
        try {
          // Delete user document from Firestore
          await AllAPIs.firestore
              .collection('user')
              .doc(user.uid)
              .delete();
          // Delete the user from Firebase Auth
          await user.delete();
          // Navigate back to Signup screen
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const Signup()),
              (Route<dynamic> route) => false,
            );
          }
        } catch (e) {
          _showSnackBar("Error deleting user: $e");
        }
      }
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer if the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    User? user = AllAPIs.auth.currentUser;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.email_outlined,
                    size: 80,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      "Verify Your Email",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "We’ve sent a verification link to your ${user?.email ?? "email address"} address. "
                    "Please check your inbox and click on the link to verify your email.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "If you don’t see the email, check your spam or junk folder.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        checkEmailVerification(); // Call the email verification check function
                      },
                      style: ButtonStyle(
                        elevation: WidgetStateProperty.all(0),
                        backgroundColor: WidgetStateProperty.all(Colors.blue),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      child: isLoading
                          ? Container(
                              padding: const EdgeInsets.all(10),
                              height: 40, // Set height to match the button
                              width: 40, // Set width to match the button
                              child: const CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              "Verify Email",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  GestureDetector(
                    onTap: _isButtonDisabled
                        ? null // Disable button if the timer is running
                        : () {
                            sendEmailVerification(); // Resend email verification
                            _startTimer(); // Start the timer when button is pressed
                          },
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        _isButtonDisabled
                            ? "Wait for $_remainingTime seconds before sending mail" // Display countdown text
                            : "Resend Verification Email",
                        style: TextStyle(
                          color: _isButtonDisabled ? Colors.grey : Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: TextButton(
        style: const ButtonStyle(shape: WidgetStatePropertyAll( LinearBorder())),
        onPressed: deleteUser,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.arrow_back_ios_new_rounded,color: Colors.blue,),
            SizedBox(width: 10,),
            Text(
              "Not your email? Sign up again",
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
