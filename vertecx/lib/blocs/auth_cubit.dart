import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vertecx/data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repo) : super(const AuthState.unauthenticated());
  final AuthRepository _repo;

  Future<void> signIn(String email, String password) async {
    emit(const AuthState.loading());
    try {
      final token = await _repo.signIn(email: email, password: password);
      emit(AuthState.authenticated(token));
    } catch (e) {
      emit(AuthState.failure(e.toString()));
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
    emit(const AuthState.unauthenticated());
  }
}
