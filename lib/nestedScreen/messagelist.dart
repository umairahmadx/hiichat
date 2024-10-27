import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:intl/intl.dart';

import '../firebase/firebaseapis.dart'; // For formatting timestamp

class Messagelist extends StatefulWidget {
  final String chatRoomId;
  final Map<String, dynamic> userMap;

  const Messagelist({
    required this.userMap,
    required this.chatRoomId,
    super.key,
  });

  @override
  State<Messagelist> createState() => _MessagelistState();
}

class _MessagelistState extends State<Messagelist> {
  final FirebaseFirestore _firestore = AllAPIs.firestore;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  void _scrollToBottom() {
    // Scroll to the bottom when new messages are loaded
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Detecting keyboard visibility
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('chatroom')
                .doc(widget.chatRoomId)
                .collection('chat')
                .orderBy('time', descending: true) // Get latest messages first
                .snapshots(), // Listening to Firestore updates in real-time
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No messages yet."));
              }

              final messages = snapshot.data!.docs;

              // Scroll to bottom after new messages are added
              WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

              return ListView.builder(
                controller: _scrollController, // Attach the controller
                reverse: true, // Reverse the list
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  bool isMe = message['sendBy'] == widget.userMap['name'];

                  // Get local time from the message data
                  DateTime localTime = (message['time'] as Timestamp).toDate();
                  String formattedTime = DateFormat('h:mm a').format(localTime);

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 10.0),
                    child: Row(
                      mainAxisAlignment: !isMe
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!isMe) // Show time on the left if it's not sent by me
                          Padding(
                            padding: const EdgeInsets.only(right: 1),
                            child: Text(
                              formattedTime,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 7,
                              ),
                            ),
                          ),
                        // Message Bubble
                        BubbleSpecialThree(
                          text: message["message"].toString(),
                          color: !isMe
                              ? const Color(0xFF1B97F3)
                              : const Color(0xFFE8E8EE),
                          isSender: !isMe,
                          tail: false,
                          textStyle: TextStyle(
                            color: !isMe ? Colors.white : Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        if (isMe) // Show time on the right if it's sent by me
                          Padding(
                            padding: const EdgeInsets.only(right: 1),
                            child: Text(
                              formattedTime,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 7,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        SizedBox(height: bottomInset), // Adding space for the keyboard
      ],
    );
  }
}
