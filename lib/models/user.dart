import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../blocs/user/user_bloc.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class User {
  /* Attributes */
  final String name;
  final String photoURL;
  final String uid;
  final UserRoles role;

  User({
    required this.name,
    required this.photoURL,
    required this.uid,
    required this.role,
  });

  User copyWith({
    String? name,
    String? photoURL,
    String? uid,
    UserRoles? role,
  }) {
    return User(
      name: name ?? this.name,
      photoURL: photoURL ?? this.photoURL,
      uid: uid ?? this.uid,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'photoURL': photoURL,
      'uid': uid,
      'role': describeEnum(role),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      name: map['name'] as String,
      photoURL: map['photoURL'] as String,
      uid: map['uid'] as String,
      role: UserRoles.values
          .firstWhere((e) => describeEnum(e) == (map['role'] as String)),
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'User(name: $name, photoURL: $photoURL, uid: $uid, role: $role)';
  }

  @override
  bool operator ==(covariant User other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.photoURL == photoURL &&
        other.uid == uid &&
        other.role == role;
  }

  @override
  int get hashCode {
    return name.hashCode ^ photoURL.hashCode ^ uid.hashCode ^ role.hashCode;
  }
}
