import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../firebase/firebaseapis.dart';
import '../nestedScreen/contactmessagescreen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreen();
}

class _ChatListScreen extends State<ChatListScreen> {
  final FirebaseAuth _auth = AllAPIs.auth;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> chatRooms = [];
  List<Map<String, dynamic>> userList = [];
  bool isLoading = true; // Start loading true until we fetch data

  @override
  void initState() {
    super.initState();
    fetchChatRooms();
  }

  Future<void> fetchChatRooms() async {
    String? currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('user')
          .doc(currentUserId)
          .collection('chatRoomIds')
          .doc('Rooms')
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

        chatRooms = data.entries.map((entry) {
          String oppositeUserId = entry.key;
          String chatRoomId = entry.value;
          return {
            'chatRoomId': chatRoomId,
            'otherMemberUid': oppositeUserId,
          };
        }).toList();
        await fetchUserList();
      }
    } catch (e) {
      _showErrorSnackbar("Error occurred: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> fetchUserList() async {
    try {
      QuerySnapshot userSnapshot = await _firestore.collection('user').get();
      userList = userSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>; // Cast to Map<String, dynamic>

        return {
          'uid': (data.containsKey('uid') && data['uid'] != null) ? data['uid'] : 'N/A', // Default value if uid is missing or null
          'name': (data.containsKey('name') && data['name'] != null) ? data['name'] : 'HiiChat User', // Default value if name is missing or null
          'email': (data.containsKey('email') && data['email'] != null) ? data['email'] : 'HiiChatUser', // Default value if email is missing or null
          'username': (data.containsKey('username') && data['username'] != null) ? data['username'] : 'Hii Chat User', // Default value if username is missing or null
          'profilePic': (data.containsKey('profilePic') && data['profilePic'] != null)
              ? data['profilePic']
              : 'https://st4.depositphotos.com/14903220/22197/v/600/depositphotos_221970610-stock-illustration-abstract-sign-avatar-icon-profile.jpg', // Default URL if profilePic is missing or null
        };
      }).toList();


    } catch (e) {
      _showErrorSnackbar("Error occurred while fetching users: $e");
    }
  }

  Future<void> deleteChat(String chatRoomId, String otherMemberUid) async {
    try {
      String? currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return;

      await _firestore
          .collection('user')
          .doc(currentUserId)
          .collection('chatRoomIds')
          .doc('Rooms')
          .update({
        otherMemberUid: FieldValue.delete(),
      });

      setState(() {
        chatRooms.removeWhere((room) => room['chatRoomId'] == chatRoomId);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Chat deleted successfully")),
        );
      }
    } catch (e) {
      _showErrorSnackbar("Error occurred while deleting: $e");
    }
  }

  void _showErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : chatRooms.isNotEmpty
              ? ListView.builder(
                  itemCount: chatRooms.length,
                  itemBuilder: (context, index) {
                    String otherMemberUid = chatRooms[index]['otherMemberUid'];
                    var user = userList.firstWhere(
                      (user) => user['uid'] == otherMemberUid,
                      orElse: () => {
                        'name': 'Unknown User',
                        'uid': otherMemberUid,
                      },
                    );
                    return Dismissible(
                      key: Key(chatRooms[index]['chatRoomId']),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.red,
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.endToStart) {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Delete Chat"),
                                content: const Text(
                                    "Are you sure you want to delete this chat?"),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text("Delete"),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                        return false;
                      },
                      onDismissed: (direction) {
                        deleteChat(
                            chatRooms[index]['chatRoomId'], otherMemberUid);
                      },
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            user['profilePic'] ??
                                'https://st4.depositphotos.com/14903220/22197/v/600/depositphotos_221970610-stock-illustration-abstract-sign-avatar-icon-profile.jpg',
                          ),
                          radius: 30,
                        ),
                        title: Text(
                          user['name'] ?? 'HiiChat User',
                          style: const TextStyle(fontSize: 18),
                        ),
                        subtitle: Text(
                          user['username'] ?? 'hiichat user',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      MessageScreen(
                                userMap: user,
                                chatRoomId: chatRooms[index]['chatRoomId'],
                              ),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                const begin = Offset(1.0, 0.0);
                                const end = Offset.zero;
                                const curve = Curves.easeInOut;

                                var tween = Tween(begin: begin, end: end)
                                    .chain(CurveTween(curve: curve));
                                var offsetAnimation = animation.drive(tween);

                                return SlideTransition(
                                  position: offsetAnimation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    );
                  },
                )
              : const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chat_rounded,
                        size: 64.0,
                        color: Colors.grey,
                      ),
                      SizedBox(
                          height: 10.0),
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
                            color:
                                Colors.grey, // Softer color for the subtitle
                          ),
                          textAlign:
                              TextAlign.center, // Center-align the subtitle
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
