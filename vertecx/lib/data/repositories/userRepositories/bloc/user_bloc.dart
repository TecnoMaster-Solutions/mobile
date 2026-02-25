import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vertecx/data/models/users/user_model.dart';
import 'package:vertecx/data/services/user_service.dart';


part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserService _userService; 
  UserBloc(this._userService) : super(UserInitial()) { 
    on<LoadUsers>(_onLoadUsers);
    on<ToggleUserStatus>(_onToggleUserStatus);
  }

  Future<void> _onLoadUsers(LoadUsers event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final users = await _userService.getUsers();
      emit(UserLoaded(users));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onToggleUserStatus(
      ToggleUserStatus event, Emitter<UserState> emit) async {
    if (state is! UserLoaded) return;

    final currentState = state as UserLoaded;
    final users = List<UserModel>.from(currentState.users);

    final index = users.indexWhere((u) => u.id == event.userId);
    if (index == -1) return;

    final user = users[index];
    final newStatus = user.estado == UserStatus.activo ? false : true;

    try {
      final updatedUser = await _userService.updateUserStatus(user.id, newStatus);
      users[index] = updatedUser;
      emit(UserLoaded(users));
    } catch (e) {
      emit(UserError("Error al cambiar estado: $e"));
    }
  }
}