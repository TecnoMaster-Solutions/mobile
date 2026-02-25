import 'package:equatable/equatable.dart';

/// Modelo de técnico
class Technician extends Equatable {
  final String titulo;
  final String nombre;

  const Technician({required this.titulo, required this.nombre});

  @override
  List<Object?> get props => [titulo, nombre];
}

/// Modelo de material
class MaterialItem extends Equatable {
  final String nombre;
  final int cantidad;

  const MaterialItem({required this.nombre, required this.cantidad});

  @override
  List<Object?> get props => [nombre, cantidad];
}

/// Modelo de Orden
class Orden extends Equatable {
  final String id;
  final String tipoServicio;
  final String? tipoMantenimiento;
  final String monto;
  final String nombreCliente;
  final String direccion;
  final List<Technician> tecnicos;
  final String descripcion;
  final String? servicio;
  final List<MaterialItem>? materiales;
  final int? serviceRequestId;
  final int? orderServiceId;

  const Orden({
    required this.id,
    required this.tipoServicio,
    this.tipoMantenimiento,
    required this.monto,
    required this.nombreCliente,
    required this.direccion,
    required this.tecnicos,
    required this.descripcion,
    this.servicio,
    this.materiales,
    this.serviceRequestId,
    this.orderServiceId,
  });

  @override
  List<Object?> get props => [
    id,
    tipoServicio,
    tipoMantenimiento,
    monto,
    nombreCliente,
    direccion,
    tecnicos,
    descripcion,
    servicio,
    materiales,
    serviceRequestId,
    orderServiceId,
  ];
}

/// Modelo de AppointmentEvent
class AppointmentEvent extends Equatable {
  final int id;
  final String horaInicio;
  final String horaFin;
  final int dia;
  final int mes;
  final int anio;

  final Orden orden;

  final String observaciones;
  final String estado;
  final String subestado;
  final String? motivoCancelacion;
  final List<String>? evidencia;
  final String? comprobantePago;
  final String tipoCita;
  final String? horaCancelacion;

  const AppointmentEvent({
    required this.id,
    required this.horaInicio,
    required this.horaFin,
    required this.dia,
    required this.mes,
    required this.anio,
    required this.orden,
    required this.observaciones,
    required this.estado,
    required this.subestado,
    this.motivoCancelacion,
    this.evidencia,
    this.comprobantePago,
    required this.tipoCita,
    this.horaCancelacion,
  });

  /// 🔹 Getter para obtener la fecha completa como DateTime
  DateTime get fecha => DateTime(anio, mes, dia);

  @override
  List<Object?> get props => [
    id,
    horaInicio,
    horaFin,
    dia,
    mes,
    anio,
    orden,
    observaciones,
    estado,
    subestado,
    motivoCancelacion,
    evidencia,
    comprobantePago,
    tipoCita,
    horaCancelacion,
  ];
}
