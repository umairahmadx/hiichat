import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hiichat/firebase/firebaseapis.dart';
import 'package:hiichat/models/message.dart';
import '../models/chatuser.dart';
import 'chatscreen.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  final bool isSearchScreen;
  final Function updateList;

  const ChatUserCard({
    required this.user,
    this.isSearchScreen = false,
    super.key,
    required this.updateList,          // Default value for updateList
  });

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? _message;
  bool imageError = false;
  void addOrUpdateUser(Map<String, dynamic> user) {
    final String uid = user['uid']?.toString() ?? '';
    final String lastMessage = user['lastmessage']?.toString() ?? '0'; // Default to '0' if null

    // Create a formatted user map with the correct types
    Map<String, String> formattedUser = {
      'uid': uid,
      'lastmessage': lastMessage,
      // Add other fields you need, ensuring they're strings
    };

    int index = AllAPIs.userList.indexWhere((existingUser) => existingUser['uid'] == formattedUser['uid']);

    if (index != -1) {
      // If the uid exists, check if the new user data is different
      Map<String, String> existingUser = AllAPIs.userList[index];

      // Only update if there is a change
      bool shouldUpdate = false;

      for (var key in formattedUser.keys) {
        if (existingUser[key] != formattedUser[key]) {
          shouldUpdate = true;
          break;
        }
      }

      if (shouldUpdate) {
        AllAPIs.userList[index] = formattedUser;
        if (!widget.isSearchScreen) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.updateList(); // Update the UI if not on search screen
          });
        }
      }
    } else {
      AllAPIs.userList.add(formattedUser);
    }
  }

  static const Map<int, String> _months = {
    1: 'Jan',
    2: 'Feb',
    3: 'Mar',
    4: 'Apr',
    5: 'May',
    6: 'Jun',
    7: 'Jul',
    8: 'Aug',
    9: 'Sep',
    10: 'Oct',
    11: 'Nov',
    12: 'Dec'
  };

  String formatDateTime(String timestamp, BuildContext context) {
    final timeOfDay = DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp));
    final now = DateTime.now();
    final difference = now.difference(timeOfDay).inDays;

    if (timeOfDay.month == now.month && timeOfDay.year == now.year) {
      if (timeOfDay.day == now.day) {
        return TimeOfDay.fromDateTime(timeOfDay).format(context);
      } else if (difference == 1) {
        return 'Yesterday';
      }
    }

    return timeOfDay.year == now.year
        ? '${timeOfDay.day} ${_months[timeOfDay.month] ?? ''}'
        : '${timeOfDay.day} ${_months[timeOfDay.month] ?? ''} ${timeOfDay.year}';
  }

  Widget trailingMessage() {
    if (_message == null) return const SizedBox();
    return _message!.fromid == AllAPIs.auth.currentUser?.uid ||
            _message!.read.isNotEmpty
        ? Text(formatDateTime(_message!.sent, context))
        : Container(
            height: 15,
            width: 15,
            decoration: const BoxDecoration(
              color: Colors.greenAccent,
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
          );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String message = '';
    return StreamBuilder(
      stream: AllAPIs.getLastMessages(widget.user),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data?.docs.isNotEmpty == true) {
          _message = Message.fromJson(snapshot.data!.docs.first.data());
          Map<String, dynamic> newUser = {
            'uid': widget.user.uid,
            'lastmessage': _message?.sent
          };
          addOrUpdateUser(newUser);
              message = _message?.msg ?? widget.user.username;
        } else {
          _message = null;
        }
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: widget.user.profilePic.isEmpty
                ? AllAPIs.defaultImage
                : CachedNetworkImageProvider(widget.user.profilePic),
          ),
          title: Text(
            widget.user.name.isNotEmpty ? widget.user.name : 'HiiChat User',
            style: const TextStyle(fontSize: 15),
          ),
          subtitle: widget.isSearchScreen
              ? Text(
                  widget.user.username,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(color: Colors.grey),
                )
              : Row(
                  children: [
                    if (_message?.fromid == AllAPIs.auth.currentUser?.uid)
                      Icon(
                        _message!.read.isNotEmpty
                            ? Icons.done_all_rounded
                            : Icons.done,
                        color: _message!.read.isNotEmpty
                            ? Colors.blue
                            : Colors.grey,
                        size: 15,
                      ),
                    const SizedBox(
                      width: 3,
                    ),
                    Text(
                      message,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
          trailing: !widget.isSearchScreen ? trailingMessage() : null,
          onTap: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    ChatScreen(user: widget.user),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
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
        );
      },
    );
  }
}
