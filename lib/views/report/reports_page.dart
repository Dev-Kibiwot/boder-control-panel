import 'package:devboder/constants/utils/enums.dart';
import 'package:devboder/controller/reports_controller.dart';
import 'package:devboder/views/report/report_item.dart';
import 'package:devboder/widgets/custom_header.dart';
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
}