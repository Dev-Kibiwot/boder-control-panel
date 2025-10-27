import 'package:boder/constants/utils/enums.dart';
import 'package:boder/controller/reports_controller.dart';
import 'package:boder/views/report/report_item.dart';
import 'package:boder/widgets/custom_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReportsPage extends StatelessWidget {
  ReportsPage({super.key});
  
  final ReportsController controller = Get.put(ReportsController());
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Obx(() {
        if (controller.isAnyLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF0E9EDC)),
          );
        }
        return RefreshIndicator(
          color: const Color(0xFF0E9EDC),
          onRefresh: () => controller.refreshReportData(context),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                CustomHeader(title: "Reports"),
                _buildQuickStats(),
                _buildReportTypeSelector(),
                _buildReportsList(context),
                _buildBulkExportSection(context),
                _buildScheduledReports(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildQuickStats() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Obx(() {
        final stats = controller.quickStats;
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Revenue',
                'KES ${stats['totalRevenue'].toStringAsFixed(2)}',
                stats['revenueChange'],
                true,
                Icons.attach_money,
                const Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Total Trips',
                '${stats['totalTrips']}',
                stats['tripsChange'],
                true,
                Icons.local_taxi,
                const Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Active Users',
                '${stats['activeUsers']}',
                stats['usersChange'],
                true,
                Icons.people,
                const Color(0xFF8B5CF6),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Avg Trip Value',
                'KES ${stats['avgTripValue'].toStringAsFixed(2)}',
                stats['avgValueChange'],
                false,
                Icons.trending_up,
                const Color(0xFFF59E0B),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatCard(String label, String value, String change, bool positive, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: positive 
                      ? const Color(0xFF10B981).withOpacity(0.1)
                      : const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: positive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF718096),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A202C),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildReportTypeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Obx(() {
        return Row(
          children: ReportType.values.map((type) {
            final isSelected = controller.selectedReportType.value == type;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: InkWell(
                  onTap: () => controller.selectReportType(type),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF0E9EDC).withOpacity(0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF0E9EDC) : const Color(0xFFE2E8F0),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: controller.getReportTypeColor(type).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            controller.getReportTypeIcon(type),
                            color: controller.getReportTypeColor(type),
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          controller.getReportTypeName(type),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? const Color(0xFF0E9EDC) : const Color(0xFF1A202C),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }),
    );
  }

  Widget _buildReportsList(BuildContext context) { // Accept context parameter
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Obx(() {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.getReportTypeName(controller.selectedReportType.value),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A202C),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Select a report to generate and download',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF718096),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            Obx(() {
              final reports = controller.currentReports;
              return Column(
                children: reports.map((report) {
                  return _buildReportItem(report, context); // Pass context
                }).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildReportItem(ReportItem report, BuildContext context) { // Accept context parameter
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.description,
              color: Color(0xFF718096),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A202C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  report.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF718096),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Last generated: ${controller.formatRelativeTime(report.lastGenerated)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFA0AEC0),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => controller.viewReport(report, context), // Use passed context
                icon: const Icon(Icons.bar_chart, size: 18),
                label: const Text('View'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF7FAFC),
                  foregroundColor: const Color(0xFF1A202C),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                color: Colors.white,
                icon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E9EDC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.download, size: 18, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Export',
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                onSelected: (format) {
                  controller.exportReport(report, context, format); // Use passed context
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'PDF',
                    child: Row(
                      children: [
                        Icon(Icons.picture_as_pdf, size: 18, color: Color(0xFF718096)),
                        SizedBox(width: 8),
                        Text('Export as PDF', style: TextStyle(color: Color(0xFF1A202C))),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'Excel',
                    child: Row(
                      children: [
                        Icon(Icons.table_chart, size: 18, color: Color(0xFF718096)),
                        SizedBox(width: 8),
                        Text('Export as Excel', style: TextStyle(color: Color(0xFF1A202C))),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'CSV',
                    child: Row(
                      children: [
                        Icon(Icons.text_snippet, size: 18, color: Color(0xFF718096)),
                        SizedBox(width: 8),
                        Text('Export as CSV', style: TextStyle(color: Color(0xFF1A202C))),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBulkExportSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0E9EDC), Color(0xFF3182CE)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bulk Export',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Download all reports for the selected period',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Obx(() => controller.isExporting.value
                ? const CircularProgressIndicator(color: Colors.white)
                : Row(
                    children: [
                      _buildExportButton('PDF', context),
                      const SizedBox(width: 12),
                      _buildExportButton('Excel', context),
                      const SizedBox(width: 12),
                      _buildExportButton('CSV', context),
                    ],
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildExportButton(String format, BuildContext context) {
    return ElevatedButton(
      onPressed: () => controller.exportAllReports(context, format),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0E9EDC),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
      child: Text(
        'Export as $format',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildScheduledReports() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scheduled Reports',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A202C),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Automate report generation and delivery',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF718096),
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    // Show create schedule dialog
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0E9EDC),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('+ New Schedule', style: TextStyle(fontWeight: FontWeight.w500)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildScheduleCard(
                  'Weekly Financial Summary',
                  'Every Monday at 9:00 AM',
                  'admin@myboder.com',
                  true,
                )),
                const SizedBox(width: 16),
                Expanded(child: _buildScheduleCard(
                  'Monthly Performance',
                  '1st of every month',
                  'admin@myboder.com',
                  true,
                )),
                const SizedBox(width: 16),
                Expanded(child: _buildScheduleCard(
                  'Daily Trip Report',
                  'Every day at 6:00 PM',
                  'admin@myboder.com',
                  false,
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard(String title, String schedule, String recipient, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive 
                      ? const Color(0xFF10B981).withOpacity(0.1)
                      : const Color(0xFFCBD5E0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isActive ? 'Active' : 'Paused',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isActive ? const Color(0xFF10B981) : const Color(0xFF718096),
                  ),
                ),
              ),
              const Icon(
                Icons.calendar_today,
                size: 18,
                color: Color(0xFF718096),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A202C),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            schedule,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF718096),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Recipients: $recipient',
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFFA0AEC0),
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomDatePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Select Date Range', style: TextStyle(color: Color(0xFF1A202C))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Start Date', style: TextStyle(color: Color(0xFF1A202C))),
              subtitle: Obx(() => Text(
                controller.customStartDate.value?.toString().split(' ')[0] ?? 'Not selected',
                style: const TextStyle(color: Color(0xFF718096)),
              )),
              trailing: const Icon(Icons.calendar_today, color: Color(0xFF0E9EDC)),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: ThemeData.light().copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Color(0xFF0E9EDC),
                          onPrimary: Colors.white,
                          surface: Colors.white,
                          onSurface: Color(0xFF1A202C),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (date != null) {
                  controller.customStartDate.value = date;
                }
              },
            ),
            ListTile(
              title: const Text('End Date', style: TextStyle(color: Color(0xFF1A202C))),
              subtitle: Obx(() => Text(
                controller.customEndDate.value?.toString().split(' ')[0] ?? 'Not selected',
                style: const TextStyle(color: Color(0xFF718096)),
              )),
              trailing: const Icon(Icons.calendar_today, color: Color(0xFF0E9EDC)),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: ThemeData.light().copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Color(0xFF0E9EDC),
                          onPrimary: Colors.white,
                          surface: Colors.white,
                          onSurface: Color(0xFF1A202C),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (date != null) {
                  controller.customEndDate.value = date;
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF718096))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0E9EDC),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            onPressed: () {
              if (controller.customStartDate.value != null &&
                  controller.customEndDate.value != null) {
                controller.selectDateRange(DateRangeType.custom);
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}