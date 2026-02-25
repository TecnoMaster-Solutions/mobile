import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vertecx/data/models/appointments/appointment_model.dart';
import 'package:vertecx/data/repositories/appointmentRepositories/appointment_repository.dart';
import 'calendar_event.dart';
import 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  CalendarBloc(this.repository) : super(CalendarInitial()) {
    on<LoadAppointmentsForDay>(_onLoadDay);
    on<LoadAppointmentsForMonth>(_onLoadMonth);
    on<LoadAllAppointments>(_onLoadAll);
    on<UpdateAppointmentStatus>(_onUpdateStatus);
  }

  final AppointmentRepository repository;
  Map<DateTime, List<AppointmentEvent>> _monthCache = {};
  DateTime? _lastLoadedMonth;

  bool _isSameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

  Future<Map<DateTime, List<AppointmentEvent>>> _ensureMonthCache(
    DateTime month,
  ) async {
    final monthKey = DateTime(month.year, month.month);
    if (_lastLoadedMonth != null &&
        _isSameMonth(_lastLoadedMonth!, monthKey) &&
        _monthCache.isNotEmpty) {
      return _monthCache;
    }
    final map = await repository.getAppointmentsForMonth(monthKey);
    _monthCache = map;
    _lastLoadedMonth = monthKey;
    return map;
  }

  Future<void> _onLoadDay(
    LoadAppointmentsForDay event,
    Emitter<CalendarState> emit,
  ) async {
    emit(CalendarLoading());
    try {
      final map = await _ensureMonthCache(event.date);
      final citas = await repository.getAppointmentsForDay(event.date);
      emit(
        CalendarLoaded(
          selectedDate: event.date,
          appointments: citas,
          appointmentsByDay: Map.from(map),
        ),
      );
    } catch (e) {
      emit(CalendarError("Error al cargar las citas: $e"));
    }
  }

  Future<void> _onLoadMonth(
    LoadAppointmentsForMonth event,
    Emitter<CalendarState> emit,
  ) async {
    emit(CalendarLoading());
    try {
      final monthKey = DateTime(event.month.year, event.month.month);
      final map = await repository.getAppointmentsForMonth(monthKey);
      _monthCache = map;
      _lastLoadedMonth = monthKey;
      emit(CalendarMonthLoaded(month: monthKey, appointmentsByDay: map));
    } catch (e) {
      emit(CalendarError("Error al cargar las citas del mes: $e"));
    }
  }

  Future<void> _onLoadAll(
    LoadAllAppointments event,
    Emitter<CalendarState> emit,
  ) async {
    emit(CalendarLoading());
    try {
      final citas = await repository.getAllAppointments();
      emit(AllAppointmentsLoaded(citas));
    } catch (e) {
      emit(CalendarError("Error al cargar todas las citas: $e"));
    }
  }

  void _onUpdateStatus(
    UpdateAppointmentStatus event,
    Emitter<CalendarState> emit,
  ) {
    if (state is CalendarLoaded) {
      final currentState = state as CalendarLoaded;
      final updatedAppointments = currentState.appointments.map((a) {
        if (a.id == event.appointmentId) {
          return AppointmentEvent(
            id: a.id,
            horaInicio: a.horaInicio,
            horaFin: a.horaFin,
            dia: a.dia,
            mes: a.mes,
            anio: a.anio,
            orden: a.orden,
            observaciones: a.observaciones,
            estado: event.newStatus,
            subestado: a.subestado,
            motivoCancelacion: a.motivoCancelacion,
            evidencia: a.evidencia,
            comprobantePago: a.comprobantePago,
            tipoCita: a.tipoCita,
            horaCancelacion: a.horaCancelacion,
          );
        }
        return a;
      }).toList();

      emit(
        CalendarLoaded(
          selectedDate: currentState.selectedDate,
          appointments: updatedAppointments,
          appointmentsByDay: Map.from(currentState.appointmentsByDay),
        ),
      );
    }
  }
}
