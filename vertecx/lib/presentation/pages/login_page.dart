import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vertecx/core/api_config.dart';
import 'package:vertecx/core/api_http.dart';
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
  static String get _baseUrl => ApiConfig.baseUrl;
  static const _loginPath = '/auth/login';
  static const _mePath = '/auth/me';

  static Future<User> signIn(String email, String password) async {
    final String rawEmail = email.trim();
    if (rawEmail.isEmpty || password.isEmpty) {
      throw Exception('Credenciales invalidas');
    }

    final String normalizedEmail = rawEmail.toLowerCase();
    final Uri loginUri = Uri.parse('$_baseUrl$_loginPath');

    final loginRes = await ApiHttp.post(
      loginUri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': normalizedEmail, 'password': password}),
    );

    if (loginRes.statusCode != 200 && loginRes.statusCode != 201) {
      String message = 'Credenciales invalidas';
      try {
        final Map<String, dynamic> body =
            jsonDecode(loginRes.body) as Map<String, dynamic>;
        final dynamic raw = body['message'];
        if (raw is String && raw.isNotEmpty) {
          message = raw;
        } else if (raw is List && raw.isNotEmpty) {
          message = raw.first.toString();
        }
      } catch (_) {}
      throw Exception(message);
    }

    final Map<String, dynamic> loginBody =
        jsonDecode(loginRes.body) as Map<String, dynamic>;
    final String accessToken = (loginBody['access_token'] ?? '').toString();
    final String refreshToken = (loginBody['refresh_token'] ?? '').toString();

    if (accessToken.isEmpty) {
      throw Exception('Token de acceso no recibido');
    }
    if (refreshToken.isEmpty) {
      throw Exception('Refresh token no recibido');
    }

    SessionContext.setTokens(access: accessToken, refresh: refreshToken);

    final Uri meUri = Uri.parse('$_baseUrl$_mePath');

    final meRes = await ApiHttp.get(
      meUri,
      headers: {'Accept': 'application/json'},
    );

    if (meRes.statusCode != 200 && meRes.statusCode != 201) {
      SessionContext.clearAuth();
      throw Exception('No se pudo obtener la informacion del usuario');
    }

    final Map<String, dynamic> meBody =
        jsonDecode(meRes.body) as Map<String, dynamic>;

    final int id = meBody['userid'] as int;
    final String emailApi = (meBody['email'] as String).toLowerCase();
    final String name = meBody['name'] as String;
    final int roleId = meBody['roleid'] as int;
    final String roleName = meBody['rolename'] as String;
    final List<String> permissions = (meBody['permissions'] as List<dynamic>)
        .map((dynamic e) => e.toString())
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

  static const Color brandGreen = Color(0xFF06A646);
  static const Color brandGreenDark = Color(0xFF058A3C);
  static const Color brandGreenDeep = Color(0xFF04652C);
  static const Color pageBackground = Color(0xFFF6F3F3);
  static const Color textPrimary = Color(0xFF0D141C);
  static const Color textMuted = Color(0xFF3B5F73);
  static const Color inputBorder = Color(0xFFD7E2DA);
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

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      hintStyle: const TextStyle(
        color: Color(0xFF8AA098),
        fontSize: 14,
      ),
      prefixIcon: Icon(icon, color: brandGreenDeep.withOpacity(0.72), size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: inputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: inputBorder),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        borderSide: BorderSide(color: brandGreen, width: 1.4),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        borderSide: BorderSide(color: Colors.redAccent, width: 1.2),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        borderSide: BorderSide(color: Colors.redAccent, width: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
    );
  }

  Widget _buildBackdrop() {
    return Stack(
      children: <Widget>[
        Positioned(
          top: -70,
          right: -40,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: brandGreen.withOpacity(_isDark ? 0.14 : 0.10),
            ),
          ),
        ),
        Positioned(
          top: 120,
          left: -60,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: brandGreenDeep.withOpacity(_isDark ? 0.10 : 0.07),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color pageColor = _isDark ? const Color(0xFF0F1713) : pageBackground;
    final Color cardBorderColor =
        _isDark ? brandGreen.withOpacity(0.20) : brandGreen.withOpacity(0.10);
    final Color cardShadowColor =
        Colors.black.withOpacity(_isDark ? 0.18 : 0.06);
    final Color titleColor = _isDark ? Colors.white : textPrimary;
    final Color mutedColor = _isDark ? Colors.white70 : textMuted;
    final Color innerCardColor =
        _isDark ? Colors.white.withOpacity(0.03) : const Color(0xFFF4FBF6);

    return Scaffold(
      backgroundColor: pageColor,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            _buildBackdrop(),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(22, 24, 22, 26),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isDark
                            ? <Color>[
                                const Color(0xFF122219),
                                const Color(0xFF0E1712),
                              ]
                            : <Color>[
                                Colors.white,
                                const Color(0xFFF8FCF9),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: cardBorderColor),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: cardShadowColor,
                          blurRadius: 28,
                          offset: const Offset(0, 18),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _form,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return const LinearGradient(
                                colors: <Color>[
                                  brandGreenDeep,
                                  brandGreen,
                                  Color(0xFF2A9781),
                                ],
                              ).createShader(bounds);
                            },
                            child: const Text(
                              'Bienvenido a TecnoMaster',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ingresa tus datos para continuar.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: mutedColor,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: innerCardColor,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: _isDark
                                    ? Colors.white.withOpacity(0.07)
                                    : brandGreen.withOpacity(0.08),
                              ),
                            ),
                            child: Column(
                              children: <Widget>[
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
                                    label: 'Ingresa tu correo',
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
                                      return 'Correo no valido';
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
                                      'Contrasena',
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
                                    label: 'Ingresa tu contrasena',
                                    icon: Icons.lock_outline,
                                    suffix: IconButton(
                                      onPressed: () => setState(
                                        () => _obscure = !_obscure,
                                      ),
                                      icon: Icon(
                                        _obscure
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: brandGreenDeep.withOpacity(0.72),
                                      ),
                                    ),
                                  ),
                                  validator: (String? v) => (v == null || v.isEmpty)
                                      ? 'Ingrese su contrasena'
                                      : null,
                                  onFieldSubmitted: (_) => _submit(),
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      gradient: const LinearGradient(
                                        colors: <Color>[
                                          brandGreen,
                                          brandGreenDark,
                                        ],
                                      ),
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                          color: brandGreen.withOpacity(0.28),
                                          blurRadius: 18,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        foregroundColor: Colors.white,
                                        disabledBackgroundColor:
                                            Colors.transparent,
                                        disabledForegroundColor: Colors.white70,
                                        elevation: 0,
                                        shadowColor: Colors.transparent,
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
                                              'Iniciar sesion',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15,
                                                letterSpacing: 0.2,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            '(c) 2026 TecnoMaster',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: mutedColor.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
