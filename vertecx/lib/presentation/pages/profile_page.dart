import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vertecx/core/api_http.dart';
import 'package:vertecx/core/session_context.dart';
import 'package:vertecx/data/constants/api_constants.dart';
import 'package:vertecx/presentation/routes/app_routes.dart';
import 'package:vertecx/presentation/widgets/navigationWidgets/app_top_bar.dart';
import 'package:vertecx/presentation/widgets/navigationWidgets/side_menu_panel.dart';

/// ---- Modelo de datos ----
class UserProfile {
  final String id;
  final String nombre;
  final String rol; // 'Administrador', 'Tecnico', 'Cliente'
  final String correo;
  final String telefono;
  final String documento; // NIT/CC
  final String avatarUrl; // puedes dejarlo vacÃƒÆ’Ã‚Â­o para placeholder
  final String? empresa;
  final DateTime? creadoEl;
  final int? ordenes;
  final int? solicitudes;
  final double? rating; // 0..5

  const UserProfile({
    required this.id,
    required this.nombre,
    required this.rol,
    required this.correo,
    required this.telefono,
    required this.documento,
    required this.avatarUrl,
    this.empresa,
    this.creadoEl,
    this.ordenes,
    this.solicitudes,
    this.rating,
  });

  UserProfile copyWith({
    String? nombre,
    String? rol,
    String? correo,
    String? telefono,
    String? documento,
    String? avatarUrl,
    String? empresa,
    DateTime? creadoEl,
    int? ordenes,
    int? solicitudes,
    double? rating,
  }) {
    return UserProfile(
      id: id,
      nombre: nombre ?? this.nombre,
      rol: rol ?? this.rol,
      correo: correo ?? this.correo,
      telefono: telefono ?? this.telefono,
      documento: documento ?? this.documento,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      empresa: empresa ?? this.empresa,
      creadoEl: creadoEl ?? this.creadoEl,
      ordenes: ordenes ?? this.ordenes,
      solicitudes: solicitudes ?? this.solicitudes,
      rating: rating ?? this.rating,
    );
  }
}

/// ---- Repositorio (API) ----
abstract class IProfileRepository {
  Future<UserProfile> getProfile();
}

class ProfileRepositoryApi implements IProfileRepository {
  String get _baseUrl => kBackendBaseUrl;

  @override
  Future<UserProfile> getProfile() async {
    final meUri = Uri.parse('$_baseUrl/auth/me');
    final meResponse = await ApiHttp.get(
      meUri,
      headers: const {'Accept': 'application/json'},
    );

    if (meResponse.statusCode != 200 && meResponse.statusCode != 201) {
      throw Exception(
        'Error al obtener usuario autenticado: ${meResponse.statusCode}',
      );
    }

    final meBody = _asMap(jsonDecode(meResponse.body));
    final mePermissionsRaw = meBody['permissions'];
    if (mePermissionsRaw is List) {
      SessionContext.permissions = mePermissionsRaw
          .map((e) => e.toString())
          .toList();
    }

    final userId = _toInt(meBody['userid']);
    if (userId == null) {
      throw Exception('No se pudo resolver el id del usuario autenticado');
    }

    final userUri = Uri.parse('$_baseUrl/users/$userId');
    final userResponse = await ApiHttp.get(
      userUri,
      headers: const {'Accept': 'application/json'},
    );

    if (userResponse.statusCode != 200 && userResponse.statusCode != 201) {
      throw Exception('Error al obtener perfil: ${userResponse.statusCode}');
    }

    final detailBody = _asMap(jsonDecode(userResponse.body));
    final data = _asMap(detailBody['data']);

    final fullName = _buildName(
      _toStr(data['name']),
      _toStr(data['lastname']),
      fallback: _toStr(meBody['name']),
    );
    final roleName = _toStr(_asMap(data['role'])['name']);
    final roleNameAlt = _toStr(_asMap(data['roles'])['name']);
    final roleFromMe = _toStr(meBody['rolename']);
    final email = _toStr(data['email']);
    final empresa = _pickString(
      data,
      const ['empresa', 'company', 'companyName', 'businessName'],
    );

    return UserProfile(
      id: userId.toString(),
      nombre: fullName,
      rol: roleName.isNotEmpty
          ? roleName
          : (roleNameAlt.isNotEmpty ? roleNameAlt : roleFromMe),
      correo: email.isNotEmpty ? email : _toStr(meBody['email']),
      telefono: _toStr(data['phone']),
      documento: _toStr(data['documentnumber']),
      avatarUrl: _toStr(data['image']),
      empresa: empresa.isNotEmpty ? empresa : null,
      creadoEl: _toDate(data['createat']),
      ordenes: _extractCountNullable(
        data,
        const ['ordenes', 'orders', 'ordersCount', 'orders_count'],
      ),
      solicitudes: _extractCountNullable(
        data,
        const [
          'solicitudes',
          'requests',
          'serviceRequests',
          'requestsCount',
          'requests_count',
        ],
      ),
      rating: _extractDoubleNullable(
        data,
        const ['rating', 'calificacion', 'promedio', 'averageRating'],
      ),
    );
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return <String, dynamic>{};
  }

