import 'dart:io';
import 'package:boder/constants/utils/enums.dart';
import 'package:boder/controller/reports_controller.dart';
import 'package:boder/services/toast_service.dart';
import 'package:boder/views/report/report_item.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class ExportService {
  final ToastService toastService = ToastService();

  Future<String> getDownloadsPath() async {
    if (Platform.isWindows) {
      final String home = Platform.environment['USERPROFILE'] ?? '';
      return '$home\\Downloads';
    } else if (Platform.isMacOS) {
      final String home = Platform.environment['HOME'] ?? '';
      return '$home/Downloads';
    } else if (Platform.isLinux) {
      final String home = Platform.environment['HOME'] ?? '';
      return '$home/Downloads';
    } else {
      // For mobile or unsupported platforms
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }
  }

  Future<void> exportToPDF(
    BuildContext context,
    ReportItem report,
    ReportsController controller,
  ) async {
    try {
      final pdf = pw.Document();
      final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
      
      // Get data based on report type
      Map<String, dynamic> data;
      switch (report.type) {
        case ReportType.financial:
          data = controller.getFinancialData();
          break;
        case ReportType.trips:
          data = controller.getTripData();
          break;
        case ReportType.users:
          data = controller.getUserData();
          break;
        case ReportType.riders:
          data = controller.getRiderData();
          break;
      }

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Text(
                  report.name,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  report.description,
                  style: const pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Generated: ${dateFormat.format(DateTime.now())}',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
                pw.Divider(thickness: 2),
                pw.SizedBox(height: 20),
                
                // Data section
                ...data.entries.map((entry) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 12),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          _formatKey(entry.key),
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          entry.value.toString(),
                          style: const pw.TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                
                pw.SizedBox(height: 30),
                pw.Divider(),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Report Period: ${controller.getDateRangeText(controller.selectedDateRange.value)}',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Save file
      final downloadsPath = await getDownloadsPath();
      final fileName = '${report.name.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('$downloadsPath/$fileName');
      await file.writeAsBytes(await pdf.save());

      toastService.showSuccess(
        context: context,
        message: 'PDF exported successfully to Downloads folder',
      );
    } catch (e) {
      toastService.showError(
        context: context,
        message: 'Failed to export PDF: $e',
      );
    }
  }

  Future<void> exportToExcel(
    BuildContext context,
    ReportItem report,
    ReportsController controller,
  ) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Report'];

      // Get data based on report type
      Map<String, dynamic> data;
      switch (report.type) {
        case ReportType.financial:
          data = controller.getFinancialData();
          break;
        case ReportType.trips:
          data = controller.getTripData();
          break;
        case ReportType.users:
          data = controller.getUserData();
          break;
        case ReportType.riders:
          data = controller.getRiderData();
          break;
      }

      // Add header
      sheet.appendRow([
        TextCellValue(report.name),
      ]);
      sheet.appendRow([
        TextCellValue(report.description),
      ]);
      sheet.appendRow([
        TextCellValue('Generated: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}'),
      ]);
      sheet.appendRow([]); // Empty row

      // Add column headers
      sheet.appendRow([
        TextCellValue('Metric'),
        TextCellValue('Value'),
      ]);

      // Add data
      data.forEach((key, value) {
        sheet.appendRow([
          TextCellValue(_formatKey(key)),
          TextCellValue(value.toString()),
        ]);
      });

      // Add report period
      sheet.appendRow([]);
      sheet.appendRow([
        TextCellValue('Report Period:'),
        TextCellValue(controller.getDateRangeText(controller.selectedDateRange.value)),
      ]);

      // Save file
      final downloadsPath = await getDownloadsPath();
      final fileName = '${report.name.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final file = File('$downloadsPath/$fileName');
      final excelBytes = excel.encode();
      if (excelBytes != null) {
        await file.writeAsBytes(excelBytes);
      }

      toastService.showSuccess(
        context: context,
        message: 'Excel exported successfully to Downloads folder',
      );
    } catch (e) {
      toastService.showError(
        context: context,
        message: 'Failed to export Excel: $e',
      );
    }
  }

  Future<void> exportToCSV(
    BuildContext context,
    ReportItem report,
    ReportsController controller,
  ) async {
    try {
      // Get data based on report type
      Map<String, dynamic> data;
      switch (report.type) {
        case ReportType.financial:
          data = controller.getFinancialData();
          break;
        case ReportType.trips:
          data = controller.getTripData();
          break;
        case ReportType.users:
          data = controller.getUserData();
          break;
        case ReportType.riders:
          data = controller.getRiderData();
          break;
      }

      // Create CSV data
      List<List<dynamic>> rows = [];
      
      // Add header information
      rows.add([report.name]);
      rows.add([report.description]);
      rows.add(['Generated: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}']);
      rows.add([]); // Empty row
      
      // Add column headers
      rows.add(['Metric', 'Value']);
      
      // Add data
      data.forEach((key, value) {
        rows.add([_formatKey(key), value.toString()]);
      });
      
      // Add report period
      rows.add([]);
      rows.add(['Report Period:', controller.getDateRangeText(controller.selectedDateRange.value)]);

      // Convert to CSV string
      String csv = const ListToCsvConverter().convert(rows);

      // Save file
      final downloadsPath = await getDownloadsPath();
      final fileName = '${report.name.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File('$downloadsPath/$fileName');
      await file.writeAsString(csv);

      toastService.showSuccess(
        context: context,
        message: 'CSV exported successfully to Downloads folder',
      );
    } catch (e) {
      toastService.showError(
        context: context,
        message: 'Failed to export CSV: $e',
      );
    }
  }

  String _formatKey(String key) {
    // Convert camelCase to Title Case
    return key
        .replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(0)}',
        )
        .trim()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}