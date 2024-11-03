import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hiichat/firebase/firebaseapis.dart';
import 'package:hiichat/models/chatuser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
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
  late ChatUser user;
  bool isLoading = true; // To handle the loading state
  final FirebaseFirestore _firestore = AllAPIs.firestore;
  bool imageLoading = false;

  @override
  void initState() {
    super.initState();
    displayUserInfo(); // Fetch user data when the screen initializes
  }

  Future<void> onProfileRemove() async {
    final ref = FirebaseStorage.instance
        .ref()
        .child("images/${AllAPIs.auth.currentUser?.uid}");
    try {
      // Delete the image from Firebase Storage
      await ref.delete();
      // Remove the image URL from Firestore
      await _firestore
          .collection('users')
          .doc(AllAPIs.auth.currentUser?.uid)
          .update({
        'profilePic': FieldValue.delete(),
      });
      setState(() {
        displayUserInfo();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile Pic Removed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove profile: $e')),
        );
      }
    }
  }

  Future<void> onProfileUpload() async {
    XFile? img2;

    // Pick image based on platform
    final ImagePicker picker = ImagePicker();
    img2 =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 60);

    if (img2 != null) {
      setState(() {
        imageLoading = true;
      });
      try {
        final bytes = await img2.readAsBytes();
        img.Image? image = img.decodeImage(bytes);
        if (image != null) {
          final List<int> jpeg = img.encodeJpg(image, quality: 60);
          final Uint8List compressedImageData = Uint8List.fromList(jpeg);
          final ref = FirebaseStorage.instance
              .ref()
              .child("images/${AllAPIs.auth.currentUser?.uid}");
          uploadTask = ref.putData(compressedImageData);

          // Listen for upload progress
          uploadTask!.snapshotEvents.listen((TaskSnapshot snapshot) {
            setState(() {
              imageLoading =
                  true; // Optional: keep loading state true until upload completes
            });
          });

          final snapshot = await uploadTask!.whenComplete(() => null);
          final downloadUrl = await snapshot.ref.getDownloadURL();

          await _firestore
              .collection('users')
              .doc(AllAPIs.auth.currentUser?.uid)
              .update({
            'profilePic': downloadUrl,
          });
          if(mounted){
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Profile Uploaded')));
          }
        } else {
          throw Exception('Failed to decode image');
        }
      } catch (e) {
        if(mounted){
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Upload failed: $e')));
        }
      } finally {
        setState(() {
          image = null;
          uploadTask = null;
          imageLoading = false; // Set to false after upload completes
          displayUserInfo();
        });
      }
    }
  }

  void displayUserInfo() async {
    try {
      String? email = "user_email@example.com";
      email = AllAPIs.auth.currentUser?.email;
      await _firestore
          .collection('users')
          .where("email", isEqualTo: email)
          .get()
          .then((snapshot) async {
        if (snapshot.docs.isNotEmpty) {
          setState(() {
            user = ChatUser.fromJson(snapshot.docs[0].data());
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

  onProfileClicked() async {
    int? confirm = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            titlePadding: const EdgeInsets.all(0),
            actionsPadding: const EdgeInsets.all(0),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            actions: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    style: const ButtonStyle(
                        shape: WidgetStatePropertyAll(LinearBorder())),
                    onPressed: () => Navigator.of(context).pop(0),
                    child: const SizedBox(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(Icons.image_rounded),
                          Text("Upload Profile Pic"),
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                    visible: user.profilePic.isNotEmpty,
                    child: TextButton(
                      style: const ButtonStyle(
                          shape: WidgetStatePropertyAll(LinearBorder())),
                      onPressed: () => Navigator.of(context).pop(1),
                      child: const SizedBox(
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(Icons.hide_image),
                            Text("Remove Profile Pic"),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        });
    if (confirm == 0) {
      onProfileUpload();
    } else if (confirm == 1) {
      onProfileRemove();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
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
                          onTap: onProfileClicked,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircleAvatar(
                                backgroundImage: image == null
                                    ? (user.profilePic.isEmpty
                                        ? AllAPIs.defaultImage
                                        : CachedNetworkImageProvider(user
                                            .profilePic))
                                    : FileImage(File(image!.path)),
                                // Use FileImage for selected image
                                radius: 50,
                              ),
                              StreamBuilder(
                                stream: uploadTask?.snapshotEvents,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    final data = snapshot.data!;
                                    double progress =
                                        data.bytesTransferred / data.totalBytes;
                                    return Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SizedBox(
                                          width: 110,
                                          height: 110,
                                          child: CircularProgressIndicator(
                                            value: progress,
                                            color: imageLoading
                                                ? Colors.blue
                                                : Colors.transparent,
                                            backgroundColor: imageLoading
                                                ? Colors.grey
                                                : Colors.transparent,
                                            strokeWidth: 5,
                                          ),
                                        ),
                                      ],
                                    );
                                  } else {
                                    return const SizedBox(
                                      width: 110,
                                      height: 110,
                                    ); // No progress to display
                                  }
                                },
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          user.name.isNotEmpty
                              ? user.name
                              : "No Name Available",
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          user.username.isNotEmpty
                              ? user.username
                              : "No Username Available",
                          style:
                              const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          user.email.isNotEmpty
                              ? user.email
                              : "No Email Available",
                          style:
                              const TextStyle(fontSize: 16, color: Colors.grey),
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
                          user.about.isNotEmpty
                              ? user.about
                              : 'No information available',
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
            ),
    );
  }
}
