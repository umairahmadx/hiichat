import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hiichat/firebase/authentication.dart';
import 'package:hiichat/nestedScreen/login/services/emailverification.dart';

import '../../firebase/firebaseapis.dart';
import 'login.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

Future<bool> isUsernameAvailable(String username) async {
  // Reference to the Firestore collection
  final QuerySnapshot result = await AllAPIs.firestore
      .collection('user')
      .where('username', isEqualTo: username)
      .limit(1)
      .get();

  // Check if any document with the same username exists
  return result.docs.isEmpty; // Returns true if the username is available
}

class _SignupState extends State<Signup> {
  String _email = "";
  String _password = "";
  String _cnfPassword = "";
  String _name = "";
  String _username = "";
  bool isLoading = false;

  void signUpCheck() async {
    String email = _email.trim();
    String password = _password.trim();
    String cnfPassword = _cnfPassword.trim();
    String name = _name.trim();
    String username = _username.trim();

    // Check for empty fields
    if (email.isEmpty ||
        password.isEmpty ||
        name.isEmpty ||
        username.isEmpty ||
        cnfPassword.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All fields are required')),
        );
      }
      return;
    }

    // Check for valid email format (trimmed, no spaces inside)
    RegExp emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid email address')),
        );
      }
      return;
    }

    // Check that the name does not contain numbers or special characters
    RegExp nameRegex = RegExp(r'^[a-zA-Z ]+$');
    if (!nameRegex.hasMatch(name)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Name cannot contain numbers or special characters')),
        );
      }
      return;
    }
    RegExp usernameRegex = RegExp(r'^(?=.*[a-z])[a-z][a-z0-9_]*$');

    if (!usernameRegex.hasMatch(username)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
              Text('username can only have lowercase letters and underscores')),
        );
      }
      return;
    }



    // Check password length
    if (password.length < 6) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Password must have at least 6 characters')),
        );
      }
      return;
    }

    // Check if password and confirm password match
    if (password != cnfPassword) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')),
        );
      }
      return;
    }
    setState(() {
      isLoading = true;
    });
    if(await isUsernameAvailable(username) == false){
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This username is unavailable')),
        );
      }
      setState(() {
        isLoading = false;
      });
      return;
    }

    String res = await AuthService().signUpUser(
      email: email,
      password: password,
      name: name,
      username: username,
    );

    if (mounted) {
      if (res == 'success') {
        isLoading = false;
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const EmailVerification()),
        );
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(res)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context)
                .size
                .height, // Make sure it covers the entire screen height
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                // Centers the content
                children: [
                  const Text(
                    "Create an account",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    onChanged: (newValue) => _name = newValue,
                    decoration: InputDecoration(
                      hintText: 'Name',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      fillColor: Colors.grey[100],
                      filled: true,
                      prefixIcon: const Icon(Icons.abc_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Email TextField
                  TextFormField(
                    onChanged: (newValue) => _email = newValue,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      fillColor: Colors.grey[100],
                      filled: true,
                      prefixIcon: const Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    onChanged: (newValue) => _username = newValue,
                    decoration: InputDecoration(
                      hintText: 'Username',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      fillColor: Colors.grey[100],
                      filled: true,
                      prefixIcon: const Icon(Icons.abc_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Password TextField
                  TextFormField(
                    onChanged: (newValue) => _password = newValue,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      fillColor: Colors.grey[100],
                      filled: true,
                      prefixIcon: const Icon(Icons.lock),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    onChanged: (newValue) => _cnfPassword = newValue,
                    decoration: InputDecoration(
                      hintText: 'Confirm Password',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      fillColor: Colors.grey[100],
                      filled: true,
                      prefixIcon: const Icon(Icons.lock),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        elevation: WidgetStateProperty.all(0),
                        backgroundColor:
                            WidgetStateProperty.all(Colors.blue[500]),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        signUpCheck(); // Call the signup check only if not loading
                      },
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
                              "SignUp",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account?",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => const Login()),
                            (Route<dynamic> route) =>
                                false, // Removes all previous Screens
                          );
                        },
                        child: Text(
                          " Login",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[500],
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
    );
  }
}
