enum CategoryStatus { activo, inactivo }

class CategoryProduct {
  final int id;
  final String? imagenPath;
  final String nombre;
  final String descripcion;
  final CategoryStatus estado;

  CategoryProduct({
    required this.id,
    this.imagenPath,
    required this.nombre,
    required this.descripcion,
    required this.estado,
  });

  factory CategoryProduct.fromJson(Map<String, dynamic> json) {
    final idValue = json['id'] ?? json['categoryid'] ?? json['category_id'];
    final parsedId = idValue is int
        ? idValue
        : int.tryParse(idValue?.toString() ?? "") ?? 0;

    final nameValue = json['name'] ?? json['categoryname'] ?? '';
    final descriptionValue =
        json['description'] ?? json['categorydescription'] ?? '';

    final statusRaw = json['status'] ?? json['isactive'];
    final isActive = statusRaw == true ||
        (statusRaw is String && statusRaw.toLowerCase() == 'true') ||
        (statusRaw is num && statusRaw == 1);
    final estado =
        isActive ? CategoryStatus.activo : CategoryStatus.inactivo;

    return CategoryProduct(
      id: parsedId,
      imagenPath: json['icon'],
      nombre: nameValue,
      descripcion: descriptionValue,
      estado: estado,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': nombre,
      'description': descripcion,
      'status': estado == CategoryStatus.activo,
      'icon': imagenPath,
    };
  }

  String get statusString =>
      estado == CategoryStatus.activo ? "Activo" : "Inactivo";
}

extension CategorySearch on CategoryProduct {
  bool matchesQuery(String query) {
    final normalizedQuery = removeDiacritics(query.toLowerCase());

    if (normalizedQuery == "activo") {
      return estado == CategoryStatus.activo;
    }
    if (normalizedQuery == "inactivo") {
      return estado == CategoryStatus.inactivo;
    }

    return id.toString().contains(normalizedQuery) ||
        removeDiacritics(nombre.toLowerCase()).contains(normalizedQuery) ||
        removeDiacritics(statusString.toLowerCase()).contains(normalizedQuery);
  }
}

/// Función utilitaria para quitar tildes y normalizar texto
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
