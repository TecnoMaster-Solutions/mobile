import '../../../models/dashboard/dashboard_models.dart';

abstract class SalesState {}

class SalesInitial extends SalesState {}

class SalesLoading extends SalesState {}

class SalesLoaded extends SalesState {
  final List<Sales> sales;
  SalesLoaded(this.sales);
}

class MonthlySalesLoaded extends SalesState {
  final int month;
  final List<double> dailySales; 
  MonthlySalesLoaded(this.month, this.dailySales);
}

class SalesError extends SalesState {
  final String message;
  SalesError(this.message);
}

abstract class ClientsState {}

class ClientsInitial extends ClientsState {}
class ClientsLoading extends ClientsState {}
class ClientsLoaded extends ClientsState {
  final List<Clients> clients;
  ClientsLoaded(this.clients);
}
class MonthlyClientsLoaded extends ClientsState {
  final int month;
  final List<double> dailyClients;
  MonthlyClientsLoaded(this.month, this.dailyClients);
}
class ClientsError extends ClientsState {
  final String message;
  ClientsError(this.message);
}

abstract class PurchasesState {}

class PurchasesInitial extends PurchasesState {}
class PurchasesLoading extends PurchasesState {}

class PurchasesLoaded extends PurchasesState {
  final List<Sales> purchases;
  PurchasesLoaded(this.purchases);
}

class MonthlyPurchasesLoaded extends PurchasesState {
  final int month;
  final List<double> dailyPurchases;
  MonthlyPurchasesLoaded(this.month, this.dailyPurchases);
}

class PurchasesError extends PurchasesState {
  final String message;
  PurchasesError(this.message);
}


class AppointmentsState {}

class AppointmentsInitial extends AppointmentsState {}

class AppointmentsLoading extends AppointmentsState {}

class AppointmentsLoaded extends AppointmentsState {
  final Map<String, int> states;
  final int total;

  AppointmentsLoaded({
    required this.states,
    required this.total,
  });
}

class AppointmentsError extends AppointmentsState {
  final String message;
  AppointmentsError(this.message);
}

abstract class OrdersState {}

class OrdersInitial extends OrdersState {}
class OrdersLoading extends OrdersState {}

class OrdersLoaded extends OrdersState {
  final Map<String, int> states;
  final int total;

  OrdersLoaded({
    required this.states,
    required this.total,
  });
}

class OrdersError extends OrdersState {
  final String message;
  OrdersError(this.message);
}


abstract class ProductsState {}

class ProductsInitial extends ProductsState {}
class ProductsLoading extends ProductsState {}
class ProductsLoaded extends ProductsState {
  final Map<String, double> products;
  ProductsLoaded(this.products);
}
class ProductsError extends ProductsState {
  final String message;
  ProductsError(this.message);
}





