import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hiichat/firebase/firebaseapis.dart';
import 'package:image_picker/image_picker.dart';

import '../firebase/authentication.dart';
import '../nestedScreen/login/services/logout_function.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  XFile? image;
  UploadTask? uploadTask;
  Map<String, dynamic>? userInfo;
  bool isLoading = true; // To handle the loading state
  final FirebaseFirestore _firestore = AllAPIs.firestore;
  bool imageLoading = false;

  @override
  void initState() {
    super.initState();
    displayUserInfo(); // Fetch user data when the screen initializes
  }

  Future<void> onProfileTapped() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (img != null) {
      setState(() {
        imageLoading = true;
      });
      image = img;
      final ref = FirebaseStorage.instance
          .ref()
          .child("images/${AllAPIs.auth.currentUser?.uid}");
      uploadTask = ref.putFile(File(image!.path));
      final snapshot = await uploadTask!.whenComplete(() => null);

      final downloadUrl = await snapshot.ref.getDownloadURL();
      await _firestore
          .collection("user")
          .doc(AllAPIs.auth.currentUser?.uid)
          .update({
        'profilePic': downloadUrl,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile Uploaded')),
        );
      }
      setState(() {
        uploadTask = null;
        imageLoading = false;
      });
    }
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
              'Profile': userData['profilePic'],
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
                    child: Text(
                        'No user data found')) // Fallback for null userInfo
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
                              GestureDetector(
                                onTap: () async {
                                  bool? confirm = await showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          titlePadding: const EdgeInsets.all(0),
                                          actionsPadding:
                                              const EdgeInsets.all(0),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          actions: [
                                            SizedBox(
                                              height: 60,
                                              child: TextButton(
                                                style: ButtonStyle(
                                                    shape: WidgetStatePropertyAll(
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)))),
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(true),
                                                child: const Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    Icon(Icons.image_rounded),
                                                    Text("Upload Profile Pic"),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      });
                                  if (confirm == true) onProfileTapped();
                                },
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: image == null
                                          ? (userInfo?['Profile'] == null
                                              ? AllAPIs.defaultImage
                                              : NetworkImage(
                                                  userInfo?['Profile']))
                                          : FileImage(File(image!.path)),
                                      radius: 50,
                                    ),
                                    StreamBuilder(
                                      stream: uploadTask?.snapshotEvents,
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          final data = snapshot.data!;
                                          double progress =
                                              data.bytesTransferred /
                                                  data.totalBytes;
                                          return Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              // SizedBox to control the size of the CircleAvatar
                                              SizedBox(
                                                width: 110,
                                                // Twice the radius (50 * 2) to ensure it takes the full circle
                                                height: 110,
                                                // Same here
                                                child:
                                                    CircularProgressIndicator(
                                                  value: progress,
                                                  // Progress value (0.0 to 1.0)
                                                  color: imageLoading
                                                      ? Colors.blue
                                                      : Colors.transparent,
                                                  backgroundColor: imageLoading
                                                      ? Colors.grey
                                                      : Colors.transparent,
                                                  strokeWidth:
                                                      5, // Adjust thickness as needed
                                                ),
                                              ),
                                            ],
                                          );
                                        } else {
                                          return const SizedBox(
                                            width: 110,
                                            // Twice the radius (50 * 2) to ensure it takes the full circle
                                            height: 110,
                                            // Same here
                                            child: CircularProgressIndicator(
                                              // Progress value (0.0 to 1.0)
                                              color: Colors.transparent,
                                              backgroundColor:
                                                  Colors.transparent,
                                              strokeWidth:
                                                  5, // Adjust thickness as needed
                                            ),
                                          ); // No progress to display
                                        }
                                      },
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                userInfo?['Name'] ?? "No Name Available",
                                // Display Name or fallback
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                userInfo?['UserName'] ??
                                    "No Username Available",
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
                                userInfo?['About'] ??
                                    'No information available',
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
