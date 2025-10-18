import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TrafficPatternChart extends StatelessWidget {
  const TrafficPatternChart({super.key});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, _) => Text('${value.toInt()}m'),
            ),            
          ),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots:  [
                FlSpot(0, 120), 
                FlSpot(5, 135), 
                FlSpot(10, 140), 
                FlSpot(15, 160), 
                FlSpot(30, 185)
              ],
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.2)),
          )
        ],
      ),
    );
  }
}
