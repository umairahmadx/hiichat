import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hiichat/firebase/firebaseapis.dart';

class AuthService {
  final FirebaseFirestore _firestore = AllAPIs.firestore;
  final FirebaseAuth _auth = AllAPIs.auth;

  // Sign up a new user
  Future<String> signUpUser({
    required String email,
    required String password,
    required String name,
    required String username,
  }) async {
    String result = "Some error occurred";
    try {
      // Create the user with email and password
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update the display name in FirebaseAuth
      await credential.user!.updateDisplayName(name);

      // Store user details in Firestore
      await _firestore.collection("user").doc(credential.user!.uid).set({
        'name': name,
        'email': email,
        'username': username,
        'uid': credential.user!.uid,
        'emailVerified': credential.user!.emailVerified,
      });

      result = 'success';

    } catch (e) {
      result = e.toString(); // Return the error message
    }
    return result;
  }

  // Log in an existing user
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String result = "Some error occurred";
    try {
      // Sign in the user
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // if(!_auth.currentUser!.emailVerified){
      //   Navigator.of(context).
      // }
      result = "success";

      // Fetch user data from Firestore if needed
      await _firestore
          .collection('user')
          .where("email", isEqualTo: email)
          .get()
          .then((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          var userData = snapshot.docs[0].data();
          credential.user!.updateDisplayName(
              userData['name']); // Set the display name correctly
        }
      });

    } catch (e) {
      result = e.toString(); // Return the error message
    }
    return result;
  }

  // Sign out the current user
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
