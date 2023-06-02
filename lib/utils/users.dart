import 'package:firebase_database/firebase_database.dart';

import '../models/user.dart';

Future<List<User>> getUsers() async {
  /* Getting the reference to users */
  final usersRef = FirebaseDatabase.instance.ref("users");

  /* registering a stream to users */
  final snapshots = await usersRef.get();

  /* Parsing obtained users to User Model */
  return snapshots.children.map((e) => User.fromJson(e.value!.toString())).toList();
}
