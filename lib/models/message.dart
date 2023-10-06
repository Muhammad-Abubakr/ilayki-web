import 'dart:convert';

class Message {
  final String senderUid;
  final String receiverUid;
  final String content;
  final DateTime timestamp;

  Message({
    required this.senderUid,
    required this.receiverUid,
    required this.content,
    required this.timestamp,
  });

  Message copyWith({
    String? senderUid,
    String? receiverUid,
    String? content,
    DateTime? timestamp,
  }) {
    return Message(
      senderUid: senderUid ?? this.senderUid,
      receiverUid: receiverUid ?? this.receiverUid,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'senderUid': senderUid,
      'receiverUid': receiverUid,
      'content': content,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderUid: map['senderUid'] as String,
      receiverUid: map['receiverUid'] as String,
      content: map['content'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory Message.fromJson(String source) =>
      Message.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Message(senderUid: $senderUid, receiverUid: $receiverUid, content: $content, timestamp: $timestamp)';
  }

  @override
  bool operator ==(covariant Message other) {
    if (identical(this, other)) return true;

    return other.senderUid == senderUid &&
        other.receiverUid == receiverUid &&
        other.content == content &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return senderUid.hashCode ^ receiverUid.hashCode ^ content.hashCode ^ timestamp.hashCode;
  }
}
