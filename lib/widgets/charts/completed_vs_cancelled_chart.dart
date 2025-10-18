import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CompletedVsCancelledChart extends StatefulWidget {
  const CompletedVsCancelledChart({super.key});

  @override
  State<CompletedVsCancelledChart> createState() => _CompletedVsCancelledChartState();
}

class _CompletedVsCancelledChartState extends State<CompletedVsCancelledChart> {
  int? touchedIndex;

  final data = [
    {'value': 70.0, 'title': 'Completed', 'color': Colors.green},
    {'value': 30.0, 'title': 'Cancelled', 'color': Colors.red},
    {'value': 20.0, 'title': 'In Progress', 'color': Colors.orange},
  ];

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: (event, response) {
            setState(() {
              if (!event.isInterestedForInteractions || response == null || response.touchedSection == null) {
                touchedIndex = null;
              } else {
                touchedIndex = response.touchedSection!.touchedSectionIndex;
              }
            });
          },
        ),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        borderData: FlBorderData(show: false),
        sections: _buildSections(),
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    return List.generate(data.length, (i) {
      final isTouched = i == touchedIndex;
      final value = data[i]['value'] as double;
      final title = data[i]['title'] as String;
      final color = data[i]['color'] as Color;

      return PieChartSectionData(
        value: value,
        color: color,
        title: isTouched ? '$title\n$value' : '$value',
        titleStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        radius: 50,
      );
    });
  }
}
