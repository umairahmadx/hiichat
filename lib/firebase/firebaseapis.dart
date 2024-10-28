import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AllAPIs {
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static const NetworkImage defaultImage= NetworkImage(
  'https://i.postimg.cc/nLhKkwhH/default-avatar.jpg',
  );
  static FirebaseAuth auth = FirebaseAuth.instance..setLanguageCode('en');
}
