import 'package:cloud_firestore/cloud_firestore.dart';
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
String formatReadTime(Timestamp? time,BuildContext context){

  final timeOfDay = TimeOfDay.fromDateTime(DateTime.fromMillisecondsSinceEpoch(time!.millisecondsSinceEpoch));
  final formattedTime = timeOfDay.format(context);

  // Return the formatted time
  return formattedTime;
}
class _MessageCardState extends State<MessageCard> {
  bool repeat=true;
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
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Column(
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
                    widget.message.read!=null
                        ? formatReadTime(widget.message.read, context)
                        : "Not read",
                    style: const TextStyle(
                      fontSize: 5,
                      color: Color(0xFFBDBDBD),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    color: widget.message.status == Status.wait || widget.message.status == Status.unread
                        ? Colors.grey
                        : Colors.blue,
                    widget.message.status == Status.wait
                        ? Icons.access_time
                        : widget.message.status == Status.read
                            ? Icons.done_all_rounded
                            : Icons.done_rounded,
                    size: 8,
                  )
                ],
              ),
            ],
          ),
        ),
        Flexible(
          child: Container(
            margin: EdgeInsets.only(
                left: 3,
                top: widget.previousId == widget.message.fromid ? 2 : 10,
                bottom: 0,
                right: 10),
            padding: const EdgeInsets.fromLTRB(13, 10, 13, 10),
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
    if(widget.message.status == Status.unread && repeat){
      // repeat=false;
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
            padding: const EdgeInsets.fromLTRB(13, 10, 13, 10),
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
          margin: const EdgeInsets.only(bottom: 10, right: 20),
          child: Text(
            formatReadTime(widget.message.serverTime, context),
            style: const TextStyle(fontSize: 8, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
