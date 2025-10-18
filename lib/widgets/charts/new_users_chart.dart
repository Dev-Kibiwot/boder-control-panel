import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class NewUsersChart extends StatelessWidget {
  const NewUsersChart({super.key});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) => Text('Day ${value.toInt()}'),
            ),
          ),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            spots: [
              FlSpot(0, 15),
              FlSpot(1, 25),
              FlSpot(2, 20),
              FlSpot(3, 30),
            ],
            color: Colors.blue,
            barWidth: 3,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
          ),
          LineChartBarData(
            isCurved: true,
            spots: [
              FlSpot(0, 10),
              FlSpot(1, 20),
              FlSpot(2, 18),
              FlSpot(3, 25),
            ],
            color: Colors.green,
            barWidth: 3,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }
}
