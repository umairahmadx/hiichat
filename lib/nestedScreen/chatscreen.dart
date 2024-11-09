import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hiichat/models/chatuser.dart';
import 'package:hiichat/models/message.dart';
import 'package:hiichat/nestedScreen/messagecard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase/firebaseapis.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;

  const ChatScreen({required this.user, super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late List<Message> _list;
  final _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool exist = false;
  bool isEmoji = false;
  bool imageError = false;

  void checkUserInChatRoom(String userId1, String userId2) {
    final document = AllAPIs.firestore
        .collection("users")
        .doc(userId1)
        .collection("my_chatroom")
        .doc(userId2);
    document.get().then((DocumentSnapshot documentSnapshot) {
      if (!documentSnapshot.exists) {
        try {
          AllAPIs.addChatRoom(userId1, userId2);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to create chatroom: $e')),
            );
          }
        }
      }
    });
  }

  void sendMessage() {
    // Trim trailing spaces and newlines from the text
    final messageText = _textController.text.replaceAll(RegExp(r'\s+$'), '');

    // Check if the trimmed message is empty
    if (messageText.isEmpty) {
      return;
    }
    AllAPIs.sendMessage(widget.user, messageText);
    _textController.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
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
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: StreamBuilder(
          stream: AllAPIs.getUserInfo(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
            return Row(
              children: [
                CircleAvatar(
                    backgroundImage: list.isEmpty
                        ? AllAPIs.defaultImage
                        : (list[0].profilePic.isEmpty
                            ? AllAPIs.defaultImage
                            : CachedNetworkImageProvider(list[0].profilePic))),
                Expanded(
                  child: ListTile(
                    dense: true,
                    title: Text(
                      list.isEmpty
                          ? 'HiiChat User'
                          : list[0].name.isNotEmpty
                              ? list[0].name
                              : 'HiiChat User',
                      style: const TextStyle(fontSize: 15),
                    ),
                    subtitle: Text(
                      list.isEmpty
                          ? 'Offline'
                          : list[0].isOnline
                              ? "Online"
                              : "Offline",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        backgroundColor: Colors.white,
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: AllAPIs.getAllMessages(widget.user),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return const SizedBox();
                  case ConnectionState.active:
                  case ConnectionState.done:
                    final data = snapshot.data?.docs;
                    _list = (data
                                ?.map((e) => Message.fromJson(e.data()))
                                .toList() ??
                            [])
                        .toList();

                    if (_list.isNotEmpty) {
                      return ListView.builder(
                        controller: _scrollController, // Attach the controller
                        reverse: true, // Reverse the list
                        itemCount: _list.length,
                        itemBuilder: (context, index) {
                          return MessageCard(
                            message: _list[index],
                            previousId: index == _list.length - 1
                                ? ""
                                : _list[index + 1].fromid,
                          );
                        },
                      );
                    } else {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "No Chats Found",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                textAlign: TextAlign.center,
                                "Start things off with a quick Hiii!! and start chatting!",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                }
              },
            ),
          ),
          Container(
            color: Colors.transparent,
            padding:
                const EdgeInsets.only(top: 3, bottom: 10, left: 10, right: 10),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    margin: const EdgeInsets.only(right: 10),
                    color: Colors.grey[200],
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            constraints: const BoxConstraints(
                              maxHeight:
                                  100, // Maximum height for the text field
                            ),
                            child: SingleChildScrollView(
                              child: TextField(
                                controller: _textController,
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                // Allow multiple lines
                                decoration: const InputDecoration(
                                  hintText: "Message",
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: InputBorder.none,
                                  // Remove inner border
                                  contentPadding:
                                      EdgeInsets.only(left: 15, right: 10),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.attach_file_rounded))
                      ],
                    ),
                  ),
                ),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    color: Colors.white,
                    onPressed: () {
                      if (_list.isEmpty || !exist) {
                        checkUserInChatRoom(
                            AllAPIs.auth.currentUser!.uid, widget.user.uid);
                        checkUserInChatRoom(
                            widget.user.uid, AllAPIs.auth.currentUser!.uid);
                        exist = true;
                      }
                      sendMessage();
                    },
                    icon: const Icon(
                      Icons.send_rounded,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
