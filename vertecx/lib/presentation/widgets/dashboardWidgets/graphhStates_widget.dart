import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StateChartWidget extends StatelessWidget {
  final String title;
  final String description;
  final List<String> labels; 
  final List<int> values;   

  const StateChartWidget({
    super.key,
    required this.title,
    required this.description,
    required this.labels,
    required this.values,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Encabezado
          Row(
            children: [
              const Icon(Icons.bar_chart, color: Colors.black, size: 20),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
              child: BarChart(
                BarChartData(
                  maxY: maxValue.toDouble(),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final index = group.x.toInt();
                        final value = (index >= 0 && index < values.length)
                            ? values[index]
                            : 0;
                        return BarTooltipItem(
                          value.toString(),
                          const TextStyle(
                            color: Color(0xFF00C2FF),
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < labels.length) {
                          return Text(
                            labels[value.toInt()],
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                barGroups: values.asMap().entries.map((entry) {
                  final index = entry.key;
                  final val = entry.value;
                  return _buildBar(index, val, maxValue);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _buildBar(int x, int value, int maxValue) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: maxValue.toDouble(),
          width: 15,
          borderRadius: BorderRadius.circular(6),
          rodStackItems: [
            BarChartRodStackItem(
              0,
              maxValue.toDouble(),
              const Color(0xFFF08080),
            ),
            BarChartRodStackItem(
              0,
              value.toDouble(),
              const Color(0xFFB20000),
            ),
          ],
        ),
      ],
    );
  }
}
