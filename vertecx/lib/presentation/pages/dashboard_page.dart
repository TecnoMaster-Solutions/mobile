import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:vertecx/core/session_context.dart';
import 'package:vertecx/data/models/dashboard/dashboard_models.dart';
import 'package:vertecx/data/repositories/appointmentRepositories/appointment_repository.dart';
import 'package:vertecx/data/repositories/appointmentRepositories/bloc/calendar_bloc.dart';
import 'package:vertecx/data/repositories/appointmentRepositories/bloc/calendar_event.dart';
import 'package:vertecx/data/repositories/appointmentRepositories/bloc/calendar_state.dart';
import 'package:vertecx/data/repositories/dashboard/bloc/dashboard_bloc.dart';
import 'package:vertecx/data/repositories/dashboard/bloc/dashboard_event.dart';
import 'package:vertecx/data/repositories/dashboard/bloc/dashboard_states.dart';
import 'package:vertecx/data/repositories/dashboard/dashboard_repository.dart';
import 'package:vertecx/presentation/widgets/appointmentsWidgets/appointment_card.dart';
import 'package:vertecx/presentation/widgets/dashboardWidgets/dashboardCards_widget.dart';
import 'package:vertecx/presentation/widgets/dashboardWidgets/clients_chart_widget.dart';
import 'package:vertecx/presentation/widgets/dashboardWidgets/graphhStates_widget.dart';
import 'package:vertecx/presentation/widgets/dashboardWidgets/pieChart_widget.dart';
import 'package:vertecx/presentation/widgets/dashboardWidgets/sales_vs_purchases_chart_widget.dart';
import '../widgets/dashboardWidgets/barChart_widget.dart';
import '../widgets/dashboardWidgets/graphLines_widget.dart';
import 'package:vertecx/presentation/widgets/navigationWidgets/app_top_bar.dart';
import 'package:vertecx/presentation/widgets/navigationWidgets/side_menu_panel.dart';
import 'package:vertecx/presentation/routes/app_routes.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final List<int> _years;
  late int _selectedYear;
  List<String> _permissions = const <String>[];
  final NumberFormat _copNumberFormat = NumberFormat.decimalPattern('es_CO');

  String _formatCurrencyValue(double value) {
    return '\$${_copNumberFormat.format(value.round())}';
  }

  bool _isSalesPending(SalesState state) =>
      state is SalesInitial || state is SalesLoading;

  bool _isClientsPending(ClientsState state) =>
      state is ClientsInitial || state is ClientsLoading;

  bool _isPurchasesPending(PurchasesState state) =>
      state is PurchasesInitial || state is PurchasesLoading;

  bool _isAppointmentsPending(AppointmentsState state) =>
      state is AppointmentsInitial || state is AppointmentsLoading;

  bool _isOrdersPending(OrdersState state) =>
      state is OrdersInitial || state is OrdersLoading;

  bool _isProductsPending(ProductsState state) =>
      state is ProductsInitial || state is ProductsLoading;

  bool _isCalendarPending(CalendarState state) =>
      state is CalendarInitial || state is CalendarLoading;

  @override
  void initState() {
    super.initState();
    final currentYear = DateTime.now().year;
    _years = List.generate(6, (index) => currentYear - index);
    _selectedYear = currentYear;
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

  Widget _buildYearSelector() {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedYear,
          items: _years
              .map((year) => DropdownMenuItem(
                    value: year,
                    child: Text(
                      year.toString(),
                      style: const TextStyle(
                        color: Color(0xFF000000),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ))
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() => _selectedYear = value);
          },
          icon: const Icon(Icons.expand_more, color: Color(0xFF000000), size: 18),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      key: ValueKey(_selectedYear),
      providers: [
        BlocProvider(create: (_) => SalesBloc(SalesRepository())..add(LoadSalesEvent(year: _selectedYear))),
        BlocProvider(create: (_) => ClientsBloc(ClientsRepository())..add(LoadClientsEvent(year: _selectedYear))),
        BlocProvider(create: (_) => PurchasesBloc(PurchasesRepository())..add(LoadPurchasesEvent(year: _selectedYear))),
        BlocProvider(create: (_) => AppointmentsBloc(AppointmentsRepository())..add(LoadAppointmentsEvent(year: _selectedYear))),
        BlocProvider(create: (_) => OrdersBloc(OrdersRepository())..add(LoadOrdersEvent(year: _selectedYear))),
        BlocProvider(create: (_) => ProductsBloc(ProductsRepository())..add(LoadProductsEvent(year: _selectedYear))),
        BlocProvider(create: (_) => CalendarBloc(AppointmentRepository())..add(LoadAllAppointments())),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F4F4),
        appBar: AppTopBar(
          showMenu: true,
          extraActions: [_buildYearSelector()],
        ),
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
        body: Builder(
          builder: (context) {
            final salesState = context.select((SalesBloc bloc) => bloc.state);
            final clientsState =
                context.select((ClientsBloc bloc) => bloc.state);
            final purchasesState =
                context.select((PurchasesBloc bloc) => bloc.state);
            final appointmentsState =
                context.select((AppointmentsBloc bloc) => bloc.state);
            final ordersState = context.select((OrdersBloc bloc) => bloc.state);
            final productsState =
                context.select((ProductsBloc bloc) => bloc.state);
            final calendarState =
                context.select((CalendarBloc bloc) => bloc.state);

            final showGlobalLoading = _isSalesPending(salesState) ||
                _isClientsPending(clientsState) ||
                _isPurchasesPending(purchasesState) ||
                _isAppointmentsPending(appointmentsState) ||
                _isOrdersPending(ordersState) ||
                _isProductsPending(productsState) ||
                _isCalendarPending(calendarState);

            if (showGlobalLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 2.2,
                  children: [
                    BlocBuilder<SalesBloc, SalesState>(
                      builder: (context, state) {
                        if (state is SalesLoaded) {
                          final total = state.sales.fold<double>(0.0, (sum, s) => sum + s.amount);
                          return SummaryCard(
                            icon: Icons.attach_money,
                            iconColor: const Color(0xFF06A646),
                            title: "Ventas:",
                            value: _formatCurrencyValue(total),
                          );
                        }
                        return const SummaryCard(
                          icon: Icons.attach_money,
                          iconColor: Color(0xFF06A646),
                          title: "Ventas:",
                          value: "...",
                        );
                      },
                    ),
                    BlocBuilder<PurchasesBloc, PurchasesState>(
                      builder: (context, state) {
                        if (state is PurchasesLoaded) {
                          final total = state.purchases.fold<double>(0.0, (sum, s) => sum + s.amount);
                          return SummaryCard(
                            icon: Icons.shopping_cart,
                            iconColor: const Color(0xFF08873C),
                            title: "Compras:",
                            value: _formatCurrencyValue(total),
                          );
                        }
                        return const SummaryCard(
                          icon: Icons.shopping_cart,
                          iconColor: Color(0xFF08873C),
                          title: "Compras:",
                          value: "...",
                        );
                      },
                    ),
                    BlocBuilder<AppointmentsBloc, AppointmentsState>(
                      builder: (context, state) {
                        if (state is AppointmentsLoaded) {
                          final total = state.total;
                          return SummaryCard(
                            icon: Icons.event_note,
                            iconColor: const Color(0xFF04652C),
                            title: "Solicitudes de servicio:",
                            value: total.toString(),
                          );
                        }
                        return const SummaryCard(
                          icon: Icons.event_note,
                          iconColor: Color(0xFF04652C),
                          title: "Solicitudes de servicio:",
                          value: "...",
                        );
                      },
                    ),
                    BlocBuilder<OrdersBloc, OrdersState>(
                      builder: (context, state) {
                        if (state is OrdersLoaded) {
                          final total = state.total;
                          return SummaryCard(
                            icon: Icons.inventory,
                            iconColor: const Color(0xFF034A21),
                            title: "Ordenes:",
                            value: total.toString(),
                          );
                        }
                        return const SummaryCard(
                          icon: Icons.inventory,
                          iconColor: Color(0xFF034A21),
                          title: "Ordenes:",
                          value: "...",
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                BlocBuilder<SalesBloc, SalesState>(
                  builder: (context, salesState) {
                    final purchasesState = context.watch<PurchasesBloc>().state;

                    if (salesState is SalesError) {
                      return Center(child: Text(salesState.message));
                    }
                    if (purchasesState is PurchasesError) {
                      return Center(child: Text(purchasesState.message));
                    }

                    if (salesState is SalesLoaded &&
                        purchasesState is PurchasesLoaded) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: SalesVsPurchasesChartWidget(
                          sales: salesState.sales,
                          purchases: purchasesState.purchases,
                          year: _selectedYear,
                        ),
                      );
                    }

                    return const Center(child: CircularProgressIndicator());
                  },
                ),
                BlocBuilder<ClientsBloc, ClientsState>(
                  builder: (context, state) {
                    if (state is ClientsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ClientsLoaded) {
                      return ClientsChartWidget(
                        clients: state.clients,
                        year: _selectedYear,
                      );
                    } else if (state is ClientsError) {
                      return Center(child: Text(state.message));
                    }
                    return const SizedBox(height: 20);
                  },
                ),
                const SizedBox(height: 20),
                BlocBuilder<AppointmentsBloc, AppointmentsState>(
                  builder: (context, state) {
                    if (state is AppointmentsLoaded) {
                      if (state.states.isEmpty) return const SizedBox(height: 20);
                      final labels = state.states.keys.toList();
                      final values = state.states.values.toList();
                      return StateChartWidget(
                        title: "Solicitudes de servicio",
                        description: "Comparacion de solicitudes por estado",
                        labels: labels,
                        values: values,
                      );
                    }
                    return const SizedBox(height: 20);
                  },
                ),
                const SizedBox(height: 20),
                BlocBuilder<OrdersBloc, OrdersState>(
                  builder: (context, state) {
                    if (state is OrdersLoaded) {
                      if (state.states.isEmpty) return const SizedBox(height: 20);
                      final labels = state.states.keys.toList();
                      final values = state.states.values.toList();
                      return StateChartWidget(
                        title: "Ordenes",
                        description: "Comparacion de ordenes por estado",
                        labels: labels,
                        values: values,
                      );
                    }
                    return const SizedBox(height: 20);
                  },
                ),
                const SizedBox(height: 20),
                const ProductsPieChartWidget(),
                const SizedBox(height: 20),
                BlocBuilder<CalendarBloc, CalendarState>(
                  builder: (context, state) {
                    if (state is CalendarLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is AllAppointmentsLoaded) {
                      final now = DateTime.now();
                      final todaysAppointments = state.appointments
                          .where(
                            (cita) =>
                                cita.dia == now.day &&
                                cita.mes == now.month &&
                                cita.anio == now.year,
                          )
                          .toList();
                      return Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(top: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.event_note, color: Colors.black, size: 20),
                                SizedBox(width: 6),
                                Text(
                                  "Citas de hoy",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (todaysAppointments.isEmpty)
                              const Text(
                                "No hay citas para hoy",
                                style: TextStyle(color: Color(0xFF9CA3AF)),
                              ),
                            ...todaysAppointments
                                .map((cita) => AppointmentCard(cita: cita))
                                .toList(),
                          ],
                        ),
                      );
                    } else if (state is CalendarError) {
                      return Center(child: Text(state.message));
                    }
                    return const SizedBox();
                  },
                ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
