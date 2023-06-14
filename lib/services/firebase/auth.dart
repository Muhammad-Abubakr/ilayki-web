import 'package:firebase_auth/firebase_auth.dart';

/* Service Handler - Handles all calls between FirebaseAuth and Application */
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get subscribe => _auth.userChanges();

  /* Sign in Anononymously using signInAnonmously provided by FirebaseAuth.instance
  on successfull sign in return User, otherwise return null; */
  Future<User?> signInAnon() async {
    UserCredential cred = await _auth.signInAnonymously();

    return cred.user;
  }

  /* Sign in with Email and Password */
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    UserCredential cred =
        await _auth.signInWithEmailAndPassword(email: email, password: password);

    return cred.user;
  }

  /* Sign in with Email and Password */
  Future<User?> signInWithGoogle() async {
    UserCredential cred = await _auth.signInWithProvider(GoogleAuthProvider());

    return cred.user;
  }

  /* register with Email and Password */
  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    UserCredential cred =
        await _auth.createUserWithEmailAndPassword(email: email, password: password);

    return cred.user;
  }

  // logout
  Future<void> logout() async => await _auth.signOut();
}
