import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vertecx/data/models/dashboard/dashboard_models.dart';

class ClientsChartWidget extends StatelessWidget {
  static const Color _clientsColor = Color(0xFF04652C);

  final List<Clients> clients;
  final int year;

  const ClientsChartWidget({
    super.key,
    required this.clients,
    required this.year,
  });

  List<double> _buildMonthlySeries(List<Clients> source) {
    final values = List<double>.filled(12, 0.0);
    for (final item in source) {
      if (item.month >= 1 && item.month <= 12) {
        values[item.month - 1] += item.amount;
      }
    }
    return values;
  }

  String _formatTotal(double value) {
    return NumberFormat.decimalPattern('es_CO').format(value.round());
  }

  @override
  Widget build(BuildContext context) {
    final monthlyClients = _buildMonthlySeries(clients);
    final totalClients = monthlyClients.fold<double>(0, (a, b) => a + b);
    final maxY =
        math.max(1, monthlyClients.fold<double>(0, (a, b) => math.max(a, b)));
    final interval = (maxY / 5).ceilToDouble();
    final chartMaxY = maxY + interval;

    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];

    return Container(
      height: 300,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Clientes $year',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF000000),
                ),
              ),
              const Spacer(),
              const Icon(Icons.show_chart, color: Color(0xFF000000), size: 18),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Total: ${_formatTotal(totalClients)}',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF4B5563),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              _LegendDot(color: _clientsColor, label: 'Clientes'),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 11,
                minY: 0,
                maxY: chartMaxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: interval,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: const Color(0xFFE9E9E9),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: const Color(0xFFE9E9E9), width: 1),
                ),
                titlesData: FlTitlesData(
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 24,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= 12) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          months[index],
                          style: const TextStyle(
                            fontSize: 9,
                            color: Color(0xFF9CA3AF),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 38,
                      interval: interval,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 9,
                            color: Color(0xFF9CA3AF),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      12,
                      (index) => FlSpot(index.toDouble(), monthlyClients[index]),
                    ),
                    isCurved: false,
                    color: _clientsColor,
                    barWidth: 2,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                        radius: 3,
                        color: _clientsColor,
                        strokeWidth: 1.5,
                        strokeColor: Colors.white,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => const Color(0xFF111111),
                    tooltipBorderRadius: BorderRadius.circular(8),
                    tooltipBorder: const BorderSide(
                      color: Color(0xFF04652C),
                      width: 1.2,
                    ),
                    tooltipPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    getTooltipItems: (spots) {
                      return spots.map((spot) {
                        return LineTooltipItem(
                          'Clientes: ${spot.y.toInt()}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4B5563),
          ),
        ),
      ],
    );
  }
}
