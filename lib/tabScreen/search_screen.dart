import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../firebase/firebaseapis.dart';
import '../models/chatuser.dart';
import '../nestedScreen/chatusercard.dart';

class SearchScreen extends StatefulWidget {
  final FocusNode focusNode;

  const SearchScreen({required this.focusNode, super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final FirebaseAuth _auth = AllAPIs.auth;
  final TextEditingController searchText = TextEditingController();
  List<ChatUser> userList = []; // Updated to ChatUser type
  bool isLoading = false;
  bool suggested = true;
  bool _isMounted = true;

  @override
  void initState() {
    super.initState();
    fetchInitialUsers(); // Fetch users on screen load
  }

  @override
  void dispose() {
    _isMounted = false; // Set to false when widget is disposed
    super.dispose();
  }

  void fetchInitialUsers() async {
    if(_isMounted) {
      setState(() {
      isLoading = true;
      suggested = true;
    });
    }

    try {
      FirebaseFirestore firestore = AllAPIs.firestore;
      QuerySnapshot snapshot =
          await firestore.collection('users').limit(3).get();

      // Convert each document to a ChatUser instance
      List<ChatUser> tempList = snapshot.docs
          .map((e) => ChatUser.fromJson(e.data() as Map<String, dynamic>))
          .where((user) => user.uid != _auth.currentUser!.uid)
          .toList();

      if(_isMounted) {
        setState(() {
        userList = tempList;
      });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error occurred: $e")),
        );
      }
    } finally {
      if(_isMounted){
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void onSearch(String query) async {
    if (query.isEmpty) {
      fetchInitialUsers();
      return;
    }

    setState(() {
      isLoading = true;
      suggested = false;
    });

    try {
      FirebaseFirestore firestore = AllAPIs.firestore;
      QuerySnapshot snapshot = await firestore.collection('users').get();

      // Filter and convert to ChatUser instances based on the search query
      List<ChatUser> tempList = snapshot.docs
          .map((doc) => ChatUser.fromJson(doc.data() as Map<String, dynamic>))
          .where((user) {
        String name = user.name.toLowerCase();
        String username = user.username.toLowerCase();
        String searchQuery = query.toLowerCase();
        return (name.contains(searchQuery) || username.contains(searchQuery)) &&
            user.uid != _auth.currentUser!.uid;
      }).toList();

      tempList.sort((a, b) {
        String searchQuery = query.toLowerCase();
        int positionA = a.name.toLowerCase().indexOf(searchQuery);
        if (positionA == -1) {
          positionA = a.username.toLowerCase().indexOf(searchQuery);
        }
        int positionB = b.name.toLowerCase().indexOf(searchQuery);
        if (positionB == -1) {
          positionB = b.username.toLowerCase().indexOf(searchQuery);
        }
        return positionA.compareTo(positionB);
      });

      setState(() {
        userList = tempList;
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
          margin: const EdgeInsets.symmetric(horizontal: 10),

          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            textAlignVertical: TextAlignVertical.center,
            controller: searchText,
            focusNode: widget.focusNode,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: "Search User",
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              suffixIcon: isLoading
                  ? Container(
                      padding: const EdgeInsets.all(15),
                      height: 40,
                      width: 40,
                      child: const CircularProgressIndicator(),
                    )
                  : IconButton(
                      onPressed: () => onSearch(searchText.text),
                      icon: const Icon(Icons.search_rounded),
                    ),
            ),
            onChanged: onSearch,
            onSubmitted: onSearch,
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              suggested ? "Suggestions" : "Result",
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.start,
            ),
          ),
        ),
        Expanded(
          child: userList.isNotEmpty
              ? ListView.builder(
                  itemCount: userList.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return ChatUserCard(
                      user: userList[index],
                      isSearchScreen: true,
                    );
                  },
                )
              : Center(
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text("No results found"),
                ),
        ),
      ],
    );
  }
}