  static String _toStr(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  static double? _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }

  static DateTime? _toDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value.trim());
    }
    return null;
  }

  static String _buildName(
    String first,
    String last, {
    required String fallback,
  }) {
    final composed = [first, last]
        .where((part) => part.trim().isNotEmpty)
        .join(' ')
        .trim();
    return composed.isNotEmpty ? composed : fallback.trim();
  }

  static String _pickString(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = _toStr(data[key]);
      if (value.isNotEmpty) return value;
    }
    return '';
  }

  static int? _extractCountNullable(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final parsed = _toInt(data[key]);
      if (parsed != null) return parsed;
    }
    return null;
  }

  static double? _extractDoubleNullable(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final parsed = _toDouble(data[key]);
      if (parsed != null) return parsed;
    }
    return null;
  }
}
/// ---- Controller ----
class ProfileController extends ChangeNotifier {
  ProfileController(this._repo);

  final IProfileRepository _repo;

  UserProfile? _profile;
  String? _error;
  bool _loading = false;

  UserProfile? get profile => _profile;
  String? get error => _error;
  bool get loading => _loading;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _profile = await _repo.getProfile();
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '').trim();
      _error = message.isNotEmpty ? message : 'No se pudo cargar el perfil';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async => load();
}

/// ---- Pagina ----
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileController(ProfileRepositoryApi())..load(),
      child: const _ProfileScaffold(),
    );
  }
}

class _ProfileScaffold extends StatelessWidget {
  const _ProfileScaffold();

