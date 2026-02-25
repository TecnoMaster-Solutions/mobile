part of 'user_bloc.dart';

abstract class UserEvent {}

class LoadUsers extends UserEvent {}

class ToggleUserStatus extends UserEvent {
  final String userId;
  ToggleUserStatus(this.userId);
}
