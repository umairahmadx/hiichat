import 'package:flutter/material.dart';
import 'package:hiichat/firebase/firebaseapis.dart';
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

class _MobileHomeState extends State<MobileHome> with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        setState(() {
          AllAPIs.updateUserStatus(true);
        });
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        setState(() {
          AllAPIs.updateUserStatus(false);
        });
        break;
    }
  }

  int currentIndex = 0; // Moved currentIndex to the state
  final FocusNode searchFocusNode = FocusNode();

  void changeTab() {
    setState(() => currentIndex = 1);
    Future.delayed(Duration.zero, () {
      searchFocusNode.requestFocus();
    });
  }

  late final List<Widget> _widgets;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    AllAPIs.getFirebaseMessagingToken();
    _widgets = [
      ChatListScreen(searchTab: changeTab),
      SearchScreen(focusNode: searchFocusNode),
      const ProfileScreen(),
    ];
  }

  @override
  void dispose() {
    super.dispose();
    searchFocusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

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
