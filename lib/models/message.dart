import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  Message({
    required this.fromid,
    required this.msg,
    required this.read,
    required this.sent,
    required this.told,
    required this.type,
    required this.serverTime,
    required this.status,
  });

  late final String fromid;
  late final String msg;
  late final Timestamp? read;
  late final String sent;
  late final String told;
  late final Type type;
  late final Timestamp? serverTime;
  late final Status status;

  Message.fromJson(Map<String, dynamic> json) {
    fromid = json['fromid'].toString();
    msg = json['msg'].toString();
    read = json['read'];
    sent = json['sent'].toString();
    told = json['told'].toString();
    type = json['type'].toString() == Type.image.name ? Type.image : Type.text;
    serverTime = json['serverTime'] as Timestamp?;
    status = json['status'].toString() == Status.read.name
        ? Status.read
        : json['status'].toString() == Status.unread.name
            ? Status.unread
            : Status.wait;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['fromid'] = fromid;
    data['msg'] = msg;
    data['read'] = read;
    data['sent'] = sent;
    data['told'] = told;
    data['type'] = type.name;
    data['serverTime'] = serverTime;
    data['status'] = status.name;
    return data;
  }
}

enum Type { text, image }

enum Status { unread, read, wait }
