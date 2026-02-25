import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:vertecx/data/models/appointments/appointment_model.dart';
import 'package:vertecx/data/models/orderServices/order_service_history_model.dart';
import 'package:vertecx/data/models/orderServices/order_service_models.dart';
import 'package:vertecx/data/models/request/request_model.dart';
import 'package:vertecx/data/repositories/appointmentRepositories/bloc/calendar_bloc.dart';
import 'package:vertecx/data/repositories/appointmentRepositories/bloc/calendar_event.dart';
import 'package:vertecx/data/repositories/appointmentRepositories/bloc/calendar_state.dart';
import 'package:vertecx/data/repositories/orderServices/order_repository.dart';
import 'package:vertecx/data/repositories/request/request_repository.dart';
import 'package:vertecx/presentation/helpers/app_dialogs.dart';
import '../../themes/appointment_colors.dart';
import '../../../data/domain/rules/appointment_state_rules.dart';

enum AppointmentDetailSource { serviceRequest, orderService, fallback }

class AppointmentServiceDetail extends StatefulWidget {
  final AppointmentEvent cita;
  final Future<AppointmentDetailData> detailFuture;

  const AppointmentServiceDetail({
    super.key,
    required this.cita,
    required this.detailFuture,
  });

  @override
  State<AppointmentServiceDetail> createState() =>
      _AppointmentServiceDetailState();
}

class _AppointmentServiceDetailState extends State<AppointmentServiceDetail> {
  String formatFecha(DateTime fecha, String inicio, String fin) {
    final formato = DateFormat("dd/MM/yyyy");
    return "${formato.format(fecha)}, $inicio - $fin";
  }

