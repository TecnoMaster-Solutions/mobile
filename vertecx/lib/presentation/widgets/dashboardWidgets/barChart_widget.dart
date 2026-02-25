import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vertecx/data/models/dashboard/dashboard_models.dart';
import 'package:vertecx/data/repositories/dashboard/bloc/dashboard_event.dart';
import 'package:vertecx/data/repositories/dashboard/bloc/dashboard_bloc.dart';
import 'package:vertecx/presentation/widgets/dashboardWidgets/DashedLinePainter.dart';

class YearSalesChartWidget extends StatelessWidget {
  final List<Sales> sales;
  final String title;
  final bool isClientChart;
  final bool isPurchasesChart;
  final int year;

  const YearSalesChartWidget({
    super.key,
    required this.sales,
    required this.title,
    this.isClientChart = false,
    this.isPurchasesChart = false,
    required this.year,
  });

  @override
  Widget build(BuildContext context) {
    final maxVenta = sales.map((s) => s.amount).reduce((a, b) => a > b ? a : b);
    final referenceLine = maxVenta + 190000;

    return Container(
      height: 200,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          //Encabezado reducido
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isClientChart
                    ? "$title $year: ${maxVenta.toStringAsFixed(0)}"
                    : "$title $year: \$${maxVenta.toStringAsFixed(0)}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF000000),
                ),
              ),
              const Icon(Icons.bar_chart, size: 18, color: Color(0xFF000000)),
            ],
          ),
          const SizedBox(height: 8),

          //Gráfico con interacción + línea punteada
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final chartHeight = constraints.maxHeight;
                final lineTop =
                    chartHeight * (1 - (referenceLine / (referenceLine)));

                return Stack(
                  children: [
                    //Gráfico de barras
                    BarChart(
                      BarChartData(
                        gridData: FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        maxY: referenceLine,
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 22,
                              getTitlesWidget: (value, meta) {
                                const months = [
                                  'Jan',
                                  'Feb',
                                  'Mar',
                                  'Apr',
                                  'May',
                                  'Jun',
                                  'Jul',
                                  'Aug',
                                  'Sep',
                                  'Oct',
                                  'Nov',
                                  'Dec',
                                ];
                                if (value.toInt() >= 0 &&
                                    value.toInt() < months.length) {
                                  return Text(
                                    months[value.toInt()],
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF525252),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                        ),

                        //Interacción: decide a qué bloc avisar
                        barTouchData: BarTouchData(
                          touchCallback: (event, response) {
                            if (event.isInterestedForInteractions &&
                                response != null &&
                                response.spot != null) {
                              final touchedIndex =
                                  response.spot!.touchedBarGroupIndex;

                              // Usa el mes real de la data para evitar ir siempre a enero
                              final selectedMonth = (touchedIndex >= 0 &&
                                      touchedIndex < sales.length)
                                  ? sales[touchedIndex].month
                                  : response.spot!.touchedBarGroup.x.toInt() + 1;

                            if (isClientChart) {
                              context.read<ClientsBloc>().add(
                                LoadMonthlyClientsEvent(
                                  selectedMonth,
                                  year: year,
                                ),
                              );
                            } else if (isPurchasesChart) {
                              context.read<PurchasesBloc>().add(
                                LoadMonthlyPurchasesEvent(
                                  selectedMonth,
                                  year: year,
                                ),
                              );
                            } else {
                              context.read<SalesBloc>().add(
                                LoadMonthlySalesEvent(
                                  selectedMonth,
                                  year: year,
                                ),
                              );
                            }
                          }
                        },
                        ),

                        barGroups: sales.map((s) {
                          final isMax = s.amount == maxVenta;
                          return BarChartGroupData(
                            x: s.month - 1,
                            barRods: [
                              BarChartRodData(
                                toY: s.amount,
                                color: isMax
                                    ? const Color(0xFFB20000)
                                    : const Color(0xFFE9E9E9),
                                borderRadius: BorderRadius.circular(4),
                                width: 14,
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),

                    //Línea roja punteada
                    Positioned(
                      top: lineTop,
                      right: 20,
                      child: Row(
                        children: [
                          CustomPaint(
                            size: const Size(280, 2),
                            painter: DashedLinePainter(
                              color: Color(0xFFCC0000),
                              dashWidth: 6,
                              dashSpace: 4,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Text(
                            "MAX",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF000000),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
