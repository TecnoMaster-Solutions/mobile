abstract class SalesEvent {}

class LoadSalesEvent extends SalesEvent {
  final int? year;
  LoadSalesEvent({this.year});
}

class LoadMonthlySalesEvent extends SalesEvent {
  final int month;
  final int? year;
  LoadMonthlySalesEvent(this.month, {this.year});
}

abstract class ClientsEvent {}

class LoadClientsEvent extends ClientsEvent {
  final int? year;
  LoadClientsEvent({this.year});
}

class LoadMonthlyClientsEvent extends ClientsEvent {
  final int month;
  final int? year;
  LoadMonthlyClientsEvent(this.month, {this.year});
}

abstract class PurchasesEvent {}

class LoadPurchasesEvent extends PurchasesEvent {
  final int? year;
  LoadPurchasesEvent({this.year});
}

class LoadMonthlyPurchasesEvent extends PurchasesEvent {
  final int month;
  final int? year;
  LoadMonthlyPurchasesEvent(this.month, {this.year});
}

abstract class AppointmentsEvent {}

class LoadAppointmentsEvent extends AppointmentsEvent {
  final int? year;
  LoadAppointmentsEvent({this.year});
}

abstract class OrdersEvent {}

class LoadOrdersEvent extends OrdersEvent {
  final int? year;
  LoadOrdersEvent({this.year});
}

abstract class ProductsEvent {}

class LoadProductsEvent extends ProductsEvent {
  final int? year;
  LoadProductsEvent({this.year});
}

