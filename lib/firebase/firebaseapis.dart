import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:hiichat/models/chatuser.dart';
import 'package:hiichat/models/message.dart';

class AllAPIs {
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyChatRoomsId() {
    var users = firestore
        .collection("users")
        .doc(auth.currentUser?.uid)
        .collection("my_chatroom")
        .snapshots();
    return users;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUsers(
      List<String> userIds) {
    return firestore
        .collection("users")
        .where("uid", whereIn: userIds)
        .snapshots();
  }
  static const NetworkImage defaultImage= NetworkImage(
    'https://i.postimg.cc/nLhKkwhH/default-avatar.jpg',
  );
  //get all messages
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection("chat/${getConversationID(user.uid)}/messages")
        .snapshots();
  }

  static String getConversationID(String uid) {
    String currentUserID = auth.currentUser!.uid;
    return currentUserID.compareTo(uid) <= 0
        ? '${currentUserID}_$uid'
        : '${uid}_$currentUserID';
  }

  static Future<bool> deleteChatRoom(String chatRoomId) async {
    try {
      await firestore
          .collection('users')
          .doc(auth.currentUser?.uid)
          .collection("my_chatroom")
          .doc(chatRoomId)
          .delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> sendMessage(ChatUser chatUser, String msg) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final Message message = Message(
        fromid: auth.currentUser!.uid,
        msg: msg,
        read: "",
        sent: time,
        told: chatUser.uid,
        type: Type.text);
    final ref = firestore
        .collection("chat/${getConversationID(chatUser.uid)}/messages");
    await ref.doc(time).set(message.toJson());
  }

  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection("chat/${getConversationID(message.fromid)}/messages")
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessages(
      ChatUser user) {
    return firestore
        .collection("chat/${getConversationID(user.uid)}/messages")
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  static Future<void> addChatRoom(String userUID1, String userUID2) async {
    firestore
        .collection("users")
        .doc(userUID1)
        .collection("my_chatroom")
        .doc(userUID2)
        .set({});
  }

  static FirebaseAuth auth = FirebaseAuth.instance..setLanguageCode('en');
}
