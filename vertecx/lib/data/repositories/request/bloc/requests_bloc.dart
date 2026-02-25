import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vertecx/data/models/request/request_model.dart';
import 'package:vertecx/data/repositories/request/bloc/requests_event.dart';
import 'package:vertecx/data/repositories/request/bloc/requests_state.dart';

class RequestsBloc extends Bloc<RequestsEvent, RequestsState> {
  final dynamic repo;

  RequestsBloc(this.repo) : super(const RequestsState()) {
    on<RequestsLoadRequested>(_onLoad);
    on<RequestsSearchChanged>(_onSearch);
    on<RequestsLoadMorePressed>(_onLoadMore);
    on<RequestsSortChanged>(_onSort);
  }

  Future<void> _onLoad(
    RequestsLoadRequested event,
    Emitter<RequestsState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final List<ServiceRequestModel> data =
          (await repo.getAll()).cast<ServiceRequestModel>();
      final filtered = _applyQueryAndSort(
        source: data,
        query: state.query,
        order: state.sortOrder,
      );
      final firstCount = filtered.length < state.pageSize ? filtered.length : state.pageSize;
      emit(state.copyWith(
        all: data,
        filtered: filtered,
        visibleCount: firstCount,
        visible: filtered.take(firstCount).toList(),
        loading: false,
      ));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  void _onSearch(
    RequestsSearchChanged event,
    Emitter<RequestsState> emit,
  ) {
    final filtered = _applyQueryAndSort(
      source: state.all,
      query: event.query,
      order: state.sortOrder,
    );

    final firstCount = filtered.length < state.pageSize ? filtered.length : state.pageSize;

    emit(state.copyWith(
      query: event.query,
      filtered: filtered,
      visibleCount: firstCount,
      visible: filtered.take(firstCount).toList(),
    ));
  }

  void _onLoadMore(
    RequestsLoadMorePressed event,
    Emitter<RequestsState> emit,
  ) {
    final hasMore = state.visibleCount < state.filtered.length;
    if (state.loadingMore || !hasMore) return;

    emit(state.copyWith(loadingMore: true));

    final nextCount = (state.visibleCount + state.pageSize).clamp(0, state.filtered.length);
    emit(state.copyWith(
      visibleCount: nextCount,
      visible: state.filtered.take(nextCount).toList(),
      loadingMore: false,
    ));
  }

  void _onSort(
    RequestsSortChanged event,
    Emitter<RequestsState> emit,
  ) {
    if (event.order == state.sortOrder) return;

    final filtered = _applyQueryAndSort(
      source: state.all,
      query: state.query,
      order: event.order,
    );
    final nextCount = state.visibleCount.clamp(0, filtered.length);

    emit(state.copyWith(
      sortOrder: event.order,
      filtered: filtered,
      visibleCount: nextCount,
      visible: filtered.take(nextCount).toList(),
    ));
  }

  List<ServiceRequestModel> _applyQueryAndSort({
    required List<ServiceRequestModel> source,
    required String query,
    required RequestsSortOrder order,
  }) {
    final q = query.trim().toLowerCase();

    final List<ServiceRequestModel> filtered = q.isEmpty
        ? List<ServiceRequestModel>.of(source)
        : source.where((r) {
            final idStr = 'id:${r.serviceRequestId}';
            final serviceType = r.serviceType.toLowerCase();
            final description = r.description.toLowerCase();
            final stateId = r.stateId.toString();
            final serviceId = r.serviceId.toString();
            final clientId = r.clientId.toString();
            final stateName = ((r.state?['name'] ?? r.state?['nombre'])?.toString().toLowerCase()) ?? '';
            final serviceName = ((r.service?['name'] ?? r.service?['nombre'])?.toString().toLowerCase()) ?? '';
            final customerName = ((r.customer?['name'] ??
                    r.customer?['fullname'] ??
                    r.customer?['razonSocial'] ??
                    r.customer?['nombre'])
                ?.toString()
                .toLowerCase()) ?? '';
            return serviceType.contains(q) ||
                description.contains(q) ||
                idStr.contains(q) ||
                stateId.contains(q) ||
                serviceId.contains(q) ||
                clientId.contains(q) ||
                stateName.contains(q) ||
                serviceName.contains(q) ||
                customerName.contains(q);
          }).toList();

    filtered.sort((a, b) {
      if (order == RequestsSortOrder.newestFirst) {
        final byDate = b.createdAt.compareTo(a.createdAt);
        if (byDate != 0) return byDate;
        return b.serviceRequestId.compareTo(a.serviceRequestId);
      }
      final byDate = a.createdAt.compareTo(b.createdAt);
      if (byDate != 0) return byDate;
      return a.serviceRequestId.compareTo(b.serviceRequestId);
    });

    return filtered;
  }
}
