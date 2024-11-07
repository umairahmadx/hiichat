import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hiichat/firebase/firebaseapis.dart';
import 'package:hiichat/models/message.dart';
import '../models/chatuser.dart';
import 'chatscreen.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  final bool isSearchScreen;

  const ChatUserCard({
    required this.user,
    this.isSearchScreen = false,
    super.key,
  });

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? _message;
  bool imageError = false;

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
            _message?.read != null
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
              ? Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.user.username,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    if (_message?.fromid == AllAPIs.auth.currentUser?.uid)
                      Icon(
                        color: _message?.status == Status.wait ||
                                _message?.status == Status.unread
                            ? Colors.grey
                            : Colors.blue,
                        _message?.status == Status.wait
                            ? Icons.access_time
                            : _message?.status == Status.read
                                ? Icons.done_all_rounded
                                : Icons.done_rounded,
                        size: 8,
                      ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        message.isNotEmpty ? message : widget.user.username,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(color: Colors.grey),
                      ),
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
