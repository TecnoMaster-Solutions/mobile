import 'dart:math';

import 'package:vertecx/data/models/appointments/appointment_model.dart';

final List<String> months = [
  "Enero",
  "Febrero",
  "Marzo",
  "Abril",
  "Mayo",
  "Junio",
  "Julio",
  "Agosto",
  "Septiembre",
  "Octubre",
  "Noviembre",
  "Diciembre",
];

final List<AppointmentEvent> mockAppointments = [
  AppointmentEvent(
    id: 1,
    horaInicio: "09:00",
    horaFin: "10:00",
    dia: 15,
    mes: 10,
    anio: 2025,
    orden: Orden(
      id: "SOL-001",
      tipoServicio: "Mantenimiento",
      tipoMantenimiento: "Preventivo",
      monto: "\$100.000 COP",
      nombreCliente: "Juan Pérez",
      direccion: "Calle 123 #45-67",
      tecnicos: [Technician(titulo: "Tec. Redes", nombre: "Carlos López")],
      descripcion: "Mantenimiento de router y switches.",
      serviceRequestId: 5,
    ),
    observaciones: "Cliente requiere mantenimiento trimestral.",
    estado: "Pendiente",
    subestado: "Normal",
    tipoCita: "solicitud",
  ),

  AppointmentEvent(
    id: 2,
    horaInicio: "14:00",
    horaFin: "16:00",
    dia: 20,
    mes: 10,
    anio: 2025,
    orden: Orden(
      id: "ORD-001",
      tipoServicio: "Instalación",
      monto: "\$${(500000 + Random().nextInt(500000))} COP",
      nombreCliente: "Empresa XYZ",
      direccion: "Av. Principal #100",
      tecnicos: [
        Technician(titulo: "Ing. Sistemas", nombre: "Ana Torres"),
        Technician(titulo: "Tec. Soporte", nombre: "Luis Martínez"),
      ],
      descripcion: "Instalación de servidor principal.",
      servicio: "Instalación de servidor",
      materiales: [
        MaterialItem(nombre: "Servidor HP ProLiant", cantidad: 1),
        MaterialItem(nombre: "Cable de red Cat6", cantidad: 20),
      ],
      orderServiceId: 7,
    ),
    observaciones: "Instalación en centro de datos.",
    estado: "En-proceso",
    subestado: "Normal",
    tipoCita: "ejecucion",
  ),

  AppointmentEvent(
    id: 3,
    horaInicio: "11:00",
    horaFin: "12:30",
    dia: 25,
    mes: 10,
    anio: 2025,
    orden: Orden(
      id: "ORD-002",
      tipoServicio: "Mantenimiento",
      tipoMantenimiento: "Correctivo",
      monto: "\$${(200000 + Random().nextInt(300000))} COP",
      nombreCliente: "María Gómez",
      direccion: "Carrera 50 #20-15",
      tecnicos: [
        Technician(titulo: "Tec. Electricista", nombre: "Pedro Sánchez"),
      ],
      descripcion: "Cambio de cámara dañada.",
      servicio: "Garantía de cámaras de seguridad",
      materiales: [MaterialItem(nombre: "Cámara Hikvision", cantidad: 1)],
      orderServiceId: 8,
    ),
    observaciones: "Equipo presentaba fallas en imagen.",
    estado: "Finalizado",
    subestado: "Normal",
    tipoCita: "garantia",
  ),
];
