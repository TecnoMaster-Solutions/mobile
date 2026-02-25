import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vertecx/data/repositories/dashboard/bloc/dashboard_bloc.dart';
import 'package:vertecx/data/repositories/dashboard/bloc/dashboard_event.dart';

class MonthSalesChartWidget extends StatelessWidget {
  final List<double> dailySales;
  final int month;
  final bool isClientChart;
  final bool isPurchasesChart;
  final int year;

  const MonthSalesChartWidget({
    super.key,
    required this.dailySales,
    required this.month,
    this.isClientChart = false,
    this.isPurchasesChart = false,
    required this.year,
  });

  //Nombres de los meses
  String getMonthName(int month) {
    const months = [
      "Ene", "Feb", "Mar", "Abr", "May", "Jun",
      "Jul", "Ago", "Sep", "Oct", "Nov", "Dic",
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final total = dailySales.fold<double>(0, (a, b) => a + b);
    final monthName = getMonthName(month);
    final maxValue = dailySales.isEmpty ? 0.0 : dailySales.reduce((a, b) => a > b ? a : b);
    final interval = maxValue <= 0 ? 1.0 : (maxValue / 5).ceilToDouble();
    final chartMaxY = (maxValue + interval).clamp(interval, double.infinity);

    return Container(
      height: 300,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado
          Row(
            children: [
              Text(
                isClientChart
                    ? "Clientes $monthName $year: ${total.toStringAsFixed(0)}"
                    : isPurchasesChart
                        ? "Compras $monthName $year: \$${total.toStringAsFixed(0)}"
                        : "Ventas $monthName $year: \$${total.toStringAsFixed(0)}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF000000),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (isClientChart) {
                    context.read<ClientsBloc>().add(
                          LoadClientsEvent(year: year),
                        );
                  } else if (isPurchasesChart) {
                    context.read<PurchasesBloc>().add(
                          LoadPurchasesEvent(year: year),
                        );
                  } else {
                    context.read<SalesBloc>().add(
                          LoadSalesEvent(year: year),
                        );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Gráfico de líneas
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  drawVerticalLine: false,
                  horizontalInterval: interval,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    axisNameWidget: const Text(
                      "Días del Mes",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 2,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < dailySales.length) {
                          return Text(
                            "${value.toInt() + 1}",
                            style: const TextStyle(fontSize: 9),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: interval,
                      getTitlesWidget: (value, meta) {
                        if (value % interval == 0) {
                          return Text(
                            isClientChart
                                ? "${value.toInt()}" 
                                : "\$${value.toInt()}", 
                            style: const TextStyle(fontSize: 9),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                minX: 0,
                maxX: dailySales.length.toDouble() - 1,
                minY: 0,
                maxY: chartMaxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: dailySales
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                        .toList(),
                    isCurved: false,
                    color: const Color(0xFFB20000),
                    barWidth: 2,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                        radius: 3,
                        color: const Color(0xFFB20000),
                        strokeWidth: 1,
                        strokeColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
