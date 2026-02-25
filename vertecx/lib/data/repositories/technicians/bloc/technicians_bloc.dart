import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vertecx/data/repositories/technicians/technicians_repository.dart';

import 'technicians_event.dart';
import 'technicians_state.dart';

class TechniciansBloc extends Bloc<TechniciansEvent, TechniciansState> {
  final TechniciansRepository repo;

  TechniciansBloc(this.repo) : super(TechniciansInitial()) {
    on<LoadTechniciansEvent>((event, emit) async {
      emit(TechniciansLoading());
      try {
        final technicians = await repo.fetchTechnicians();
        emit(TechniciansLoaded(technicians));
      } catch (e) {
        emit(TechniciansError(e.toString()));
      }
    });
  }
}
