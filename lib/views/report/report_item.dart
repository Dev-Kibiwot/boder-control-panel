import 'package:boder/constants/utils/enums.dart';

class ReportItem {
  final String name;
  final String description;
  final DateTime lastGenerated;
  final ReportType type;

  ReportItem({
    required this.name,
    required this.description,
    required this.lastGenerated,
    required this.type,
  });
}