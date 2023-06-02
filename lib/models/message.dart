import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class Message {
  /* Fields */
  String sender;
  DateTime time;
  String content;

  /* Constructor */
  Message({
    required this.sender,
    required this.time,
    required this.content,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'sender': sender,
      'time': time.millisecondsSinceEpoch,
      'content': content,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      sender: map['sender'] as String,
      time: DateTime.fromMillisecondsSinceEpoch(map['time'] as int),
      content: map['content'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Message.fromJson(String source) =>
      Message.fromMap(json.decode(source) as Map<String, dynamic>);
}
