import 'package:vertecx/data/models/services/service_model.dart';
import 'package:vertecx/data/services/services_service.dart';

abstract class ServicesState {}

class ServicesInitial extends ServicesState {}

class ServicesLoading extends ServicesState {}

class ServicesLoaded extends ServicesState {
  final List<ServiceModel> services;
  final ServicesMeta meta;
  final bool loadingMore;

  ServicesLoaded({
    required this.services,
    required this.meta,
    required this.loadingMore,
  });

  ServicesLoaded copyWith({
    List<ServiceModel>? services,
    ServicesMeta? meta,
    bool? loadingMore,
  }) {
    return ServicesLoaded(
      services: services ?? this.services,
      meta: meta ?? this.meta,
      loadingMore: loadingMore ?? this.loadingMore,
    );
  }

  bool get hasMore => meta.page < meta.pages;
}

class ServicesError extends ServicesState {
  final String message;
  ServicesError(this.message);
}
