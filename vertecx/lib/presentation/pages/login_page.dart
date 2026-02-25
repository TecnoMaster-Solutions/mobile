import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:vertecx/core/api_http.dart';
import 'package:vertecx/core/api_config.dart';
import 'package:vertecx/core/navigation_helper.dart';
import 'package:vertecx/core/session_context.dart';

class User {
  final int id;
  final String email;
  final String name;
  final int roleId;
  final String roleName;
  final List<String> permissions;
  final String accessToken;
  final String refreshToken;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.roleId,
    required this.roleName,
    required this.permissions,
    required this.accessToken,
    required this.refreshToken,
  });
}

class AuthService {
  static const _baseUrl = ApiConfig.baseUrl;
  static const _loginPath = '/auth/login';
  static const _mePath = '/auth/me';

  static Future<User> signIn(String email, String password) async {
    final rawEmail = email.trim();
    if (rawEmail.isEmpty || password.isEmpty) {
      throw Exception('Credenciales inválidas');
    }

    final normalizedEmail = rawEmail.toLowerCase();
    final loginUri = Uri.parse('$_baseUrl$_loginPath');

    final loginRes = await ApiHttp.post(
      loginUri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': normalizedEmail, 'password': password}),
    );

    if (loginRes.statusCode != 200 && loginRes.statusCode != 201) {
      String message = 'Credenciales inválidas';
      try {
        final body = jsonDecode(loginRes.body) as Map<String, dynamic>;
        final raw = body['message'];
        if (raw is String && raw.isNotEmpty) {
          message = raw;
        } else if (raw is List && raw.isNotEmpty) {
          message = raw.first.toString();
        }
      } catch (_) {}
      throw Exception(message);
    }

    final loginBody = jsonDecode(loginRes.body) as Map<String, dynamic>;
    final accessToken = (loginBody['access_token'] ?? '').toString();
    final refreshToken = (loginBody['refresh_token'] ?? '').toString();

    if (accessToken.isEmpty) {
      throw Exception('Token de acceso no recibido');
    }
    if (refreshToken.isEmpty) {
      throw Exception('Refresh token no recibido');
    }

    SessionContext.setTokens(access: accessToken, refresh: refreshToken);

    final meUri = Uri.parse('$_baseUrl$_mePath');

    final meRes = await ApiHttp.get(
      meUri,
      headers: {'Accept': 'application/json'},
    );

    if (meRes.statusCode != 200 && meRes.statusCode != 201) {
      SessionContext.clearAuth();
      throw Exception('No se pudo obtener la información del usuario');
    }

    final meBody = jsonDecode(meRes.body) as Map<String, dynamic>;

    final id = meBody['userid'] as int;
    final emailApi = (meBody['email'] as String).toLowerCase();
    final name = meBody['name'] as String;
    final roleId = meBody['roleid'] as int;
    final roleName = meBody['rolename'] as String;
    final permissions = (meBody['permissions'] as List<dynamic>)
        .map((e) => e.toString())
        .toList();

    return User(
      id: id,
      email: emailApi,
      name: name,
      roleId: roleId,
      roleName: roleName,
      permissions: permissions,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _pass = TextEditingController();
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  bool _loading = false;
  bool _obscure = true;

  static const Color primary = Color(0xFFD30000);
  static const Color primaryHover = Color(0xFFA80000);
  static const Color bgLight = Color(0xFFF9FAFB);
  static const Color bgDark = Color(0xFF111827);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1F2937);
  static const Color textLight = Color(0xFF111827);
  static const Color textDark = Color(0xFFF9FAFB);
  static const Color mutedLight = Color(0xFF6B7280);
  static const Color mutedDark = Color(0xFF9CA3AF);
  static const Color inputBgLight = Color(0xFFF3F4F6);
  static const Color inputBgDark = Color(0xFF374151);

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) {
      return;
    }
    setState(() => _loading = true);
    try {
      final User user = await AuthService.signIn(_email.text, _pass.text);
      SessionContext.permissions = user.permissions;
      if (!mounted) {
        return;
      }

      NavigationHelper.goToLanding(context, permissions: user.permissions);
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Widget _buildLogo() {
    final Color borderColor = primary.withOpacity(_isDark ? 0.4 : 0.2);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(120),
            border: Border.all(color: borderColor, width: 4),
          ),
          child: Image.asset(
            'assets/imgs/logo.png',
            height: 80,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    final Color fillColor = _isDark ? inputBgDark : inputBgLight;
    final Color labelColor = _isDark ? textDark : textLight;
    final Color iconColor = _isDark ? mutedDark : mutedLight;

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        color: labelColor,
        fontSize: 13,
      ),
      prefixIcon: Icon(icon, color: iconColor),
      suffixIcon: suffix,
      filled: true,
      fillColor: fillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide(color: primary, width: 1.2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = _isDark ? bgDark : bgLight;
    final Color surfaceColor = _isDark ? surfaceDark : surfaceLight;
    final Color titleColor = _isDark ? textDark : textLight;
    final Color mutedColor = _isDark ? mutedDark : mutedLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLogo(),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: _isDark
                          ? const <BoxShadow>[]
                          : <BoxShadow>[
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 18,
                                offset: const Offset(0, 10),
                              ),
                            ],
                    ),
                    child: Form(
                      key: _form,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Bienvenido a Sistemas PC',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: titleColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Ingresa tus datos para continuar.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: mutedColor),
                          ),
                          const SizedBox(height: 24),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 4,
                                bottom: 6,
                              ),
                              child: Text(
                                'Email',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: titleColor,
                                ),
                              ),
                            ),
                          ),
                          TextFormField(
                            controller: _email,
                            enabled: !_loading,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDecoration(
                              label: 'Correo electrónico',
                              icon: Icons.email_outlined,
                            ),
                            validator: (String? v) {
                              final String value = (v ?? '').trim();
                              if (value.isEmpty) {
                                return 'Ingrese su correo';
                              }
                              final bool ok = RegExp(
                                r'^[^@]+@[^@]+\.[^@]+',
                              ).hasMatch(value);
                              if (!ok) {
                                return 'Correo no válido';
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) => _submit(),
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 4,
                                bottom: 6,
                              ),
                              child: Text(
                                'Contraseña',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: titleColor,
                                ),
                              ),
                            ),
                          ),
                          TextFormField(
                            controller: _pass,
                            enabled: !_loading,
                            obscureText: _obscure,
                            decoration: _inputDecoration(
                              label: '••••••••••••',
                              icon: Icons.lock_outline,
                              suffix: IconButton(
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                              ),
                            ),
                            validator: (String? v) => (v == null || v.isEmpty)
                                ? 'Ingrese su contraseña'
                                : null,
                            onFieldSubmitted: (_) => _submit(),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: primary.withOpacity(
                                  0.6,
                                ),
                                disabledForegroundColor: Colors.white70,
                                elevation: 6,
                                shadowColor: primary.withOpacity(0.45),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              onPressed: _loading ? null : _submit,
                              child: _loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Text(
                                      'Iniciar sesión',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '© 2024 Sistemas PC. V 1.0.2',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: mutedColor.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
