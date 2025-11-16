import 'package:flutter/material.dart';
import 'package:meditech_v1/core/utils/size_config.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class SalesGraph extends StatelessWidget {
  final List<double> weeklySales;
  const SalesGraph({super.key, required this.weeklySales});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: SizeConfig.w(8)),
      child: SizedBox(
        height: SizeConfig.h(144),
        child: LineChart(
          LineChartData(
            borderData: FlBorderData(show: false),
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final days = List.generate(
                      7,
                      (index) => DateFormat('E').format(
                        DateTime.now().subtract(Duration(days: 7 - index)),
                      ),
                    );
                    if (value.toInt() >= 0 && value.toInt() < days.length) {
                      return Text(
                        days[value.toInt()],
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                isCurved: true,
                color: colorScheme.primary,
                barWidth: 2,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colorScheme.primary.withValues(alpha: 0.3),
                      colorScheme.primary.withValues(alpha: 0.05),
                    ],
                  ),
                ),
                spots: List.generate(
                  weeklySales.length,
                  (i) => FlSpot(i.toDouble(), weeklySales[i]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
