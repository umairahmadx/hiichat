import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:hiichat/models/chatuser.dart';
import 'package:hiichat/models/message.dart';

class AllAPIs {
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyChatRoomsId() {
    return firestore
        .collection("users/${auth.currentUser?.uid}/my_chatroom")
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUsers(
      List<String> userIds) {
    return firestore
        .collection("users")
        .where("uid", whereIn: userIds)
        .snapshots();
  }

  static const NetworkImage defaultImage = NetworkImage(
    'https://i.postimg.cc/nLhKkwhH/default-avatar.jpg',
  );

  //get all messages
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection("chat/${getConversationID(user.uid)}/messages")
        .orderBy("serverTime", descending: true)
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
    final time = DateTime
        .now()
        .millisecondsSinceEpoch
        .toString();

    final Message message = Message(
      fromid: auth.currentUser!.uid,
      msg: msg,
      read: null,
      sent: time,
      told: chatUser.uid,
      type: Type.text,
      serverTime: Timestamp.now(),
      status: Status.wait,
    );
    final ref = firestore
        .collection("chat/${getConversationID(chatUser.uid)}/messages");
    await ref.doc(time).set(message.toJson()).then((_) {
      ref.doc(time).update({
        'serverTime': FieldValue.serverTimestamp(),
        'status': Status.unread.name
      });
    });
    await updateLastMessage(auth.currentUser!.uid, chatUser.uid);
    await updateLastMessage(chatUser.uid, auth.currentUser!.uid);
  }

    static Future<void> updateLastMessage(String uid1, String uid2) async {
      final lastMessage = firestore.collection("users/$uid1/my_chatroom");
      await lastMessage
          .doc(uid2)
          .update({"lastMessageTime": FieldValue.serverTimestamp()});
    }


    static Future<bool> updateMessageReadStatus(Message message) async {
    firestore
        .collection("chat/${getConversationID(message.fromid)}/messages")
        .doc(message.sent)
        .update(
            {'read': FieldValue.serverTimestamp(), 'status': Status.read.name});
    return true;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessages(
      ChatUser user) {
    return firestore
        .collection("chat/${getConversationID(user.uid)}/messages")
        .orderBy('serverTime', descending: true)
        .limit(1)
        .snapshots();
  }

  static Future<String> getLastMessageTime(String uid) async {
    final snapshot = await firestore
        .collection("chat/${getConversationID(uid)}/messages")
        .orderBy('serverTime', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      Message message = Message.fromJson(snapshot.docs.first.data());
      return message.sent; // Return the sent timestamp
    }
    return ""; // Return an empty string if no messages
  }

  static Future<void> addChatRoom(String userUID1, String userUID2) async {
    firestore
        .collection("users")
        .doc(userUID1)
        .collection("my_chatroom")
        .doc(userUID2)
        .set({"lastMessageTime": FieldValue.serverTimestamp().toString()});
  }

  // static List<Map<String, String>> userList = [];
  static FirebaseAuth auth = FirebaseAuth.instance..setLanguageCode('en');
}
