import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../firebase/firebaseapis.dart';
import '../nestedScreen/contactmessagescreen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final FirebaseAuth _auth = AllAPIs.auth;
  List<Map<String, dynamic>> userList = [];
  TextEditingController searchText = TextEditingController();
  bool isLoading = false;
  bool suggested = true;

  @override
  void initState() {
    super.initState();
    fetchInitialUsers(); // Fetch users on screen load
  }

  // Function to create a unique chat room ID based on UIDs
  String chatRoomId(String user1, String user2) {
    return user1.compareTo(user2) < 0 ? "$user1$user2" : "$user2$user1";
  }

  void fetchInitialUsers() async {
    suggested = true;
    setState(() {
      isLoading = true;
    });

    try {
      FirebaseFirestore firestore = AllAPIs.firestore;
      QuerySnapshot snapshot = await firestore
          .collection("user")
          .limit(3) // Limit the number of users fetched to 3
          .get();

      List<Map<String, dynamic>> tempList = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .where((userData) =>
              userData['uid'] != _auth.currentUser!.uid) // Exclude your own ID
          .toList();

      setState(() {
        userList = tempList.isNotEmpty ? tempList : [];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error occurred: $e")),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to search all users whose username starts with the query
  void onSearch(String query) async {
    if (searchText.text.isEmpty) {
      fetchInitialUsers();
      return;
    }

    suggested = false;
    if (query.isEmpty) {
      setState(() {
        userList = [];
        isLoading = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      FirebaseFirestore firestore = AllAPIs.firestore;
      QuerySnapshot snapshot =
          await firestore.collection("user").get(); // Fetch all users

      List<Map<String, dynamic>> tempList = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .where((userData) {
        String name = userData['name']?.toLowerCase() ?? '';
        String username = userData['username']?.toLowerCase() ?? '';
        String searchQuery = query.toLowerCase();
        return (name.contains(searchQuery) || username.contains(searchQuery)) &&
            userData['uid'] != _auth.currentUser!.uid; // Exclude your own ID
      }).toList();

      setState(() {
        userList = tempList.isNotEmpty ? tempList : [];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error occurred: $e")),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          width: double.infinity,
          child: SearchBar(
            hintText: "Search User",
            elevation: const WidgetStatePropertyAll(0),
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
            trailing: <Widget>[
              isLoading
                  ? Container(
                      margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                      height: 20,
                      width: 20,
                      child: const CircularProgressIndicator(),
                    )
                  : IconButton(
                      onPressed: () => onSearch(searchText.text),
                      icon: const Icon(Icons.search_rounded),
                    )
            ],
            controller: searchText,
            padding: const WidgetStatePropertyAll<EdgeInsets>(
                EdgeInsets.fromLTRB(10, 0, 10, 0)),
            onChanged: (query) {
              onSearch(query); // Perform search immediately when typing
            },
          ),
        ),
        const SizedBox(height: 10),
        Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              suggested ? "Suggestions" : "Result",
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.start,
            )),
        userList.isNotEmpty
            ? Expanded(
                child: ListView.builder(
                  itemCount: userList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        searchText.clear();
                        String currentUserId = _auth.currentUser!.uid;
                        String otherUserUid = userList[index]['uid'].toString();
                        String roomId = chatRoomId(currentUserId, otherUserUid);
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    MessageScreen(
                              userMap: userList[index],
                              chatRoomId: roomId,
                            ),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              const begin =
                                  Offset(1.0, 0.0); // Start from the right
                              const end =
                                  Offset.zero; // End at the current position
                              const curve = Curves.easeInOut;

                              // Define the animation
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

                        fetchInitialUsers();
                      },
                      leading: CircleAvatar(
                        backgroundImage: userList[index]['Profile'] == null
                            ? AllAPIs.defaultImage
                            : NetworkImage(
                            userList[index]['profilePic']
                        ),
                      ),
                      title: Text(userList[index]['name'] ?? 'No Name'),
                      subtitle: Text(
                        userList[index]['username'] ?? 'No Username',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    );
                  },
                ),
              )
            : isLoading
                ? const SizedBox
                    .shrink() // Avoid showing anything while loading
                : const Text("No results found"),
      ],
    );
  }
}
