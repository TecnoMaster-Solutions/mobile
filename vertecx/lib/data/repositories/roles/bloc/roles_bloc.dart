import 'package:flutter_bloc/flutter_bloc.dart';
import 'roles_event.dart';
import 'roles_state.dart';
import 'package:vertecx/data/repositories/roles/roles_repository.dart';

class RolesBloc extends Bloc<RolesEvent, RolesState> {
  final RolesRepository repo;

  RolesBloc(this.repo) : super(RolesInitial()) {
    on<LoadRolesEvent>((event, emit) async {
      emit(RolesLoading());
      try {
        final roles = await repo.fetchRoles();
        emit(RolesLoaded(roles));
      } catch (e) {
        emit(RolesError(e.toString()));
      }
    });
  }
}
