import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../firebase/firebaseapis.dart';
import 'messagelist.dart';

class MessageScreen extends StatefulWidget {
  final String chatRoomId;
  final Map<String, dynamic> userMap;

  const MessageScreen(
      {required this.userMap, required this.chatRoomId, super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final FirebaseFirestore _firestore = AllAPIs.firestore;

  final FirebaseAuth _auth = AllAPIs.auth;

  final TextEditingController _controller = TextEditingController();

  void onSendText(String message, BuildContext context) async {
    _controller.clear();
    if (message.isEmpty) {
      return;
    }

    try {
      Map<String, dynamic> messages = {
        "sendBy": _auth.currentUser?.displayName ?? "No Name",
        "message": message,
        "time": Timestamp.now(), // Send formatted time as a string
      };

      await _firestore
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chat')
          .add(messages);
      _firestore
          .collection('user')
          .doc(_auth.currentUser?.uid)
          .collection('chatRoomIds')
          .doc('Rooms')
          .update({
        widget.userMap['uid'].toString(): widget.chatRoomId
      }).catchError((error) async {
        // If the document does not exist, use set to create it
        await _firestore
            .collection('user')
            .doc(_auth.currentUser?.uid)
            .collection('chatRoomIds')
            .doc('Rooms')
            .set({widget.userMap['uid'].toString(): widget.chatRoomId});
      });

      _firestore
          .collection('user')
          .doc(widget.userMap['uid'].toString())
          .collection('chatRoomIds')
          .doc('Rooms')
          .update({
        _auth.currentUser?.uid ?? "secret": widget.chatRoomId
      }).catchError((error) async {
        // If the document does not exist, use set to create it
        await _firestore
            .collection('user')
            .doc(widget.userMap['uid'].toString())
            .collection('chatRoomIds')
            .doc('Rooms')
            .set({_auth.currentUser?.uid ?? "secret": widget.chatRoomId});
      });
      // Clear the input field after sending
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to send message')));
      }
    }
  }

  // Function to send audio messages
  void onSendAudio(String audioFilePath, Duration duration) {
    // Not Implemented it Yet
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back), // Back button icon
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Navigate back to the previous screen
              },
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              backgroundImage: NetworkImage(
                widget.userMap['profilePic'] ??
                    'https://pbs.twimg.com/profile_images/1419974913260232732/Cy_CUavB.jpg', // Fallback image
              ),
            ),
            Expanded(
              child: ListTile(
                dense: true,
                title: Text(
                  widget.userMap['name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  widget.userMap['username'],
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        centerTitle: false, // Align title to the left
      ),
      body: Column(
        children: [
          Expanded(
              child: Messagelist(
                  chatRoomId: widget.chatRoomId, userMap: widget.userMap)),
          Row(
            children: [

              const SizedBox(width: 5,),
              Expanded(
                child: InputWidget(
                  controller: _controller,
                  onSendText: (message) => onSendText(message, context),
                  onSendAudio: onSendAudio,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5,)
        ],
      ),
    );
  }
}

class InputWidget extends StatefulWidget {
  final Function(String) onSendText;
  final Function(String, Duration) onSendAudio;
  final TextEditingController controller;

  const InputWidget({
    required this.onSendText,
    required this.onSendAudio,
    required this.controller,
    super.key,
  });

  @override
  InputWidgetState createState() => InputWidgetState();
}

class InputWidgetState extends State<InputWidget> {
  bool _isRecording = false; // Placeholder for audio recording state

  // Function to handle sending text
  void _handleSendText() {
    if (widget.controller.text.isNotEmpty) {
      widget.onSendText(widget.controller.text);
      widget.controller.clear(); // Clear the text field after sending
    }
  }

  // Function to toggle audio recording Not implemented yet
  void _handleAudioRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });

    if (_isRecording) {
      // Placeholder for actual audio recording logic
      widget.onSendAudio(
          "audioFilePath", const Duration(seconds: 5)); // Sample data
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey), // Static border
                borderRadius: BorderRadius.circular(8.0),
              ),
              constraints: const BoxConstraints(
                maxHeight: 100, // Maximum height for the text field
              ),
              child: SingleChildScrollView(
                child: TextField(
                  controller: widget.controller,
                  maxLines: null, // Allow multiple lines
                  decoration: const InputDecoration(
                    hintText: "Type a message",
                    border: InputBorder.none, // Remove inner border
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  onSubmitted: (value) {
                    _handleSendText();
                  },
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              _isRecording ? Icons.mic : Icons.mic_none,
              color: _isRecording ? Colors.red : Colors.grey,
            ),
            onPressed: _handleAudioRecording,
          ),
          IconButton(
            icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
            onPressed: _handleSendText,
          ),
        ],
      ),
    );
  }
}
