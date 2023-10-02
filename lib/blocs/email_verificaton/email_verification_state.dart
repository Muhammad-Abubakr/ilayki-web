part of 'email_verification_cubit.dart';

enum EmailVerificationStatus { unavailable, verified, pending }

abstract class EmailVerificationState {
  final EmailVerificationStatus status;

  const EmailVerificationState({required this.status});
}

/* Initial State */
class EmailVerificationStateInitial extends EmailVerificationState {
  const EmailVerificationStateInitial({required super.status});
}

/* Updated State */
class EmailVerificationStateUpdated extends EmailVerificationState {
  const EmailVerificationStateUpdated({required super.status});
}
