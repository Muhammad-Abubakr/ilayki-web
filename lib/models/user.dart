import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class User {
  /* Attributes */
  final String name;
  final String photoURL;
  final String uid;

  /* Constructor */
  const User({required this.name, required this.photoURL, required this.uid});

  /* Json Serialization */
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'photoURL': photoURL,
      'uid': uid,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      name: map['name'] as String,
      photoURL: map['photoURL'] as String,
      uid: map['uid'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);

  User copyWith({
    String? name,
    String? photoURL,
    String? uid,
  }) {
    return User(
      name: name ?? this.name,
      photoURL: photoURL ?? this.photoURL,
      uid: uid ?? this.uid,
    );
  }
}
