import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import '../nestedScreen/login/services/logout_function.dart';
import '../tabScreen/chatlist.dart';
import '../tabScreen/profile_screen.dart';
import '../tabScreen/search_screen.dart';

class MobileHome extends StatefulWidget {
  const MobileHome({super.key});

  @override
  State<MobileHome> createState() => _MobileHomeState();
}

class _MobileHomeState extends State<MobileHome> {
  int currentIndex = 0; // Moved currentIndex to the state

  final List<Widget> _widgets = [
    const ChatListScreen(),
    const SearchScreen(),
    const ProfileScreen(),
  ];
  final List<String> screenName = ["Chat", "Search", "Profile"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(screenName[currentIndex]),
        centerTitle: true,
        actions: [
          Visibility(
            visible: currentIndex != 1,
            child: IconButton(
              onPressed: () async {
                logoutUser(context);
              },
              icon: const Icon(Icons.logout_rounded),
            ),
          )
        ],
      ),
      body: _widgets[currentIndex],
      bottomNavigationBar: SizedBox(
        height: 60,
        child: SalomonBottomBar(
          currentIndex: currentIndex,
          onTap: (i) => setState(() => currentIndex = i),
          // Update the index on tap
          items: [
            SalomonBottomBarItem(
              icon: const Icon(Icons.home),
              title: const Text("Home"),
              selectedColor: const Color(0xFF0D47A1),
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.search),
              title: const Text("Search"),
              selectedColor: const Color(0xFF0D47A1),
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.person_rounded),
              title: const Text("Profile"),
              selectedColor: const Color(0xFF0D47A1),
            ),
          ],
        ),
      ),
    );
  }
}
