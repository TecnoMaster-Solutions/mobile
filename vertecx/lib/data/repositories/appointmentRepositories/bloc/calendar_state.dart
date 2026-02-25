import 'package:equatable/equatable.dart';
import 'package:vertecx/data/models/appointments/appointment_model.dart';

abstract class CalendarState extends Equatable {
  const CalendarState();

  @override
  List<Object?> get props => [];
}

class CalendarInitial extends CalendarState {}

class CalendarLoading extends CalendarState {}

class CalendarLoaded extends CalendarState {
  final DateTime selectedDate;
  final List<AppointmentEvent> appointments;
  final Map<DateTime, List<AppointmentEvent>> appointmentsByDay;

  const CalendarLoaded({
    required this.selectedDate,
    required this.appointments,
    required this.appointmentsByDay,
  });

  @override
  List<Object?> get props => [selectedDate, appointments, appointmentsByDay];
}

class CalendarMonthLoaded extends CalendarState {
  final DateTime month;
  final Map<DateTime, List<AppointmentEvent>> appointmentsByDay;

  const CalendarMonthLoaded({
    required this.month,
    required this.appointmentsByDay,
  });

  @override
  List<Object?> get props => [month, appointmentsByDay];
}

class CalendarError extends CalendarState {
  final String message;

  const CalendarError(this.message);

  @override
  List<Object?> get props => [message];
}

class AllAppointmentsLoaded extends CalendarState {
  final List<AppointmentEvent> appointments;

  const AllAppointmentsLoaded(this.appointments);

  @override
  List<Object?> get props => [appointments];
}
