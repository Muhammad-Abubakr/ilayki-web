import 'dart:convert';

class User {
  final String uid;
  final String displayName;
  final String email;
  final String pfp;

  User({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.pfp,
  });

  User copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? pfp,
  }) {
    return User(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      pfp: pfp ?? this.pfp,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'pfp': pfp,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'] as String,
      displayName: map['displayName'] as String,
      email: map['email'] as String,
      pfp: map['pfp'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'User(uid: $uid, displayName: $displayName, email: $email, pfp: $pfp)';
  }

  @override
  bool operator ==(covariant User other) {
    if (identical(this, other)) return true;

    return other.uid == uid &&
        other.displayName == displayName &&
        other.email == email &&
        other.pfp == pfp;
  }

  @override
  int get hashCode {
    return uid.hashCode ^ displayName.hashCode ^ email.hashCode ^ pfp.hashCode;
  }
}
