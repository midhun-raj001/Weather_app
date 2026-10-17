import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TemperatureChart extends StatelessWidget {
  final List<double> temps;

  const TemperatureChart({super.key, required this.temps});

  @override
  Widget build(BuildContext context) {
    if (temps.isEmpty) return const SizedBox();

    double minY = temps.reduce((a, b) => a < b ? a : b) - 2;
    double maxY = temps.reduce((a, b) => a > b ? a : b) + 2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        height: 180, // 👈 reduced height
        child: LineChart(
          LineChartData(
            minY: minY,
            maxY: maxY,
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: temps.asMap().entries.map((e) {
                  return FlSpot(e.key.toDouble(), e.value);
                }).toList(),
                isCurved: true,
                curveSmoothness: 0.2, // 👈 smoother but not too wavy
                barWidth: 3,
                color: Colors.white,
                dotData: FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
