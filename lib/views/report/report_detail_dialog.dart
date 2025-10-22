import 'package:boder/constants/utils/enums.dart';
import 'package:boder/controller/reports_controller.dart';
import 'package:boder/views/report/report_item.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportDetailDialog extends StatelessWidget {
  final ReportItem report;
  final ReportsController controller;

  const ReportDetailDialog({
    super.key,
    required this.report,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                report.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A202C),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                report.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF718096),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: Color(0xFF718096)),
        ),
      ],
    );
  }

  Widget _buildContent() {
    switch (report.type) {
      case ReportType.financial:
        return _buildFinancialReport();
      case ReportType.trips:
        return _buildTripsReport();
      case ReportType.users:
        return _buildUsersReport();
      case ReportType.riders:
        return _buildRidersReport();
    }
  }

  Widget _buildFinancialReport() {
    final data = controller.getFinancialData();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMetricsGrid([
          _MetricData('Total Revenue', 'KES ${data['totalRevenue'].toStringAsFixed(2)}', Icons.attach_money, Colors.green),
          _MetricData('Transactions', '${data['totalTransactions']}', Icons.receipt, Colors.blue),
          _MetricData('Success Rate', '${data['successRate'].toStringAsFixed(1)}%', Icons.check_circle, Colors.green),
          _MetricData('Failed', '${data['failedTransactions']}', Icons.error, Colors.red),
        ]),
        const SizedBox(height: 32),
        _buildSectionTitle('Revenue Trend'),
        const SizedBox(height: 16),
        _buildRevenueChart(data),
        const SizedBox(height: 32),
        _buildSectionTitle('Transaction Distribution'),
        const SizedBox(height: 16),
        _buildTransactionPieChart(data),
      ],
    );
  }

  Widget _buildTripsReport() {
    final data = controller.getTripData();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMetricsGrid([
          _MetricData('Total Trips', '${data['totalTrips']}', Icons.local_taxi, Colors.blue),
          _MetricData('Completed', '${data['completedTrips']}', Icons.check_circle, Colors.green),
          _MetricData('Active', '${data['activeTrips']}', Icons.pending, Colors.orange),
          _MetricData('Cancelled', '${data['cancelledTrips']}', Icons.cancel, Colors.red),
        ]),
        const SizedBox(height: 32),
        _buildSectionTitle('Trip Status Distribution'),
        const SizedBox(height: 16),
        _buildTripStatusChart(data),
        const SizedBox(height: 32),
        _buildSectionTitle('Completion Rate'),
        const SizedBox(height: 16),
        _buildCompletionRateChart(data),
      ],
    );
  }

  Widget _buildUsersReport() {
    final data = controller.getUserData();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMetricsGrid([
          _MetricData('Total Users', '${data['totalUsers']}', Icons.people, Colors.purple),
          _MetricData('Active Users', '${data['activeUsers']}', Icons.person, Colors.blue),
          _MetricData('Growth Rate', '+12.5%', Icons.trending_up, Colors.green),
          _MetricData('Retention', '87%', Icons.repeat, Colors.orange),
        ]),
        const SizedBox(height: 32),
        _buildSectionTitle('User Growth Over Time'),
        const SizedBox(height: 16),
        _buildUserGrowthChart(),
        const SizedBox(height: 32),
        _buildSectionTitle('User Activity'),
        const SizedBox(height: 16),
        _buildUserActivityChart(),
      ],
    );
  }

  Widget _buildRidersReport() {
    final data = controller.getRiderData();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMetricsGrid([
          _MetricData('Total Riders', '${data['totalRiders']}', Icons.motorcycle, Colors.orange),
          _MetricData('Approved', '${data['approvedRiders']}', Icons.verified, Colors.green),
          _MetricData('Pending', '${data['pendingRiders']}', Icons.pending, Colors.orange),
          _MetricData('Approval Rate', '${data['approvalRate'].toStringAsFixed(1)}%', Icons.analytics, Colors.blue),
        ]),
        const SizedBox(height: 32),
        _buildSectionTitle('Rider Status Distribution'),
        const SizedBox(height: 16),
        _buildRiderStatusChart(data),
        const SizedBox(height: 32),
        _buildSectionTitle('Top Performers'),
        const SizedBox(height: 16),
        _buildTopRidersTable(),
      ],
    );
  }

  Widget _buildMetricsGrid(List<_MetricData> metrics) {
    return Row(
      children: metrics.map((metric) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: metric.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(metric.icon, color: metric.color, size: 20),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    metric.label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF718096),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    metric.value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A202C),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A202C),
      ),
    );
  }

  Widget _buildRevenueChart(Map<String, dynamic> data) {
    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    'KES ${(value / 1000).toStringAsFixed(0)}k',
                    style: const TextStyle(fontSize: 10, color: Color(0xFF718096)),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                  if (value.toInt() < months.length) {
                    return Text(
                      months[value.toInt()],
                      style: const TextStyle(fontSize: 10, color: Color(0xFF718096)),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                const FlSpot(0, 3000),
                const FlSpot(1, 4500),
                const FlSpot(2, 4000),
                const FlSpot(3, 5500),
                const FlSpot(4, 6000),
                const FlSpot(5, 7200),
              ],
              isCurved: true,
              color: const Color(0xFF0E9EDC),
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF0E9EDC).withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionPieChart(Map<String, dynamic> data) {
    final successful = data['successfulTransactions'] ?? 0;
    final failed = data['failedTransactions'] ?? 0;
    
    return SizedBox(
      height: 200,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: successful.toDouble(),
                    title: '${successful}',
                    color: Colors.green,
                    radius: 80,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: failed.toDouble(),
                    title: '${failed}',
                    color: Colors.red,
                    radius: 80,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(width: 24),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegendItem('Successful', Colors.green, successful),
              const SizedBox(height: 8),
              _buildLegendItem('Failed', Colors.red, failed),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTripStatusChart(Map<String, dynamic> data) {
    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10, color: Color(0xFF718096)),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final labels = ['Completed', 'Active', 'Cancelled'];
                  if (value.toInt() < labels.length) {
                    return Text(
                      labels[value.toInt()],
                      style: const TextStyle(fontSize: 10, color: Color(0xFF718096)),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: (data['completedTrips'] ?? 0).toDouble(),
                  color: Colors.green,
                  width: 40,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: (data['activeTrips'] ?? 0).toDouble(),
                  color: Colors.orange,
                  width: 40,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  toY: (data['cancelledTrips'] ?? 0).toDouble(),
                  color: Colors.red,
                  width: 40,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionRateChart(Map<String, dynamic> data) {
    final completionRate = data['completionRate'] ?? 0.0;
    
    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 150,
            width: 150,
            child: CircularProgressIndicator(
              value: completionRate / 100,
              strokeWidth: 15,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${completionRate.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A202C),
                ),
              ),
              const Text(
                'Completion Rate',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF718096),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserGrowthChart() {
    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10, color: Color(0xFF718096)),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                  if (value.toInt() < months.length) {
                    return Text(
                      months[value.toInt()],
                      style: const TextStyle(fontSize: 10, color: Color(0xFF718096)),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                const FlSpot(0, 10),
                const FlSpot(1, 15),
                const FlSpot(2, 20),
                const FlSpot(3, 25),
                const FlSpot(4, 32),
                const FlSpot(5, 36),
              ],
              isCurved: true,
              color: const Color(0xFF8B5CF6),
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF8B5CF6).withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserActivityChart() {
    return SizedBox(
      height: 200,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: 60,
                    title: '60%',
                    color: Colors.green,
                    radius: 80,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: 30,
                    title: '30%',
                    color: Colors.orange,
                    radius: 80,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: 10,
                    title: '10%',
                    color: Colors.red,
                    radius: 80,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(width: 24),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegendItem('Active', Colors.green, 60),
              const SizedBox(height: 8),
              _buildLegendItem('Occasional', Colors.orange, 30),
              const SizedBox(height: 8),
              _buildLegendItem('Inactive', Colors.red, 10),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRiderStatusChart(Map<String, dynamic> data) {
    final approved = data['approvedRiders'] ?? 0;
    final pending = data['pendingRiders'] ?? 0;
    
    return SizedBox(
      height: 200,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: approved.toDouble(),
                    title: '${approved}',
                    color: Colors.green,
                    radius: 80,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: pending.toDouble(),
                    title: '${pending}',
                    color: Colors.orange,
                    radius: 80,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(width: 24),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegendItem('Approved', Colors.green, approved),
              const SizedBox(height: 8),
              _buildLegendItem('Pending', Colors.orange, pending),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopRidersTable() {
    final topRiders = controller.dashboardController.leadingRiders.take(5).toList();
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFF7FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Rider Name',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A202C),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Trips',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A202C),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          ...topRiders.asMap().entries.map((entry) {
            final index = entry.key;
            final rider = entry.value;
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(
                  top: index > 0 ? const BorderSide(color: Color(0xFFE2E8F0)) : BorderSide.none,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      rider['name'] ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF1A202C),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      rider['trips'] ?? '0',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF718096),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, dynamic value) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: $value',
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF1A202C),
          ),
        ),
      ],
    );
  }
}

class _MetricData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  _MetricData(this.label, this.value, this.icon, this.color);
}