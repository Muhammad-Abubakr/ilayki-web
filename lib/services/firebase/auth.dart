import 'package:firebase_auth/firebase_auth.dart';

/* Service Handler - Handles all calls between FirebaseAuth and Application */
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get subscribe => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
  bool? get isEmailVerified => _auth.currentUser?.emailVerified;

  /* Send email verification link to the user */
  Future<bool> verifyEmail(User user) async {
    await user.sendEmailVerification();
    return true;
  }

  /* Sign in Anonymously using signInAnonymously provided by FirebaseAuth.instance
  on successful sign in return User, otherwise return null; */
  Future<User?> signInAnon() async {
    UserCredential cred = await _auth.signInAnonymously();

    return cred.user;
  }

  /* Sign in with Email and Password */
  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email, password: password);

    return cred.user;
  }

  /* Sign in with Email and Password */
  Future<User?> signInWithGoogle() async {
    UserCredential cred = await _auth.signInWithProvider(GoogleAuthProvider());

    return cred.user;
  }

  /* register with Email and Password */
  Future<User?> registerWithEmailAndPassword(
      String email, String password) async {
    UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);

    return cred.user;
  }

  // logout
  Future<void> logout() async => await _auth.signOut();
}
