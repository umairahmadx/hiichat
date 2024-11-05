import 'package:flutter/material.dart';
import 'package:hiichat/models/chatuser.dart';
import 'package:hiichat/nestedScreen/chatusercard.dart';
import '../firebase/firebaseapis.dart';

class ChatListScreen extends StatefulWidget {
  final Function searchTab;

  const ChatListScreen({super.key, required this.searchTab});

  @override
  State<ChatListScreen> createState() => _ChatListScreen();
}

class _ChatListScreen extends State<ChatListScreen>
    with AutomaticKeepAliveClientMixin {
  List<ChatUser> list = []; // This will hold the last messages and UIDs

  @override
  bool get wantKeepAlive => true;

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
              color: Colors.black,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              "Head over to the Search Tab to start a new chat!",
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, String>>> fetchAndUpdateUserList(List<String> uids) async {
    try {
      // Fetch last messages for all user IDs
      Map<String, String> lastMessages = {};
      await Future.wait(
        uids.map((uid) async {
          lastMessages[uid] = await AllAPIs.getLastMessageTime(uid); // Default to '0' if null
        }),
      );

      // Prepare updated user list based on the fetched last messages
      List<Map<String, String>> updatedUserList = [];
      for (var uid in uids) {
        updatedUserList.add({
          'uid': uid,
          'lastmessage': lastMessages[uid] ?? '0' // Ensure it's a string
        });
      }

      // Sort the userList by last message timestamp
      updatedUserList.sort((a, b) {
        int timeA = int.tryParse(a['lastmessage'] ?? '0') ?? 0;
        int timeB = int.tryParse(b['lastmessage'] ?? '0') ?? 0;
        return timeB.compareTo(timeA); // Sort in descending order
      });

      return updatedUserList; // Return updated user list
    } catch (e) {
      return []; // Return an empty list on error
    }
  }


  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Scaffold(
      body: StreamBuilder(
        stream: AllAPIs.getMyChatRoomsId(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userIds = snapshot.data?.docs.map((e) => e.id).toList() ?? [];
          if (userIds.isEmpty) {
            return noChatsFound();
          }

          return FutureBuilder<List<Map<String, String>>>(
            future: fetchAndUpdateUserList(userIds),
            builder: (context, lastMessagesSnapshot) {
              if (lastMessagesSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // Use the updated user list from the future
              final updatedUserList = lastMessagesSnapshot.data ?? [];
              AllAPIs.userList = updatedUserList; // Assign to your API list

              return StreamBuilder(
                stream: AllAPIs.getUsers(userIds),
                builder: (context, usersSnapshot) {
                  if (!usersSnapshot.hasData || usersSnapshot.data?.docs.isEmpty == true) {
                    return const Center(child: CircularProgressIndicator(),);
                  }

                  final users = usersSnapshot.data!.docs
                      .map((e) => ChatUser.fromJson(e.data()))
                      .toList();

                  return ListView.builder(
                    itemCount: AllAPIs.userList.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final userMap = AllAPIs.userList[index];
                      // Find the corresponding ChatUser object based on uid
                      final chatUser = users.firstWhere((user) => user.uid == userMap['uid']);
                      return ChatUserCard(
                        user: chatUser,
                        updateList: () => setState(() {}), // Pass a function reference here
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 3,
        backgroundColor: Colors.blue,
        onPressed: () => widget.searchTab(),
        child: const Icon(
          Icons.add_comment_rounded,
          color: Colors.white,
        ),
      ),
    );
  }
}
