class Message {
  Message({
    required this.fromid,
    required this.msg,
    required this.read,
    required this.sent,
    required this.told,
    required this.type,
  });
  late final String fromid;
  late final String msg;
  late final String read;
  late final String sent;
  late final String told;
  late final Type type;

  Message.fromJson(Map<String, dynamic> json){
    fromid = json['fromid'].toString();
    msg = json['msg'].toString();
    read = json['read'].toString();
    sent = json['sent'].toString();
    told = json['told'].toString();
    type = json['type'].toString() == Type.image.name? Type.image:Type.text;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['fromid'] = fromid;
    data['msg'] = msg;
    data['read'] = read;
    data['sent'] = sent;
    data['told'] = told;
    data['type'] = type.name;
    return data;
  }
}

enum Type{text,image}