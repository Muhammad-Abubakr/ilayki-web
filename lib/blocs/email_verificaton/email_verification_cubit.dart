import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/firebase/auth.dart' as auth;

part 'email_verification_state.dart';

class EmailVerificationCubit extends Cubit<EmailVerificationState> {
  final _auth = auth.AuthService();
  late StreamSubscription<User?> _firebaseUserChanges;

  EmailVerificationCubit()
      : super(const EmailVerificationStateInitial(
            status: EmailVerificationStatus.unavailable));

  /* Verification Status Sync */
  void initialize() {
    _firebaseUserChanges =
        FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null && user.emailVerified) {
        emit(const EmailVerificationStateUpdated(
            status: EmailVerificationStatus.verified));

        _firebaseUserChanges.cancel();
      } else {
        emit(const EmailVerificationStateUpdated(
            status: EmailVerificationStatus.pending));

        _firebaseUserChanges.cancel();
      }
    });
  }

  /* Verification Status Update */
  void verificationPending() {
    emit(const EmailVerificationStateUpdated(
        status: EmailVerificationStatus.pending));
  }

  bool check() {
    bool? verified = _auth.isEmailVerified;

    return verified != null && verified;
  }
}
