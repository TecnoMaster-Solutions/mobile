import 'package:flutter/material.dart';
import 'package:vertecx/data/models/appointments/appointment_model.dart';
import 'package:vertecx/presentation/widgets/navigationWidgets/app_top_bar.dart';
import 'package:vertecx/presentation/widgets/appointmentsWidgets/appointment_additional_info.dart';
import 'package:vertecx/presentation/widgets/appointmentsWidgets/appointment_service_detail.dart';
import 'package:vertecx/presentation/widgets/appointmentsWidgets/appointment_order_history.dart';
import 'package:vertecx/presentation/widgets/appointmentsWidgets/appointment_technicians_card.dart';

class AppointmentDetailPage extends StatefulWidget {
  final AppointmentEvent cita;

  const AppointmentDetailPage({super.key, required this.cita});

  @override
  State<AppointmentDetailPage> createState() => _AppointmentDetailPageState();
}

class _AppointmentDetailPageState extends State<AppointmentDetailPage> {
  late final Future<AppointmentDetailData> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = loadAppointmentDetail(widget.cita);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'Detalles de la cita', showBack: true),
      backgroundColor: const Color(0xFFE8E8E8),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  AppointmentServiceDetail(
                    cita: widget.cita,
                    detailFuture: _detailFuture,
                  ),
                  AppointmentTechniciansCard(
                    tecnicos: widget.cita.orden.tecnicos,
                  ),
                  AppointmentAdditionalInfo(cita: widget.cita),
                  AppointmentOrderHistory(detailFuture: _detailFuture),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
