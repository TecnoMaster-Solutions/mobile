import 'package:equatable/equatable.dart';

abstract class CalendarEvent extends Equatable {
  const CalendarEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar citas para un día específico
class LoadAppointmentsForDay extends CalendarEvent {
  final DateTime date;

  const LoadAppointmentsForDay(this.date);

  @override
  List<Object?> get props => [date];
}

/// Cargar todas las citas del mes
class LoadAppointmentsForMonth extends CalendarEvent {
  final DateTime month;

  const LoadAppointmentsForMonth(this.month);

  @override
  List<Object?> get props => [month];
}

class UpdateAppointmentStatus extends CalendarEvent {
  final int appointmentId;
  final String newStatus;

  const UpdateAppointmentStatus({
    required this.appointmentId,
    required this.newStatus,
  });

  @override
  List<Object?> get props => [appointmentId, newStatus];
}

class LoadAllAppointments extends CalendarEvent {}


