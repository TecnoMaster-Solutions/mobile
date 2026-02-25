import 'package:equatable/equatable.dart';
import 'package:vertecx/data/repositories/request/bloc/requests_state.dart';

abstract class RequestsEvent extends Equatable {
  const RequestsEvent();
  @override
  List<Object?> get props => [];
}

class RequestsLoadRequested extends RequestsEvent {
  const RequestsLoadRequested();
}

class RequestsSearchChanged extends RequestsEvent {
  final String query;
  const RequestsSearchChanged(this.query);
  @override
  List<Object?> get props => [query];
}

class RequestsLoadMorePressed extends RequestsEvent {
  const RequestsLoadMorePressed();
}

class RequestsSortChanged extends RequestsEvent {
  final RequestsSortOrder order;
  const RequestsSortChanged(this.order);

  @override
  List<Object?> get props => [order];
}
