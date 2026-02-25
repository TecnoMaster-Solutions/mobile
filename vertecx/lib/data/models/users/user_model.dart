enum UserStatus { activo, inactivo }

class UserModel {
  final String id;
  final String nombreCompleto;
  final String documentoId;
  final String telefono;
  final String email;
  final UserStatus estado;
  final String roleString;
  final String imagenPath;
  final String tipoDocumento;

  UserModel({
    required this.id,
    required this.nombreCompleto,
    required this.documentoId,
    required this.telefono,
    required this.email,
    required this.estado,
    required this.roleString,
    required this.imagenPath,
    required this.tipoDocumento,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Obtener el estado desde stateid
    final rawStateId = json['stateid'];
    final stateId = rawStateId is int
        ? rawStateId
        : int.tryParse(rawStateId?.toString() ?? "") ?? 2;
    final estado = stateId == 1 ? UserStatus.activo : UserStatus.inactivo;

    // Obtener el rol desde roles.name o roleconfiguration.roles.name
    String roleName = "Sin rol";
    final roleSource = json['roles'] ?? json['roleconfiguration']?['roles'];
    if (roleSource is Map && roleSource['name'] != null) {
      final name = roleSource['name'].toString().trim();
      if (name.isNotEmpty) {
        roleName = name;
      }
    }

    String tipoDoc = "Sin tipo";
    try {
      tipoDoc = json['typeofdocuments']['name'] as String;
    } catch (e) {
      // Si no existe, usa "Sin tipo"
    }

    return UserModel(
      id: json['userid'].toString(),
      nombreCompleto: "${json['name']} ${json['lastname']}".trim(),
      documentoId: json['documentnumber'],
      telefono: json['phone'],
      email: json['email'],
      estado: estado,
      roleString: roleName,
      imagenPath: json['image'] ?? 'assets/icons/userP.png',
      tipoDocumento: tipoDoc,
    );
  }

  // Método de utilidad para mapear el enum a una cadena de estado legible
  String get statusString {
    return estado == UserStatus.activo ? "Activo" : "Inactivo";
  }
}

UserModel toggleStatus(UserModel user) {
  return UserModel(
    id: user.id,
    nombreCompleto: user.nombreCompleto,
    documentoId: user.documentoId,
    telefono: user.telefono,
    email: user.email,
    estado: user.estado == UserStatus.activo
        ? UserStatus.inactivo
        : UserStatus.activo,
    roleString: user.roleString,
    imagenPath: user.imagenPath,
    tipoDocumento: user.tipoDocumento,
  );
}

extension UserSearch on UserModel {
  bool matchesQuery(String query) {
    final normalizedQuery = removeDiacritics(query.toLowerCase());

    //chequeo exacto para estados
    if (normalizedQuery == "activo") {
      return estado == UserStatus.activo;
    }
    if (normalizedQuery == "inactivo") {
      return estado == UserStatus.inactivo;
    }

    //resto de campos usa búsqueda flexible con contains
    return removeDiacritics(
          nombreCompleto.toLowerCase(),
        ).contains(normalizedQuery) ||
        removeDiacritics(documentoId.toLowerCase()).contains(normalizedQuery) ||
        removeDiacritics(telefono.toLowerCase()).contains(normalizedQuery) ||
        removeDiacritics(email.toLowerCase()).contains(normalizedQuery) ||
        removeDiacritics(roleString.toLowerCase()).contains(normalizedQuery) ||
        removeDiacritics(roleString.toLowerCase()).contains(normalizedQuery) ||
        removeDiacritics(tipoDocumento.toLowerCase()).contains(normalizedQuery) ||
        removeDiacritics(statusString.toLowerCase()).contains(normalizedQuery);
  }
}

String removeDiacritics(String input) {
  const withDiacritics = 'áéíóúÁÉÍÓÚñÑ';
  const withoutDiacritics = 'aeiouAEIOUnN';

  return input.split('').map((char) {
    final index = withDiacritics.indexOf(char);
    if (index >= 0) {
      return withoutDiacritics[index];
    }
    return char;
  }).join();
}
