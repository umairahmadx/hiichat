import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hiichat/firebase/firebaseapis.dart';

import '../firebase/authentication.dart';
import '../nestedScreen/login/services/logout_function.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userInfo;
  bool isLoading = true; // To handle the loading state
  final FirebaseFirestore _firestore = AllAPIs.firestore;

  @override
  void initState() {
    super.initState();
    displayUserInfo(); // Fetch user data when the screen initializes
  }

  // Function to load user data from Firestore
  void displayUserInfo() async {
    try {
      // Replace this with the appropriate email value
      String? email = "user_email@example.com";
      email = AllAPIs.auth.currentUser?.email;

      await _firestore
          .collection('user')
          .where("email", isEqualTo: email)
          .get()
          .then((snapshot) async {
        if (snapshot.docs.isNotEmpty) {
          var userData = snapshot.docs[0].data();
          setState(() {
            userInfo = {
              'Name': userData['name'],
              'UserName': userData['username'],
              'Email': userData['email'],
              'Profile': userData['profile'],
              'Uid': userData['uid']
            };
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User not found')),
            );
            try {
              await AuthService().signOut();
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error signing out: $e')),
                );
              }
            }
          }
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching user info: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator()) // Show loading spinner
            : userInfo == null
                ? const Center(
                    child:
                        Text('No user data found')) // Fallback for null userInfo
                : SingleChildScrollView(
                  child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.all(10),
                          padding: const EdgeInsets.all(10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black26),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                          child: Column(
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(
                                  userInfo?['Profile'] ??
                                      'https://i.postimg.cc/nLhKkwhH/default-avatar.jpg', // Fallback image
                                ),
                                radius: 50,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                userInfo?['Name'] ?? "No Name Available",
                                // Display Name or fallback
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                userInfo?['UserName'] ?? "No Username Available",
                                // Display Username or fallback
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.grey),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                userInfo?['Email'] ?? "No Email Available",
                                // Display Email or fallback
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(10),
                          padding: const EdgeInsets.all(10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black26),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "About",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                userInfo?['About'] ?? 'No information available',
                                // Display About or fallback
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                logoutUser(context);
                              },
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
                              child: const Text(
                                "Logout",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ));
  }
}
