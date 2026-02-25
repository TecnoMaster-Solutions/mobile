import 'package:equatable/equatable.dart';

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
