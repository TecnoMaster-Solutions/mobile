import 'dart:async';

abstract class AuthRepository {
  /// Retorna un token si las credenciales son válidas.
  Future<String> signIn({required String email, required String password});

  Future<void> signOut();
}

/// Impl. de ejemplo (simula backend)
class AuthRepositoryFake implements AuthRepository {
  @override
  Future<String> signIn({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Demo: credenciales válidas
    if (email == 'admin@sistemaspc.com' && password == '123456') {
      return 'fake_jwt_token';
    }
    throw Exception('Credenciales inválidas');
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
