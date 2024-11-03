import 'package:flutter/material.dart';
import 'package:hiichat/models/chatuser.dart';
import 'package:hiichat/nestedScreen/chatusercard.dart';
import '../firebase/firebaseapis.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreen();
}

class _ChatListScreen extends State<ChatListScreen> {
  List<ChatUser> list = [];

  Widget noChatsFound() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_rounded,
            size: 64.0,
            color: Colors.grey,
          ),
          SizedBox(height: 10.0),
          Text(
            "No Chats Found",
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.black, // Use a contrasting color
            ),
          ), // Space between text and subtitle
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              "Head over to the Search Tab to start a new chat!",
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey, // Softer color for the subtitle
              ),
              textAlign: TextAlign.center, // Center-align the subtitle
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: AllAPIs.getMyChatRoomsId(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final userIds = snapshot.data?.docs.map((e) => e.id).toList() ?? [];
            if (userIds.isEmpty) {
              return noChatsFound();
            }
            return StreamBuilder(
              stream: AllAPIs.getUsers(userIds),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return const Center(child: CircularProgressIndicator());
                  case ConnectionState.active:
                  case ConnectionState.done:
                    if (snapshot.hasData) {
                      final data = snapshot.data?.docs;
                      list = data
                              ?.map((e) => ChatUser.fromJson(e.data()))
                              .toList() ??
                          [];
                    }
                    if (list.isNotEmpty) {
                      return ListView.builder(
                        itemCount: list.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return ChatUserCard(user: list[index]);
                        },
                      );
                    } else {
                      return noChatsFound();
                    }
                }
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 3,
        backgroundColor: Colors.blue,
        onPressed: () {},
        child: const Icon(
          Icons.add_comment_rounded,
          color: Colors.white,
        ),
      ),
    );
  }
}
