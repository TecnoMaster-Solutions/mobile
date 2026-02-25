import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:vertecx/data/models/appointments/appointment_model.dart';
import 'package:vertecx/data/repositories/appointmentRepositories/bloc/calendar_bloc.dart';
import 'package:vertecx/data/repositories/appointmentRepositories/bloc/calendar_event.dart';
import 'package:vertecx/presentation/helpers/app_dialogs.dart';
import 'package:vertecx/presentation/pages/appointementPage/appointment_detail_page.dart';
import '../../themes/appointment_colors.dart';
import '../../../data/domain/rules/appointment_state_rules.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentEvent cita;
  final bool esTecnico;

  const AppointmentCard({super.key, required this.cita, this.esTecnico = false});

  String getDiaSemana(DateTime fecha) {
    return DateFormat.EEEE("es_ES").format(fecha);
  }

  String getTecnicosTexto() {
    final tecnicos = cita.orden.tecnicos;
    if (tecnicos.isEmpty) return "Sin técnico";

    if (tecnicos.length == 1) {
      return tecnicos.first.nombre;
    } else {
      final primero = tecnicos.first.nombre;
      final restantes = tecnicos.length - 1;
      return "$primero - $restantes técnicos";
    }
  }

  @override
  Widget build(BuildContext context) {
    final fecha = DateTime(cita.anio, cita.mes, cita.dia);
    final diaSemana = getDiaSemana(fecha);
    final estado =
        AppointmentColors.estadoStyles[cita.estado] ??
        AppointmentColors.estadoStyles["Pendiente"]!;
    final tipoCitaColor =
        AppointmentColors.tipoCitaColors[cita.tipoCita.toLowerCase()] ??
        Colors.black;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AppointmentDetailPage(cita: cita)),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(16),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //Columna izquierda (Día)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    diaSemana,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF797979),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${cita.dia}",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF000000),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cita.horaInicio,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF797979),
                    ),
                  ),
                ],
              ),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                width: 3,
                color: const Color(0xFFE8E8E8),
              ),

              // Contenido principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            cita.orden.tipoServicio,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFB20000),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            cita.tipoCita,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: tipoCitaColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Tipo de mantenimiento
                    if (cita.orden.tipoMantenimiento != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          cita.orden.tipoMantenimiento!,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ),

                    const SizedBox(height: 4),

                    // Descripción
                    Text(
                      cita.orden.descripcion,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF797979),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Técnico
                    Row(
                      children: [
                        const Icon(
                          Icons.person,
                          size: 16,
                          color: Color(0xFF797979),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            getTecnicosTexto(),
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF797979),
                            ),
                          ),
                        ),

                        //Estado interactivo con confirmación
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            AppDialogs.showConfirmChangeStatus(
                              context: context,
                              title: "Cambiar estado",
                              message:
                                  "¿Seguro que deseas cambiar el estado a $value?",
                              onConfirm: () {
                                context.read<CalendarBloc>().add(
                                  UpdateAppointmentStatus(
                                    appointmentId: cita.id,
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
                              cita.estado,
                              esTecnico: esTecnico,
                            );
                            return opciones
                                .map(
                                  (e) =>
                                      PopupMenuItem(value: e, child: Text(e)),
                                )
                                .toList();
                          },
                          enabled: getOpcionesEstado(
                            cita.estado,
                            esTecnico: true,
                          ).isNotEmpty,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: estado["bg"],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              cita.estado,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: estado["text"],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
