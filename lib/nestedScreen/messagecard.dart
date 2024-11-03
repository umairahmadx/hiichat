import 'package:flutter/material.dart';
import 'package:hiichat/firebase/firebaseapis.dart';
import 'package:hiichat/models/message.dart';

class MessageCard extends StatefulWidget {
  final Message message;
  final String previousId;

  const MessageCard(
      {super.key, required this.message, required this.previousId});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

String formatTime(String time, BuildContext context) {
  final timeOfDay = TimeOfDay.fromDateTime(
      DateTime.fromMillisecondsSinceEpoch(int.parse(time)));

  // Get the formatted string with AM/PM
  final formattedTime = timeOfDay.format(context);

  // Return the formatted time
  return formattedTime;
}


class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return widget.message.fromid == AllAPIs.auth.currentUser?.uid
        ? _blueMessage()
        : _whiteMessage();
  }

  Widget _blueMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formatTime(widget.message.sent, context),
              style: const TextStyle(
                fontSize: 8,
                color: Colors.grey,
              ),
            ),
            Row(
              children: [
                Text(
                  widget.message.read.isNotEmpty
                      ? formatTime(widget.message.read, context)
                      : "Not read",
                  style: const TextStyle(
                    fontSize: 8,
                    color: Color(0xFFBDBDBD),
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  color: widget.message.read.isNotEmpty
                      ? Colors.blue
                      : Colors.grey,
                  widget.message.read.isNotEmpty
                      ? Icons.done_all_rounded
                      : Icons.done_rounded,
                  size: 8,
                )
              ],
            ),
          ],
        ),
        Flexible(
          child: Container(
            margin: EdgeInsets.only(
                left: 3,
                top: widget.previousId == widget.message.fromid ? 2 : 10,
                bottom: 0,
                right: 10),
            padding: const EdgeInsets.fromLTRB(13,10,13,10),
            decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(15),
                  bottomLeft: const Radius.circular(15),
                  topRight: Radius.circular(
                      widget.previousId == widget.message.fromid ? 3 : 15),
                  bottomRight: const Radius.circular(3),
                )),
            child: Text(
              widget.message.msg,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _whiteMessage() {
    if(widget.message.read.isEmpty){
      AllAPIs.updateMessageReadStatus(widget.message);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: Container(
            margin: EdgeInsets.only(
                left: 10,
                top: widget.previousId == widget.message.fromid ? 2 : 10,
                bottom: 0,
                right: 10),
            padding: const EdgeInsets.fromLTRB(13,10,13,10),
            decoration: BoxDecoration(
                color: const Color(0xFFE8E8EE),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(
                      widget.previousId == widget.message.fromid ? 3 : 15),
                  bottomRight: const Radius.circular(15),
                  topRight: const Radius.circular(15),
                  bottomLeft: const Radius.circular(3),
                )),
            child: Text(
              widget.message.msg,
              style: const TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 10, right: 5),
          child: Text(
            formatTime(widget.message.sent,context),
            style: const TextStyle(fontSize: 8, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