  @override
  Widget build(BuildContext context) {
    final brandRed = const Color(0xFFB20000);
    final args = ModalRoute.of(context)?.settings.arguments;
    final permissions = args is List<String>
        ? args
        : SessionContext.permissions;

    void _logout() {
      SessionContext.clearAll();
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      drawer: Drawer(
        backgroundColor: Colors.transparent,
        child: SideMenuPanel(
          permissions: permissions,
          onClose: () => Navigator.of(context).maybePop(),
          onLogout: () {
            Navigator.of(context).maybePop();
            _logout();
          },
        ),
      ),
      appBar: const AppTopBar(
        title: 'Perfil',
        centerTitle: true,
        showBack: false,
        showMenu: true,
      ),
      body: Consumer<ProfileController>(
        builder: (_, c, __) {
          if (c.loading) {
            return const _Skeleton();
          }
          if (c.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 40,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 10),
                    Text(c.error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: c.load,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandRed,
                      ),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }
          final p = c.profile!;
          final hasStats = p.ordenes != null || p.solicitudes != null;
          return RefreshIndicator(
            onRefresh: c.refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HeaderCard(profile: p),
                  if (hasStats) ...[
                    const SizedBox(height: 12),
                    _StatsGrid(profile: p),
                  ],
                  const SizedBox(height: 12),
                  _InfoCard(profile: p),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(
                      Icons.logout_outlined,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Cerrar sesion',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandRed,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// ---- Header (avatar + nombre + rol + rating) ----
class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    const wine = Color(0xFF5C0F0F);
    const red = Color(0xFFB20000);
    final hasRole = profile.rol.trim().isNotEmpty;
    final hasRating = profile.rating != null;
    final hasEmpresa = (profile.empresa ?? '').trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: const Color(0xFFE8E8E8),
            backgroundImage: (profile.avatarUrl.isNotEmpty)
                ? NetworkImage(profile.avatarUrl)
                : null,
            child: (profile.avatarUrl.isEmpty)
                ? Text(
                    _initials(profile.nombre),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: wine,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Wrap(
              runSpacing: 6,
              children: [
                Text(
                  profile.nombre.trim().isNotEmpty ? profile.nombre : 'Sin nombre',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: wine,
                  ),
                ),
                if (hasRole || hasRating)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasRole)
                        _Chip(
                          text: profile.rol,
                          bg: const Color(0xFFFFF1F1),
                          fg: red,
                          icon: Icons.verified_user_outlined,
                        ),
                      if (hasRole && hasRating) const SizedBox(width: 8),
                      if (hasRating)
                        _Chip(
                          text: profile.rating!.toStringAsFixed(1),
                          bg: const Color(0xFFF8FAFC),
                          fg: wine,
                          icon: Icons.star_rate_rounded,
                        ),
                    ],
                  ),
                if (hasEmpresa)
                  Text(
                    profile.empresa!,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _initials(String name) {
    final clean = name.trim();
    if (clean.isEmpty) return '?';
    final parts = clean.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts[0].characters.first + parts[1].characters.first)
        .toUpperCase();
  }
}
class _Chip extends StatelessWidget {
  const _Chip({
    required this.text,
    required this.bg,
    required this.fg,
    this.icon,
  });
  final String text;
  final Color bg;
  final Color fg;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(color: fg, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// ---- Stats ----
class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    const wine = Color(0xFF5C0F0F);

    Widget stat(String label, String value, IconData icon) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: wine),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: wine,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final stats = <Widget>[
      if (profile.ordenes != null)
        stat(
          'Ordenes',
          '${profile.ordenes}',
          Icons.assignment_turned_in_outlined,
        ),
      if (profile.solicitudes != null)
        stat('Solicitudes', '${profile.solicitudes}', Icons.list_alt_outlined),
    ];

    if (stats.isEmpty) {
      return const SizedBox.shrink();
    }

    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 78,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      children: stats,
    );
  }
}
/// ---- Informacion de contacto / detalle ----
class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    const wine = Color(0xFF5C0F0F);

    Widget row(
      IconData icon,
      String title,
      String value, {
      VoidCallback? onTap,
    }) {
      return InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 22, color: wine),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final rows = <Widget>[];

    void addRow(IconData icon, String title, String value) {
      if (value.trim().isEmpty) return;
      if (rows.isNotEmpty) {
        rows.add(const Divider(height: 1));
      }
      rows.add(row(icon, title, value));
    }

    addRow(Icons.badge_outlined, 'Documento', profile.documento);
    addRow(Icons.mail_outline, 'Correo', profile.correo);
    addRow(Icons.phone_outlined, 'Telefono', profile.telefono);
    addRow(Icons.apartment_outlined, 'Empresa', profile.empresa ?? '');

    final createdAt = profile.creadoEl;
    if (createdAt != null) {
      final fecha =
          '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';
      addRow(Icons.calendar_today_outlined, 'Creado el', fecha);
    }

    if (rows.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Column(children: rows),
    );
  }
}
/// ---- Skeleton (cargando) ----
class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    Widget box({double h = 70}) => Container(
      height: h,
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(16),
      ),
    );

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        children: [
          box(h: 90),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: box()),
              const SizedBox(width: 10),
              Expanded(child: box()),
            ],
          ),
          const SizedBox(height: 12),
          box(h: 180),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: box(h: 48)),
              const SizedBox(width: 12),
              Expanded(child: box(h: 48)),
            ],
          ),
        ],
      ),
    );
  }
}

