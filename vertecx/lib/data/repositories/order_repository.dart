import 'package:vertecx/data/models/order_service_models.dart';

class OrderRepository {
  Future<List<OrderService>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      OrderService(
        id: 1001,
        titulo: 'Instalación de cámara IP Hikvision DS-2CD2043G2',
        tecnico: 'Luis Andrade',
        cliente: 'Ferretería San Miguel',
        fechaCreacion: DateTime(2025, 9, 12, 10, 30),
        estado: OrderServiceStatus.completada,
      ),
      OrderService(
        id: 1002,
        titulo: 'Mantenimiento preventivo DVR Dahua XVR5108',
        tecnico: 'María Quispe',
        cliente: 'Colegio Santa Rosa',
        fechaCreacion: DateTime(2025, 9, 14, 9, 10),
        estado: OrderServiceStatus.pendiente,
      ),
      OrderService(
        id: 1003,
        titulo: 'Reemplazo de disco 2TB en NVR Uniview',
        tecnico: 'Diego Velasco',
        cliente: 'Clínica Los Álamos',
        fechaCreacion: DateTime(2025, 9, 15, 16, 5),
        estado: OrderServiceStatus.enProgreso,
      ),
      OrderService(
        id: 1004,
        titulo: 'Reconfiguración de red para 12 cámaras PoE',
        tecnico: 'Sofía Rojas',
        cliente: 'Supermercado La Colmena',
        fechaCreacion: DateTime(2025, 9, 16, 11, 45),
        estado: OrderServiceStatus.completada,
      ),
      OrderService(
        id: 1005,
        titulo: 'Diagnóstico: pérdida de video en canal 6',
        tecnico: 'Jorge Lema',
        cliente: 'Hotel Mirador Andino',
        fechaCreacion: DateTime(2025, 9, 17, 14, 20),
        estado: OrderServiceStatus.pendiente,
      ),
      OrderService(
        id: 1006,
        titulo: 'Ajuste de ángulos y enfoque en domos PTZ',
        tecnico: 'Valeria Núñez',
        cliente: 'Parque Industrial Norte',
        fechaCreacion: DateTime(2025, 9, 18, 9, 0),
        estado: OrderServiceStatus.enProgreso,
      ),
      OrderService(
        id: 1007,
        titulo: 'Cambio de fuente 12V/5A y conector BNC',
        tecnico: 'Carlos Ibáñez',
        cliente: 'Restaurante El Puerto',
        fechaCreacion: DateTime(2025, 9, 18, 15, 40),
        estado: OrderServiceStatus.anulada,
      ),
      OrderService(
        id: 1008,
        titulo: 'Integración NVR con app móvil y P2P',
        tecnico: 'María Quispe',
        cliente: 'Oficinas CentralTech',
        fechaCreacion: DateTime(2025, 9, 19, 10, 15),
        estado: OrderServiceStatus.completada,
      ),
      OrderService(
        id: 1009,
        titulo: 'Tendido de cable UTP Cat6 y certificación',
        tecnico: 'Luis Andrade',
        cliente: 'Bodega Santa Ana',
        fechaCreacion: DateTime(2025, 9, 19, 13, 55),
        estado: OrderServiceStatus.pendiente,
      ),
      OrderService(
        id: 1010,
        titulo: 'Actualización de firmware en cámaras Uniview',
        tecnico: 'Sofía Rojas',
        cliente: 'Edificio Torre Norte',
        fechaCreacion: DateTime(2025, 9, 20, 8, 30),
        estado: OrderServiceStatus.enProgreso,
      ),
    ];
  }
}