  Widget _buildRow(
    String label,
    String value, {
    Color color = const Color(0xFF666666),
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF000000),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: color)),
          ),
        ],
      ),
    );
  }

  String _maintenanceLabel(String? value) {
    if (value == null) return "Mantenimiento:";
    final normalized = value.toLowerCase();
    if (normalized.contains('instal')) {
      return "Instalacion:";
    }
    if (normalized.contains('preventivo') ||
        normalized.contains('correctivo') ||
        normalized.contains('mantenimiento')) {
      return "Mantenimiento:";
    }
    return "Mantenimiento:";
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarBloc, CalendarState>(
      builder: (context, state) {
        AppointmentEvent currentCita = widget.cita;

        if (state is CalendarLoaded) {
          final updated = state.appointments.firstWhere(
            (a) => a.id == widget.cita.id,
            orElse: () => widget.cita,
          );
          currentCita = updated;
        }

      final source = resolveDetailSource(currentCita);
      final typeLabel = typeLabelForSource(source);
      final fallbackIdLabel = sourceIdLabel(source);
      final detailId = resolveDetailId(currentCita, source);
      final fallbackId =
          formatFallbackId(currentCita, source, detailId: detailId);
        final fecha = DateTime(
          currentCita.anio,
          currentCita.mes,
          currentCita.dia,
        );
        final estado =
            AppointmentColors.estadoStyles[currentCita.estado] ??
            AppointmentColors.estadoStyles["Pendiente"]!;

        return Container(
          margin: const EdgeInsets.only(top: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFFB20000),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  AppDialogs.showConfirmChangeStatus(
                                    context: context,
                                    title: "Cambiar estado",
                                    message:
                                        "?Seguro que deseas cambiar el estado a $value?",
                                    onConfirm: () {
                                      context.read<CalendarBloc>().add(
                                        UpdateAppointmentStatus(
                                          appointmentId: currentCita.id,
                                          newStatus: value,
                                        ),
                                      );

                                      AppDialogs.showSuccessMessage(
                                        context,
                                        "Estado cambiado a $value",
                                      );
                                    },
                                  );
                                },
                                itemBuilder: (context) {
                                  final opciones = getOpcionesEstado(
                                    currentCita.estado,
                                  );
                                  return opciones
                                      .map(
                                        (e) => PopupMenuItem(
                                          value: e,
                                          child: Text(e),
                                        ),
                                      )
                                      .toList();
                                },
                                enabled: getOpcionesEstado(
                                  currentCita.estado,
                                ).isNotEmpty,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: estado["bg"],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    currentCita.estado,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: estado["text"],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    typeLabel,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: Color(0xFFC20000),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          formatFecha(
                            fecha,
                            currentCita.horaInicio,
                            currentCita.horaFin,
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF000000),
                          ),
                        ),
                        const Divider(
                          height: 24,
                          thickness: 1,
                          color: Color(0xFFE8E8E8),
                        ),
                        const Text(
                          "Detalle del servicio",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF000000),
                          ),
                        ),
                        const SizedBox(height: 10),
                        FutureBuilder<AppointmentDetailData>(
                          future: widget.detailFuture,
                          builder: (context, snapshot) {
                            final detail =
                                snapshot.data ??
                                AppointmentDetailData.fromFallback(
                                  currentCita,
                                  idLabel: fallbackIdLabel,
                                  idOverride: fallbackId,
                                );
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildRow(detail.idLabel, detail.id),
                                _buildRow("Cliente:", detail.cliente),
                                _buildRow("Dirección:", detail.direccion),
                                _buildRow("Servicio:", detail.servicio),
                                if (detail.mantenimiento != null &&
                                    detail.mantenimiento!.isNotEmpty)
                                  _buildRow(
                                    _maintenanceLabel(detail.mantenimiento),
                                    detail.mantenimiento!,
                                  ),
                                _buildRow("Descripción:", detail.descripcion),
                                const SizedBox(height: 10),
                                Text(
                                  "Monto: ${detail.monto}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFC20000),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AppointmentDetailData {
  final String id;
  final String cliente;
  final String direccion;
  final String servicio;
  final String? mantenimiento;
  final String descripcion;
  final String monto;
  final String idLabel;
  final List<OrderServiceHistoryEntry>? history;

  const AppointmentDetailData({
    required this.id,
    required this.cliente,
    required this.direccion,
    required this.servicio,
    this.mantenimiento,
    required this.descripcion,
    required this.monto,
    required this.idLabel,
    this.history,
  });

  factory AppointmentDetailData.fromFallback(
    AppointmentEvent cita, {
    String idLabel = "ID de orden:",
    String? idOverride,
    List<OrderServiceHistoryEntry>? history,
  }) {
    return AppointmentDetailData(
      id: idOverride ?? cita.orden.id,
      cliente: cita.orden.nombreCliente,
      direccion: cita.orden.direccion,
      servicio: cita.orden.servicio ?? cita.orden.tipoServicio,
      mantenimiento: cita.orden.tipoMantenimiento,
      descripcion: cita.orden.descripcion,
      monto: cita.orden.monto,
      idLabel: idLabel,
      history: history,
    );
  }

  factory AppointmentDetailData.fromServiceRequest(
    ServiceRequestModel request,
    AppointmentEvent cita,
  ) {
    final serviceName = (request.service?['name'] ?? request.serviceType ?? '')
        .toString()
        .trim();
    final servicio = serviceName.isEmpty
        ? cita.orden.servicio ?? request.serviceType
        : serviceName;
    final clientName = request.customerName;
    final direccion = (request.direccion ?? '').isNotEmpty
        ? request.direccion!
        : cita.orden.direccion;
    final mantenimiento = request.serviceType;
    final descripcion = request.description.isNotEmpty
        ? request.description
        : cita.orden.descripcion;
    const monto = 'Valor no registrado';

    return AppointmentDetailData(
      id: formatServiceRequestCode(request.serviceRequestId),
      cliente: clientName,
      direccion: direccion,
      servicio: servicio,
      mantenimiento: mantenimiento,
      descripcion: descripcion,
      monto: monto,
      idLabel: "ID de solicitud:",
      history: null,
    );
  }

  factory AppointmentDetailData.fromOrder(
    OrderService order,
    AppointmentEvent cita, {
    List<OrderServiceHistoryEntry>? history,
  }) {
    final servicio = order.titulo.isNotEmpty
        ? order.titulo
        : cita.orden.servicio ?? order.description;
    final descripcion = order.description.isNotEmpty
        ? order.description
        : cita.orden.descripcion;
    final client = order.client;
    final direccion = _clienteDireccion(client) ?? cita.orden.direccion;
    final cliente = order.cliente.isNotEmpty
        ? order.cliente
        : _clienteNombre(client) ?? cita.orden.nombreCliente;
    final mantenimiento = (order.serviceType != null &&
            order.serviceType!.trim().isNotEmpty)
        ? order.serviceType
        : order.estadoLabel;
    final monto = _formatCurrency(order.total);

    return AppointmentDetailData(
      id: formatOrderCode(order.id),
      cliente: cliente,
      direccion: direccion,
      servicio: servicio,
      mantenimiento: mantenimiento,
      descripcion: descripcion,
      monto: monto,
      idLabel: "ID de orden:",
      history: history ?? order.history,
    );
  }

  AppointmentDetailData copyWith({
    List<OrderServiceHistoryEntry>? history,
  }) {
    return AppointmentDetailData(
      id: id,
      cliente: cliente,
      direccion: direccion,
      servicio: servicio,
      mantenimiento: mantenimiento,
      descripcion: descripcion,
      monto: monto,
      idLabel: idLabel,
      history: history ?? this.history,
    );
  }

  static String? _clienteDireccion(Map<String, dynamic>? client) {
    if (client == null) return null;
    final parts = <String>[];
    final city = (client['customercity'] ?? client['city'])?.toString().trim();
    final zipcode =
        (client['customerzipcode'] ?? client['zip'] ?? client['postalcode'])
            ?.toString()
            .trim();
    if (city != null && city.isNotEmpty) parts.add(city);
    if (zipcode != null && zipcode.isNotEmpty) parts.add(zipcode);
    return parts.isNotEmpty ? parts.join(', ') : null;
  }

  static String? _clienteNombre(Map<String, dynamic>? client) {
    if (client == null) return null;
    final users = client['users'];
    if (users is Map<String, dynamic>) {
      final first =
          (users['name'] ?? users['firstname'] ?? users['firstName'])
              ?.toString()
              .trim() ??
          '';
      final last =
          (users['lastname'] ?? users['lastName'])?.toString().trim() ?? '';
      final joined = [first, last].where((value) => value.isNotEmpty).join(' ');
      if (joined.isNotEmpty) return joined;
    }
    return null;
  }

  static String _formatCurrency(int value) {
    if (value <= 0) return 'Valor no registrado';
    final formatter = NumberFormat.simpleCurrency(
      locale: 'es_CO',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }
}

String formatServiceRequestCode(int id) =>
    'SRV-${id.toString().padLeft(6, '0')}';

String formatOrderCode(int id) => 'OS-${id.toString().padLeft(6, '0')}';

AppointmentDetailSource resolveDetailSource(AppointmentEvent cita) {
  final tipo = cita.tipoCita.toLowerCase();
  if (cita.orden.serviceRequestId != null ||
      tipo.contains('solicitud') ||
      tipo.contains('request')) {
    return AppointmentDetailSource.serviceRequest;
  }
  if (cita.orden.orderServiceId != null ||
      tipo.contains('orden') ||
      tipo.contains('ejecucion')) {
    return AppointmentDetailSource.orderService;
  }
  return AppointmentDetailSource.fallback;
}

int? resolveDetailId(AppointmentEvent cita, AppointmentDetailSource source) {
  switch (source) {
    case AppointmentDetailSource.serviceRequest:
      return cita.orden.serviceRequestId ?? extractDigits(cita.orden.id);
    case AppointmentDetailSource.orderService:
      return cita.orden.orderServiceId ?? extractDigits(cita.orden.id);
    case AppointmentDetailSource.fallback:
      return null;
  }
}

String sourceIdLabel(AppointmentDetailSource source) {
  switch (source) {
    case AppointmentDetailSource.serviceRequest:
      return "ID de solicitud:";
    case AppointmentDetailSource.orderService:
    case AppointmentDetailSource.fallback:
      return "ID de orden:";
  }
}

String typeLabelForSource(AppointmentDetailSource source) {
  switch (source) {
    case AppointmentDetailSource.serviceRequest:
      return "Solicitud de servicio";
    case AppointmentDetailSource.orderService:
      return "Orden de servicio";
    case AppointmentDetailSource.fallback:
      return "Orden de servicio";
  }
}

String formatFallbackId(
  AppointmentEvent cita,
  AppointmentDetailSource source, {
  int? detailId,
}) {
  final digits = extractDigits(cita.orden.id);
  switch (source) {
    case AppointmentDetailSource.serviceRequest:
      final idValue = detailId ?? cita.orden.serviceRequestId ?? digits;
      return idValue != null
        ? formatServiceRequestCode(idValue)
        : cita.orden.id;
    case AppointmentDetailSource.orderService:
      final idValue = detailId ?? cita.orden.orderServiceId ?? digits;
      return idValue != null ? formatOrderCode(idValue) : cita.orden.id;
    case AppointmentDetailSource.fallback:
      return cita.orden.id;
  }
}

int? extractDigits(String raw) {
  final matches = RegExp(r'\d+').allMatches(raw);
  final joined = matches.map((m) => m.group(0)).whereType<String>().join();
  if (joined.isEmpty) return null;
  return int.tryParse(joined);
}

Future<AppointmentDetailData> loadAppointmentDetail(
  AppointmentEvent cita,
) async {
  final source = resolveDetailSource(cita);
  final idLabel = sourceIdLabel(source);
  final detailId = resolveDetailId(cita, source);
  final fallbackId = formatFallbackId(
    cita,
    source,
    detailId: detailId,
  );
  if (detailId == null || source == AppointmentDetailSource.fallback) {
    return AppointmentDetailData.fromFallback(
      cita,
      idLabel: idLabel,
      idOverride: fallbackId,
    );
  }

  try {
    if (source == AppointmentDetailSource.serviceRequest) {
      final request = await RequestsRepository().getById(detailId);
      return AppointmentDetailData.fromServiceRequest(request, cita);
    }
    final repository = OrderRepository();
    final historyFuture = repository.getHistory(detailId);
    final order = await repository.getById(detailId);
    List<OrderServiceHistoryEntry> history;
    try {
      history = await historyFuture;
    } catch (_) {
      history = order.history;
    }
    return AppointmentDetailData.fromOrder(
      order,
      cita,
      history: history,
    );
  } catch (_) {
    return AppointmentDetailData.fromFallback(
      cita,
      idLabel: idLabel,
      idOverride: fallbackId,
    );
  }
}
