import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vertecx/data/repositories/services/services_repository.dart';

import 'services_event.dart';
import 'services_state.dart';

class ServicesBloc extends Bloc<ServicesEvent, ServicesState> {
  final ServicesRepository repo;

  static const int _limit = 50;

  ServicesBloc(this.repo) : super(ServicesInitial()) {
    on<LoadServicesEvent>(_onLoad);
    on<RefreshServicesEvent>(_onRefresh);
    on<LoadMoreServicesEvent>(_onLoadMore);
  }

  Future<void> _onLoad(LoadServicesEvent event, Emitter<ServicesState> emit) async {
    emit(ServicesLoading());
    try {
      final res = await repo.fetchServices(page: 1, limit: _limit);

      emit(
        ServicesLoaded(
          services: res.services,
          meta: res.meta,
          loadingMore: false,
        ),
      );
    } catch (e) {
      emit(ServicesError(e.toString()));
    }
  }

  Future<void> _onRefresh(RefreshServicesEvent event, Emitter<ServicesState> emit) async {
    add(LoadServicesEvent());
  }

  Future<void> _onLoadMore(LoadMoreServicesEvent event, Emitter<ServicesState> emit) async {
    final current = state;
    if (current is! ServicesLoaded) return;
    if (!current.hasMore) return;
    if (current.loadingMore) return;

    emit(current.copyWith(loadingMore: true));

    try {
      final nextPage = current.meta.page + 1;

      final res = await repo.fetchServices(
        page: nextPage,
        limit: _limit,
      );

      emit(
        current.copyWith(
          services: [...current.services, ...res.services],
          meta: res.meta,
          loadingMore: false,
        ),
      );
    } catch (e) {
      emit(ServicesError(e.toString()));
    }
  }
}
