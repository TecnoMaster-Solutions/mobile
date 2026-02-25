import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vertecx/core/session_context.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:vertecx/data/models/appointments/appointment_model.dart';
import 'package:vertecx/data/repositories/appointmentRepositories/bloc/calendar_bloc.dart';
import 'package:vertecx/data/repositories/appointmentRepositories/bloc/calendar_event.dart';
import 'package:vertecx/data/repositories/appointmentRepositories/bloc/calendar_state.dart';
import 'package:vertecx/presentation/widgets/appointmentsWidgets/appointment_card.dart';
import 'package:vertecx/presentation/widgets/appointmentsWidgets/calendar_constants.dart';
import 'package:vertecx/presentation/widgets/appointmentsWidgets/calendar_header.dart';
import 'package:vertecx/presentation/widgets/navigationWidgets/app_top_bar.dart';
import 'package:vertecx/presentation/widgets/navigationWidgets/side_menu_panel.dart';
import 'package:vertecx/presentation/routes/app_routes.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final String _searchQuery = '';
  Map<DateTime, List<AppointmentEvent>> _eventsByDayCache = {};
  List<String> _permissions = const <String>[];

  void _loadMonthData() {
    final bloc = context.read<CalendarBloc>();
    bloc.add(
      LoadAppointmentsForMonth(DateTime(_focusedDay.year, _focusedDay.month)),
    );
    if (_selectedDay != null) {
      bloc.add(LoadAppointmentsForDay(_selectedDay!));
    }
  }

  void _updateEventsCache(Map<DateTime, List<AppointmentEvent>> map) {
    if (!mapEquals(_eventsByDayCache, map)) {
      setState(() {
        _eventsByDayCache = Map.from(map);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<CalendarBloc>();
      bloc.add(
        LoadAppointmentsForMonth(DateTime(_focusedDay.year, _focusedDay.month)),
      );
      bloc.add(LoadAppointmentsForDay(_focusedDay));
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is List<String>) {
      _permissions = args;
      SessionContext.permissions = args;
      return;
    }
    _permissions = SessionContext.permissions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'Citas', showMenu: true),
      drawer: Drawer(
        backgroundColor: Colors.transparent,
        child: SideMenuPanel(
          permissions: _permissions,
          onClose: () => Navigator.of(context).maybePop(),
          onLogout: () {
            Navigator.of(context).maybePop();
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.login,
              (route) => false,
            );
          },
        ),
      ),
      backgroundColor: const Color(0xFFE8E8E8),
      body: BlocListener<CalendarBloc, CalendarState>(
            listener: (context, state) {
              if (state is CalendarLoaded) {
                _updateEventsCache(state.appointmentsByDay);
              } else if (state is CalendarMonthLoaded) {
                _updateEventsCache(state.appointmentsByDay);
              }
            },
            child: BlocBuilder<CalendarBloc, CalendarState>(
              builder: (context, state) {
                final stateMap = state is CalendarLoaded
                    ? state.appointmentsByDay
                    : state is CalendarMonthLoaded
                        ? state.appointmentsByDay
                        : null;
                final appointmentsByDay = stateMap ??
                    (_eventsByDayCache.isNotEmpty ? _eventsByDayCache : {});
                final dayAppointments = state is CalendarLoaded
                    ? state.appointments
                    : [];
                late final Widget appointmentsSection;

                if (state is CalendarLoading) {
                  appointmentsSection = const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is CalendarError) {
                  appointmentsSection = Center(child: Text(state.message));
                } else {
                  final filtered = dayAppointments.where((cita) {
                    return cita.orden.tipoServicio.toLowerCase().contains(
                          _searchQuery,
                        ) ||
                        cita.orden.descripcion.toLowerCase().contains(
                          _searchQuery,
                        ) ||
                        cita.orden.tecnicos
                            .map((t) => t.nombre.toLowerCase())
                            .join(' ')
                            .contains(_searchQuery);
                  }).toList();

                  if (filtered.isEmpty) {
                    appointmentsSection = const Center(
                      child: Text("No hay citas para este dÃ­a"),
                    );
                  } else {
                    appointmentsSection = ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) =>
                          AppointmentCard(cita: filtered[index]),
                    );
                  }
                }

                return Column(
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F4F4),
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          const BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.3),
                            blurRadius: 3,
                            offset: const Offset(1, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          CalendarHeader(
                            focusedDay: _focusedDay,
                            monthNames: calendarMonthNames,
                            onPrevious: () {
                              final newFocused = DateTime(
                                _focusedDay.year,
                                _focusedDay.month - 1,
                                _focusedDay.day,
                              );
                              setState(() {
                                _focusedDay = newFocused;
                                _selectedDay = newFocused;
                              });
                              _loadMonthData();
                            },
                            onNext: () {
                              final newFocused = DateTime(
                                _focusedDay.year,
                                _focusedDay.month + 1,
                                _focusedDay.day,
                              );
                              setState(() {
                                _focusedDay = newFocused;
                                _selectedDay = newFocused;
                              });
                              _loadMonthData();
                            },
                          ),
                          const SizedBox(height: 15),
                          TableCalendar(
                            firstDay: DateTime.utc(2020, 1, 1),
                            lastDay: DateTime.utc(2030, 12, 31),
                            focusedDay: _focusedDay,
                            selectedDayPredicate: (day) =>
                                isSameDay(_selectedDay, day),
                            calendarFormat: CalendarFormat.month,
                            startingDayOfWeek: StartingDayOfWeek.monday,
                            locale: "es_ES",
                            headerVisible: false,
                            daysOfWeekHeight: 45,
                            calendarStyle: const CalendarStyle(
                              todayDecoration: BoxDecoration(
                                color: Color(0xFFFFD6D6),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(6)),
                              ),
                              selectedDecoration: BoxDecoration(
                                color: Color(0xFFB20000),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(6)),
                              ),
                            ),
                            daysOfWeekStyle: const DaysOfWeekStyle(
                              weekdayStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: Colors.black,
                              ),
                              weekendStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: Colors.black,
                              ),
                            ),
                            calendarBuilders: CalendarBuilders(
                              defaultBuilder: (context, day, focusedDay) {
                                final hasAppointment =
                                    appointmentsByDay.keys.any(
                                  (fecha) => isSameDay(fecha, day),
                                );
                                return Container(
                                  width: 56,
                                  height: 40,
                                  margin: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: hasAppointment
                                        ? Border.all(
                                            color: const Color(0xFFCC0000),
                                            width: 3,
                                          )
                                        : null,
                                    boxShadow: [
                                      const BoxShadow(
                                        color: Color.fromRGBO(0, 0, 0, 0.08),
                                        blurRadius: 3,
                                        offset: const Offset(1, 1),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${day.day}',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            onDaySelected: (selectedDay, focusedDay) {
                              setState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusedDay;
                              });
                              context.read<CalendarBloc>().add(
                                LoadAppointmentsForDay(selectedDay),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(child: appointmentsSection),
                  ],
                );
              },
            ),
          ),
    );
  }
}
