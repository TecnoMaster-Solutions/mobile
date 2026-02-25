enum ClientStatus { activo, inactivo }

enum ClientRole { cliente, tecnico, administrador }

class ClientModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final ClientStatus status;
  final String? imagePath;
  final ClientRole role;
  ClientModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.status,
    this.imagePath,
    this.role = ClientRole.cliente,
  });

  // Método de utilidad para mostrar el estado como texto
  String get statusString =>
      status == ClientStatus.activo ? "Activo" : "Inactivo";

  // Role en string
  String get roleString {
    switch (role) {
      case ClientRole.cliente:
        return "Cliente";
      case ClientRole.tecnico:
        return "Técnico";
      case ClientRole.administrador:
        return "Administrador";
    }
  }

  // Método para cambiar el estado
  ClientModel toggleStatus() {
    return ClientModel(
      id: id,
      name: name,
      phone: phone,
      email: email,
      status: status == ClientStatus.activo
          ? ClientStatus.inactivo
          : ClientStatus.activo,
      imagePath: imagePath,
    );
  }
}
