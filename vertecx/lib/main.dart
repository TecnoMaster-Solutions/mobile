import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:vertecx/core/api_config.dart';
import 'package:vertecx/core/api_http.dart';
import 'package:vertecx/core/navigation_helper.dart';
import 'package:vertecx/core/session_context.dart';

// Calendar
import 'package:vertecx/data/repositories/appointmentRepositories/appointment_repository.dart';
import 'package:vertecx/data/repositories/appointmentRepositories/bloc/calendar_bloc.dart';

// Roles
import 'package:vertecx/data/repositories/roles/roles_repository.dart';
import 'package:vertecx/data/repositories/roles/bloc/roles_bloc.dart';
import 'package:vertecx/data/repositories/roles/bloc/roles_event.dart';

// Technicians
import 'package:vertecx/data/repositories/technicians/technicians_repository.dart';
import 'package:vertecx/data/repositories/technicians/bloc/technicians_bloc.dart';
import 'package:vertecx/data/repositories/technicians/bloc/technicians_event.dart';

// Services
import 'package:vertecx/data/repositories/services/services_repository.dart';
import 'package:vertecx/data/repositories/services/bloc/services_bloc.dart';
import 'package:vertecx/data/repositories/services/bloc/services_event.dart';

// Products
import 'package:vertecx/data/repositories/products/products_repository.dart';
import 'package:vertecx/data/repositories/products/bloc/products_bloc.dart';

// Pages
import 'package:vertecx/presentation/pages/clients_page.dart';
import 'package:vertecx/presentation/pages/products_page.dart';
import 'package:vertecx/presentation/pages/purchases_page.dart';
import 'package:vertecx/presentation/pages/providers_page.dart';
import 'package:vertecx/presentation/pages/sales_page.dart';
import 'package:vertecx/presentation/routes/app_routes.dart';
import 'package:vertecx/presentation/pages/appointementPage/appointment_page.dart';
import 'package:vertecx/presentation/pages/appointementPage/appointment_page_tecnico.dart';
import 'package:vertecx/presentation/pages/purchase_orders_page.dart';
import 'package:vertecx/presentation/pages/user_list_page.dart';
import 'package:vertecx/presentation/pages/categoryProducts_list_page.dart';
import 'package:vertecx/presentation/pages/dashboard_page.dart';
import 'package:vertecx/presentation/pages/profile_page.dart';
import 'package:vertecx/presentation/pages/login_page.dart';
import 'package:vertecx/presentation/pages/home/homePage.dart';
import 'package:vertecx/presentation/pages/hub/section_hub_page.dart';
import 'package:vertecx/presentation/widgets/navigationWidgets/app_top_bar.dart';
import 'package:vertecx/presentation/pages/technicians_page.dart';
import 'package:vertecx/presentation/pages/services_page.dart';
import 'package:vertecx/presentation/pages/roles_page.dart';
import 'package:vertecx/presentation/pages/OrderServicePage.dart';
import 'package:vertecx/presentation/pages/requests_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);
  await SessionContext.hydrateFromStorage();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CalendarBloc(AppointmentRepository())),
        BlocProvider(
          create: (_) => RolesBloc(RolesRepository())..add(LoadRolesEvent()),
        ),
        BlocProvider(
          create: (_) =>
              TechniciansBloc(TechniciansRepository())
                ..add(LoadTechniciansEvent()),
        ),
        BlocProvider(
          create: (_) =>
              ServicesBloc(ServicesRepository())..add(LoadServicesEvent()),
        ),
        BlocProvider(create: (_) => ProductsBloc(ProductsRepository())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.bootstrap,
        onGenerateRoute: _RouteGuard.onGenerateRoute,
        onUnknownRoute: (settings) =>
            _RouteGuard.onGenerateRoute(const RouteSettings(name: AppRoutes.bootstrap)),
      ),
    );
  }
}

class _RouteGuard {
  const _RouteGuard._();

  static final Map<String, WidgetBuilder> _routeBuilders = {
    AppRoutes.bootstrap: (_) => const SessionBootstrapPage(),
    AppRoutes.login: (_) => const LoginPage(),
    AppRoutes.home: (_) => const Home(),
    AppRoutes.userList: (_) => const UserListPage(),
    AppRoutes.categoryProduct: (_) => const CategoryProductListPage(),
    AppRoutes.appointment: (_) => const CalendarPage(),
    AppRoutes.dashboard: (_) => const DashboardPage(),
    AppRoutes.profile: (_) => const ProfilePage(),
    AppRoutes.purchasesHub: (_) => const PurchasesHubPage(),
    AppRoutes.productsHub: (_) => const ProductsHubPage(),
    AppRoutes.servicesHub: (_) => const ServicesHubPage(),
    AppRoutes.salesHub: (_) => const SalesHubPage(),
    AppRoutes.purchaseOrders: (_) => const PurchaseOrdersPage(),
    AppRoutes.purchases: (_) => const PurchasesPage(),
    AppRoutes.providers: (_) => const ProvidersPage(),
    AppRoutes.productCategories: (_) => const CategoryProductListPage(),
    AppRoutes.productsList: (_) => const ProductsPage(),
    AppRoutes.servicesList: (_) => const ServicesPage(),
    AppRoutes.techniciansList: (_) => const TechniciansPage(),
    AppRoutes.sales: (_) => const SalesPage(),
    AppRoutes.clients: (_) => const ClientsPage(),
    AppRoutes.requests: (_) => const RequestsPage(),
    AppRoutes.salesOrders: (_) => const OrderServicePage(),
    AppRoutes.salesAppointments: (_) => const AppointmentPageTecnico(),
    AppRoutes.rolesList: (_) => const RolesPage(),
    AppRoutes.techHome: (_) => const AppointmentPageTecnico(),
    AppRoutes.techHub: (_) => const TechnicianHubPage(),
  };

