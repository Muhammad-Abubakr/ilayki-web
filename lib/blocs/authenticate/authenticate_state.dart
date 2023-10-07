part of 'authenticate_bloc.dart';

abstract class AuthenticateState {
  final User? user;
  final FirebaseAuthException? error;
  final FirebaseException? exception;

  AuthenticateState({
    this.user,
    this.error,
    this.exception,
  });
}

class AuthError extends AuthenticateState {
  AuthError({super.error});
}

class DatabaseException extends AuthenticateState {
  DatabaseException({super.exception});
}

class AuthSuccessful extends AuthenticateState {
  AuthSuccessful({super.user});
}

class AuthInit extends AuthenticateState {}

class AuthProcessing extends AuthenticateState {}

class AuthRegistered extends AuthenticateState {}

class AuthReset extends AuthenticateState {}
