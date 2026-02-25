enum OrderServiceStatus { pendiente, enProgreso, completada, anulada }

class OrderService {
  final int id;
  final String titulo;
  final String tecnico;
  final String cliente;
  final DateTime fechaCreacion;
  final OrderServiceStatus estado;

  const OrderService({
    required this.id,
    required this.titulo,
    required this.tecnico,
    required this.cliente,
    required this.fechaCreacion,
    required this.estado,
  });
}
