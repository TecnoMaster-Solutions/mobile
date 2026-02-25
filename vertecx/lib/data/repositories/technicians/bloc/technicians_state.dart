import 'package:vertecx/data/models/technicians/technician_model.dart';

abstract class TechniciansState {}

class TechniciansInitial extends TechniciansState {}

class TechniciansLoading extends TechniciansState {}

class TechniciansLoaded extends TechniciansState {
  final List<TechnicianModel> technicians;

  TechniciansLoaded(this.technicians);
}

class TechniciansError extends TechniciansState {
  final String message;

  TechniciansError(this.message);
}
