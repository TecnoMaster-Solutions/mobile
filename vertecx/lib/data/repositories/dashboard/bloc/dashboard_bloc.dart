import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vertecx/data/repositories/dashboard/bloc/dashboard_event.dart';
import 'package:vertecx/data/repositories/dashboard/bloc/dashboard_states.dart';
import 'package:vertecx/data/repositories/dashboard/dashboard_repository.dart';

class SalesBloc extends Bloc<SalesEvent, SalesState> {
  final SalesRepository repository;

  SalesBloc(this.repository) : super(SalesInitial()) {
    on<LoadSalesEvent>((event, emit) async {
      emit(SalesLoading());
      try {
        final sales = await repository.fetchSales(year: event.year);
        emit(SalesLoaded(sales));
      } catch (e) {
        emit(SalesError("Error al cargar ventas"));
      }
    });

    on<LoadMonthlySalesEvent>((event, emit) async {
      emit(SalesLoading());
      try {
        final dailySales = await repository.fetchDailySales(
          event.month,
          year: event.year,
        );
        emit(MonthlySalesLoaded(event.month, dailySales));
      } catch (e) {
        emit(SalesError("Error al cargar ventas mensuales"));
      }
    });
  }
}

class ClientsBloc extends Bloc<ClientsEvent, ClientsState> {
  final ClientsRepository repository;

  ClientsBloc(this.repository) : super(ClientsInitial()) {
    on<LoadClientsEvent>((event, emit) async {
      emit(ClientsLoading());
      try {
        final clients = await repository.fetchClients(year: event.year);
        emit(ClientsLoaded(clients));
      } catch (e) {
        emit(ClientsError("Error al cargar clientes"));
      }
    });

    on<LoadMonthlyClientsEvent>((event, emit) async {
      emit(ClientsLoading());
      try {
        final daily = await repository.fetchDailyClients(
          event.month,
          year: event.year,
        );
        emit(MonthlyClientsLoaded(event.month, daily));
      } catch (e) {
        emit(ClientsError("Error al cargar clientes mensuales"));
      }
    });
  }
}

class PurchasesBloc extends Bloc<PurchasesEvent, PurchasesState> {
  final PurchasesRepository repository;

  PurchasesBloc(this.repository) : super(PurchasesInitial()) {
    on<LoadPurchasesEvent>((event, emit) async {
      emit(PurchasesLoading());
      try {
        final purchases = await repository.fetchPurchases(year: event.year);
        emit(PurchasesLoaded(purchases));
      } catch (e) {
        emit(PurchasesError("Error al cargar compras"));
      }
    });

    on<LoadMonthlyPurchasesEvent>((event, emit) async {
      emit(PurchasesLoading());
      try {
        final daily = await repository.fetchDailyPurchases(
          event.month,
          year: event.year,
        );
        emit(MonthlyPurchasesLoaded(event.month, daily));
      } catch (e) {
        emit(PurchasesError("Error al cargar compras mensuales"));
      }
    });
  }
}

class AppointmentsBloc extends Bloc<AppointmentsEvent, AppointmentsState> {
  final AppointmentsRepository repository;

  AppointmentsBloc(this.repository) : super(AppointmentsInitial()) {
    on<LoadAppointmentsEvent>((event, emit) async {
      emit(AppointmentsLoading());
      try {
        final data = await repository.fetchAppointmentsStats(year: event.year);
        final total = data.values.fold<int>(0, (a, b) => a + b);
        emit(AppointmentsLoaded(states: data, total: total));
      } catch (e) {
        emit(AppointmentsError("Error al cargar citas"));
      }
    });
  }
}

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final OrdersRepository repository;

  OrdersBloc(this.repository) : super(OrdersInitial()) {
    on<LoadOrdersEvent>((event, emit) async {
      emit(OrdersLoading());
      try {
        final data = await repository.fetchOrdersStats(year: event.year);
        final total = data.values.fold<int>(0, (a, b) => a + b);
        emit(OrdersLoaded(states: data, total: total));
      } catch (e) {
        emit(OrdersError("Error al cargar ordenes"));
      }
    });
  }
}


class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final ProductsRepository repository;

  ProductsBloc(this.repository) : super(ProductsInitial()) {
    on<LoadProductsEvent>((event, emit) async {
      emit(ProductsLoading());
      try {
        final products = await repository.fetchProductsByCategory(
          year: event.year,
        );
        emit(ProductsLoaded(products));
      } catch (e) {
        emit(ProductsError("Error al cargar productos"));
      }
    });
  }
}







