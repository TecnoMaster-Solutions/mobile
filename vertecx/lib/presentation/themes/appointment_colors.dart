import 'package:flutter/material.dart';

/// Colores de estados de citas
class AppointmentColors {
  static Map<String, Map<String, dynamic>> estadoStyles = {
    "Finalizado": {
      "text": const Color(0xFF168700),
      "bg": const Color(0xFFD2F5D3).withOpacity(1.0),
    },
    "Pendiente": {
      "text": const Color(0xFFE1B954),
      "bg": const Color(0xFFE6C97F).withOpacity(0.54),
    },
    "Cancelado": {
      "text": const Color(0xFF034A21),
      "bg": const Color(0xFFC3E6D2).withOpacity(0.9),
    },
    "En-proceso": {
      "text": const Color(0xFF2781FF),
      "bg": const Color(0xFF2781FF).withOpacity(0.37),
    },
    "Cerrado": {
      "text": const Color(0xFF000000),
      "bg": const Color(0xFF000000).withOpacity(0.43),
    },
    "Reprogramada": {
      "text": const Color(0xFF6A0DAD),
      "bg": const Color(0xFF6A0DAD).withOpacity(0.48),
    },
    "Agendada": {
      "text": const Color(0xFF00695C),
      "bg": const Color(0xFFB2DFDB).withOpacity(0.9),
    },
    "agendada": {
      "text": const Color(0xFF00695C),
      "bg": const Color(0xFFB2DFDB).withOpacity(0.9),
    },
  };

  /// Colores por tipo de cita
  static Map<String, Color> tipoCitaColors = {
    "solicitud": const Color(0xFF04652C),
    "ejecucion": const Color(0xFF06A646),
    "garantia": const Color(0xFF058A3C),
    "orden": const Color(0xFF2A9781),
  };
}
