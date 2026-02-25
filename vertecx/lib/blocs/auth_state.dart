import 'package:equatable/equatable.dart';

enum AuthStatus { unauthenticated, loading, authenticated, failure }

class AuthState extends Equatable {
  final AuthStatus status;
  final String? token;
  final String? error;

  const AuthState._(this.status, {this.token, this.error});
  const AuthState.unauthenticated() : this._(AuthStatus.unauthenticated);
  const AuthState.loading()          : this._(AuthStatus.loading);
  const AuthState.authenticated(String t)
      : this._(AuthStatus.authenticated, token: t);
  const AuthState.failure(String msg)
      : this._(AuthStatus.failure, error: msg);

  @override
  List<Object?> get props => [status, token, error];
}
