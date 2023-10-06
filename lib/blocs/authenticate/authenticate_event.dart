part of 'authenticate_bloc.dart';

abstract class AuthenticateEvent {}

class InitEvent extends AuthenticateEvent {}

class LogoutEvent extends AuthenticateEvent {}

class LoginEvent extends AuthenticateEvent {
  final String email;
  final String password;

  LoginEvent({required this.email, required this.password});
}

class RegisterEvent extends AuthenticateEvent {
  final String displayName;
  final String email;
  final String password;
  final Uint8List pfp;

  RegisterEvent({
    required this.displayName,
    required this.email,
    required this.password,
    required this.pfp,
  });
}