  static const Set<String> _publicRoutes = {
    AppRoutes.bootstrap,
    AppRoutes.login,
  };

  static const Map<String, List<String>> _anyPermissionByRoute = {
    AppRoutes.dashboard: ['dashboard.read'],
    AppRoutes.userList: ['users.read'],
    AppRoutes.rolesList: ['roles.read'],
    AppRoutes.purchaseOrders: ['purchaseorders.read'],
    AppRoutes.purchases: ['purchases.read'],
    AppRoutes.providers: ['suppliers.read'],
    AppRoutes.productsList: ['products.read'],
    AppRoutes.categoryProduct: ['categoryproducts.read'],
    AppRoutes.productCategories: ['categoryproducts.read'],
    AppRoutes.servicesList: ['services.read'],
    AppRoutes.techniciansList: ['technicians.read'],
    AppRoutes.sales: ['sales.read'],
    AppRoutes.clients: ['customers.read'],
    AppRoutes.requests: ['servicesrequest.read'],
    AppRoutes.salesOrders: ['orderservices.read'],
    AppRoutes.salesAppointments: ['appointments.read'],
    AppRoutes.appointment: ['appointments.read'],
    AppRoutes.techHome: ['appointments.read'],
    AppRoutes.techHub: ['appointments.read'],
    AppRoutes.purchasesHub: [
      'purchases.read',
      'purchaseorders.read',
      'suppliers.read',
    ],
    AppRoutes.productsHub: ['products.read', 'categoryproducts.read'],
    AppRoutes.servicesHub: ['services.read', 'technicians.read'],
    AppRoutes.salesHub: [
      'sales.read',
      'customers.read',
      'servicesrequest.read',
      'orderservices.read',
      'appointments.read',
    ],
  };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final requestedRoute = settings.name ?? AppRoutes.bootstrap;
    final builder = _routeBuilders[requestedRoute];

    if (builder == null) {
      return _buildRoute(
        AppRoutes.bootstrap,
        arguments: settings.arguments,
      );
    }

    if (_publicRoutes.contains(requestedRoute)) {
      if (requestedRoute == AppRoutes.login && _hasSession()) {
        return _buildRoute(AppRoutes.bootstrap, arguments: settings.arguments);
      }
      return MaterialPageRoute(builder: builder, settings: settings);
    }

    if (!_hasSession()) {
      return _buildRoute(AppRoutes.login, arguments: settings.arguments);
    }

    final requiredPermissions = _anyPermissionByRoute[requestedRoute];
    if (requiredPermissions != null &&
        !_hasAnyPermission(requiredPermissions)) {
      final landing = NavigationHelper.landingRouteForPermissions(
        SessionContext.permissions,
      );
      final fallbackRoute = landing == requestedRoute
          ? AppRoutes.home
          : landing;
      return _buildRoute(fallbackRoute, arguments: settings.arguments);
    }

    return MaterialPageRoute(builder: builder, settings: settings);
  }

  static bool _hasSession() {
    final hasAccess = (SessionContext.accessToken ?? '').isNotEmpty;
    final hasRefresh = (SessionContext.refreshToken ?? '').isNotEmpty;
    return hasAccess || hasRefresh;
  }

  static bool _hasAnyPermission(List<String> required) {
    final userPermissions = SessionContext.permissions
        .map((p) => p.toLowerCase())
        .toSet();
    return required.map((p) => p.toLowerCase()).any(userPermissions.contains);
  }

  static Route<dynamic> _buildRoute(String routeName, {Object? arguments}) {
    final builder = _routeBuilders[routeName] ?? _routeBuilders[AppRoutes.login]!;
    return MaterialPageRoute(
      builder: builder,
      settings: RouteSettings(name: routeName, arguments: arguments),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final String title;
  const _Placeholder(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(),
      body: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class SessionBootstrapPage extends StatefulWidget {
  const SessionBootstrapPage({super.key});

  @override
  State<SessionBootstrapPage> createState() => _SessionBootstrapPageState();
}

class _SessionBootstrapPageState extends State<SessionBootstrapPage> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await SessionContext.hydrateFromStorage();

    final hasAccess = (SessionContext.accessToken ?? '').isNotEmpty;
    final hasRefresh = (SessionContext.refreshToken ?? '').isNotEmpty;

    if (!hasAccess && !hasRefresh) {
      _goToLogin();
      return;
    }

    final meUri = Uri.parse('${ApiConfig.baseUrl}/auth/me');

    try {
      final meResponse = await ApiHttp.get(
        meUri,
        headers: const {'Accept': 'application/json'},
      );

      if (meResponse.statusCode != 200 && meResponse.statusCode != 201) {
        SessionContext.clearAll();
        _goToLogin();
        return;
      }

      final decoded = jsonDecode(meResponse.body);
      if (decoded is! Map<String, dynamic>) {
        SessionContext.clearAll();
        _goToLogin();
        return;
      }

      final rawPermissions = decoded['permissions'];
      final permissions = rawPermissions is List
          ? rawPermissions.map((e) => e.toString()).toList()
          : const <String>[];

      SessionContext.permissions = permissions;

      if (!mounted) return;
      NavigationHelper.goToLanding(context, permissions: permissions);
    } catch (_) {
      SessionContext.clearAll();
      _goToLogin();
    }
  }

  void _goToLogin() {
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
