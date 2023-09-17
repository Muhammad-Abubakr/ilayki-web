import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class Message {
  /* Fields */
  String sender;
  String receiver;
  DateTime time;
  String content;
  Message({
    required this.sender,
    required this.receiver,
    required this.time,
    required this.content,
  });

  Message copyWith({
    String? sender,
    String? receiver,
    DateTime? time,
    String? content,
  }) {
    return Message(
      sender: sender ?? this.sender,
      receiver: receiver ?? this.receiver,
      time: time ?? this.time,
      content: content ?? this.content,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'sender': sender,
      'receiver': receiver,
      'time': time.millisecondsSinceEpoch,
      'content': content,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      sender: map['sender'] as String,
      receiver: map['receiver'] as String,
      time: DateTime.fromMillisecondsSinceEpoch(map['time'] as int),
      content: map['content'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Message.fromJson(String source) =>
      Message.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Message(sender: $sender, receiver: $receiver, time: $time, content: $content)';
  }

  @override
  bool operator ==(covariant Message other) {
    if (identical(this, other)) return true;

    return other.sender == sender &&
        other.receiver == receiver &&
        other.time == time &&
        other.content == content;
  }

  @override
  int get hashCode {
    return sender.hashCode ^
        receiver.hashCode ^
        time.hashCode ^
        content.hashCode;
  }
}
