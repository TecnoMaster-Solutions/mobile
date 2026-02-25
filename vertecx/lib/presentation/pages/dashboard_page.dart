import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:vertecx/presentation/widgets/dashboardWidgets/graphhStates_widget.dart';
import 'package:vertecx/presentation/widgets/dashboardWidgets/pieChart_widget.dart';
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
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ))
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() => _selectedYear = value);
          },
          icon: const Icon(Icons.expand_more, color: Colors.black87, size: 18),
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
        backgroundColor: const Color(0xFFE8E8E8),
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
        body: SingleChildScrollView(
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
                            iconColor: Colors.green,
                            title: "Ventas:",
                            value: "\$${total.toStringAsFixed(0)}",
                          );
                        }
                        return const SummaryCard(
                          icon: Icons.attach_money,
                          iconColor: Colors.green,
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
                            iconColor: Colors.red,
                            title: "Compras:",
                            value: "\$${total.toStringAsFixed(0)}",
                          );
                        }
                        return const SummaryCard(
                          icon: Icons.shopping_cart,
                          iconColor: Colors.red,
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
                            iconColor: Colors.black87,
                            title: "Solicitudes de servicio:",
                            value: total.toString(),
                          );
                        }
                        return const SummaryCard(
                          icon: Icons.event_note,
                          iconColor: Colors.black87,
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
                            iconColor: Colors.black87,
                            title: "Ordenes:",
                            value: total.toString(),
                          );
                        }
                        return const SummaryCard(
                          icon: Icons.inventory,
                          iconColor: Colors.black87,
                          title: "Ordenes:",
                          value: "...",
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                BlocBuilder<SalesBloc, SalesState>(
                  builder: (context, state) {
                    if (state is SalesLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is SalesLoaded) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: YearSalesChartWidget(
                          title: "Ventas",
                          sales: state.sales,
                          year: _selectedYear,
                        ),
                      );
                    } else if (state is MonthlySalesLoaded) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: MonthSalesChartWidget(
                          month: state.month,
                          dailySales: state.dailySales,
                          year: _selectedYear,
                        ),
                      );
                    } else if (state is SalesError) {
                      return Center(child: Text(state.message));
                    }
                    return const SizedBox(height: 20);
                  },
                ),
                BlocBuilder<ClientsBloc, ClientsState>(
                  builder: (context, state) {
                    if (state is ClientsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ClientsLoaded) {
                      return YearSalesChartWidget(
                        title: "Clientes",
                        sales: state.clients.map((c) => Sales(month: c.month, amount: c.amount)).toList(),
                        isClientChart: true,
                        year: _selectedYear,
                      );
                    } else if (state is MonthlyClientsLoaded) {
                      return MonthSalesChartWidget(
                        month: state.month,
                        dailySales: state.dailyClients,
                        isClientChart: true,
                        year: _selectedYear,
                      );
                    } else if (state is ClientsError) {
                      return Center(child: Text(state.message));
                    }
                    return const SizedBox(height: 20);
                  },
                ),
                const SizedBox(height: 20),
                BlocBuilder<PurchasesBloc, PurchasesState>(
                  builder: (context, state) {
                    if (state is PurchasesLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is PurchasesLoaded) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: YearSalesChartWidget(
                          title: "Compras",
                          sales: state.purchases,
                          isPurchasesChart: true,
                          year: _selectedYear,
                        ),
                      );
                    } else if (state is MonthlyPurchasesLoaded) {
                      return MonthSalesChartWidget(
                        month: state.month,
                        dailySales: state.dailyPurchases,
                        isPurchasesChart: true,
                        year: _selectedYear,
                      );
                    } else if (state is PurchasesError) {
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
                                style: TextStyle(color: Color(0xFF6E6E6E)),
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
        ),
      ),
    );
  }
}
