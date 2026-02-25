import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vertecx/blocs/requests_event.dart';
import 'package:vertecx/blocs/requests_state.dart';
import 'package:vertecx/data/models/request/request_model.dart';

class RequestsBloc extends Bloc<RequestsEvent, RequestsState> {
  final dynamic repo;

  RequestsBloc(this.repo) : super(const RequestsState()) {
    on<RequestsLoadRequested>(_onLoad);
    on<RequestsSearchChanged>(_onSearch);
    on<RequestsLoadMorePressed>(_onLoadMore);
  }

  Future<void> _onLoad(
    RequestsLoadRequested event,
    Emitter<RequestsState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final data = await repo.getAll();
      final filtered = data;
      final firstCount =
          filtered.length < state.pageSize ? filtered.length : state.pageSize;

      emit(
        state.copyWith(
          all: data,
          filtered: filtered,
          visibleCount: firstCount,
          visible: filtered.take(firstCount).toList(),
          loading: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  void _onSearch(
    RequestsSearchChanged event,
    Emitter<RequestsState> emit,
  ) {
    final q = event.query.trim().toLowerCase();

    final filtered = q.isEmpty
        ? state.all
        : state.all.where((ServiceRequestModel r) {
            final idText = 'id:${r.serviceRequestId}';

            final estText = ((r.state?['name'] ?? r.state?['nombre'] ?? '')
                    .toString())
                .toLowerCase();

            final tipoText = r.serviceType.toLowerCase();

            final tituloText = ((r.service?['name'] ??
                        r.service?['nombre'] ??
                        r.description)
                    .toString())
                .toLowerCase();

            return tituloText.contains(q) ||
                tipoText.contains(q) ||
                idText.contains(q) ||
                estText.contains(q);
          }).toList();

    final firstCount =
        filtered.length < state.pageSize ? filtered.length : state.pageSize;

    emit(
      state.copyWith(
        query: event.query,
        filtered: filtered,
        visibleCount: firstCount,
        visible: filtered.take(firstCount).toList(),
      ),
    );
  }

  void _onLoadMore(
    RequestsLoadMorePressed event,
    Emitter<RequestsState> emit,
  ) {
    if (state.loadingMore || !state.hasMore) return;

    emit(state.copyWith(loadingMore: true));

    final nextCount =
        (state.visibleCount + state.pageSize).clamp(0, state.filtered.length);

    emit(
      state.copyWith(
        visibleCount: nextCount,
        visible: state.filtered.take(nextCount).toList(),
        loadingMore: false,
      ),
    );
  }
}
