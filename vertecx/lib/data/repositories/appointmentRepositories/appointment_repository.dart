import 'package:intl/intl.dart';
import 'package:vertecx/data/mocks/appointments_mock_data.dart';
import 'package:vertecx/data/models/appointments/appointment_model.dart';
import 'package:vertecx/data/models/orderServices/order_service_models.dart';
import 'package:vertecx/data/models/request/request_model.dart';
import 'package:vertecx/data/repositories/orderServices/order_repository.dart';
import 'package:vertecx/data/repositories/request/request_repository.dart';

class AppointmentRepository {
  AppointmentRepository({
    OrderRepository? orderRepository,
    RequestsRepository? requestRepository,
  }) : _orderRepository = orderRepository ?? OrderRepository(),
       _requestRepository = requestRepository ?? RequestsRepository();

  final OrderRepository _orderRepository;
  final RequestsRepository _requestRepository;
  List<AppointmentEvent>? _cache;

  Future<List<AppointmentEvent>> _loadAppointments() async {
    if (_cache != null) return _cache!;
    try {
      final orders = await _orderRepository.getAll();
      final requests = await _requestRepository.getAll();
      final mapped = <AppointmentEvent>[];

      mapped.addAll(orders.map(_toAppointmentFromOrder));
      mapped.addAll(requests.map(_toAppointmentFromRequest));

      _cache = mapped.isEmpty ? mockAppointments : mapped;
    } catch (_) {
      _cache = mockAppointments;
    }

    return _cache!;
  }

  Future<List<AppointmentEvent>> getAllAppointments() async {
    return _loadAppointments();
  }

  Future<List<AppointmentEvent>> getAppointmentsForDay(DateTime date) async {
    final all = await _loadAppointments();
    return all
        .where(
          (cita) =>
              cita.dia == date.day &&
              cita.mes == date.month &&
              cita.anio == date.year,
        )
        .toList();
  }

  Future<Map<DateTime, List<AppointmentEvent>>> getAppointmentsForMonth(
    DateTime month,
  ) async {
    final all = await _loadAppointments();
    final Map<DateTime, List<AppointmentEvent>> citasPorDia = {};

    for (final cita in all) {
      final fecha = DateTime(cita.anio, cita.mes, cita.dia);
      if (fecha.year == month.year && fecha.month == month.month) {
        citasPorDia.putIfAbsent(fecha, () => []);
        citasPorDia[fecha]!.add(cita);
      }
    }

    return citasPorDia;
  }

  AppointmentEvent _toAppointmentFromOrder(OrderService order) {
    final start = order.startAt ?? order.fechaCreacion;
    final end = order.endAt ?? order.startAt ?? order.fechaCreacion;
    final inicio = _formatTime(start);
    final fin = _formatTime(
      end.isAfter(start) ? end : start.add(const Duration(hours: 2)),
    );
    final tecnicos = order.technicians
        .map((name) => Technician(titulo: 'Técnico', nombre: name))
        .toList();
    final materials = order.products.map((producto) {
      final productName =
          (producto['product']?['productname'] ?? producto['productname'])
              ?.toString() ??
          'Producto';
      final quantity = producto['cantidad'] is int
          ? producto['cantidad'] as int
          : 1;
      return MaterialItem(nombre: productName, cantidad: quantity);
    }).toList();
    final monto = order.total > 0
        ? _formatCurrency(order.total)
        : 'Valor no registrado';

    final estadoLabel = _translateEstado(order.estadoLabel);

    return AppointmentEvent(
      id: order.id,
      horaInicio: inicio,
      horaFin: fin,
      dia: start.day,
      mes: start.month,
      anio: start.year,
      orden: Orden(
        id: order.id.toString(),
        tipoServicio: order.titulo,
        tipoMantenimiento: (order.serviceType != null &&
                order.serviceType!.trim().isNotEmpty)
            ? order.serviceType
            : (estadoLabel.isNotEmpty ? estadoLabel : null),
        monto: monto,
        nombreCliente: order.cliente,
        direccion: order.client != null
            ? _clienteDireccion(order.client!) ?? ''
            : '',
        tecnicos: tecnicos,
        descripcion: order.description.isNotEmpty
            ? order.description
            : order.titulo,
        servicio: order.titulo,
        materiales: materials.isEmpty ? null : materials,
        serviceRequestId: null,
        orderServiceId: order.id,
      ),
      observaciones: '',
      estado: estadoLabel.isNotEmpty ? estadoLabel : 'Pendiente',
      subestado: estadoLabel.isNotEmpty ? estadoLabel : 'Pendiente',
      tipoCita: 'orden',
    );
  }

  AppointmentEvent _toAppointmentFromRequest(ServiceRequestModel request) {
    final fecha = request.scheduledAt ?? request.createdAt;
    final inicio = _formatTime(fecha);
    final end = request.scheduledEndAt ?? fecha.add(const Duration(hours: 2));
    final fin = _formatTime(end);
    final cliente = request.customerName;
    final direccion = request.direccion ?? '';
    final servicioName =
        (request.service?['name'] ?? request.serviceType)?.toString() ??
        request.serviceType;

    final estadoLabel = _translateEstado(
      (request.state?['name'] ?? 'Pendiente').toString(),
    );

    return AppointmentEvent(
      id: request.serviceRequestId,
      horaInicio: inicio,
      horaFin: fin,
      dia: fecha.day,
      mes: fecha.month,
      anio: fecha.year,
      orden: Orden(
        id: request.serviceRequestId.toString(),
        tipoServicio: servicioName,
        tipoMantenimiento: request.serviceType,
        monto: 'Valor no registrado',
        nombreCliente: cliente,
        direccion: direccion,
        tecnicos: const [],
        descripcion: request.description,
        servicio: servicioName,
        materiales: null,
        serviceRequestId: request.serviceRequestId,
        orderServiceId: null,
      ),
      observaciones: request.description,
      estado: estadoLabel.isNotEmpty ? estadoLabel : 'Pendiente',
      subestado: estadoLabel.isNotEmpty ? estadoLabel : 'Pendiente',
      tipoCita: 'solicitud',
    );
  }

  static String _formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  static String _translateEstado(String raw) {
    final normalized = raw.trim().toLowerCase();
    if (normalized.isEmpty) return '';

    switch (normalized) {
      case 'finished':
      case 'finalizado':
        return 'Finalizado';
      case 'cancel':
      case 'canceled':
      case 'cancelled':
      case 'cancelado':
        return 'Cancelado';
      case 'in process':
      case 'in-process':
      case 'in_process':
      case 'en-proceso':
      case 'en proceso':
        return 'En-proceso';
      case 'pendient':
      case 'pending':
      case 'pendiente':
        return 'Pendiente';
      default:
        return raw;
    }
  }

  static String _formatCurrency(int value) {
    final formatter = NumberFormat.simpleCurrency(
      locale: 'es_CO',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }

  static String? _clienteDireccion(Map<String, dynamic> client) {
    final city =
        (client['customercity'] ?? client['city'])?.toString().trim() ?? '';
    final zipcode =
        (client['customerzipcode'] ?? client['zipcode'])?.toString().trim() ??
        '';
    final street =
        (client['address'] ?? client['direccion'])?.toString().trim() ?? '';
    final parts = [street, city, zipcode].where((p) => p.isNotEmpty).toList();
    return parts.isEmpty ? null : parts.join(', ');
  }
}
