import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/history_provider.dart';
import '../models/water_data.dart';
import '../utils/constants.dart';
import '../utils/water_data_stats.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Column(
          children: [
            Text(
              'Historical Data',
              style: AppStyles.headingStyle,
            ),
            SizedBox(height: 4),
            Text(
              'Trends and patterns',
              style: AppStyles.captionStyle,
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 56,
        leading: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            color: Theme.of(context).colorScheme.primary,
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.history_rounded,
                      color: AppColors.primary,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Data Yet',
                    style: AppStyles.headingStyle,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Historical data will appear as readings are collected',
                    textAlign: TextAlign.center,
                    style: AppStyles.labelStyle,
                  ),
                ],
              ),
            )
          : ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                // Statistics section
                _buildStatisticsSection(context, history),
                const SizedBox(height: 28),
                _buildChartCard(
                  'pH Level',
                  history,
                  (d) => d.ph,
                  Colors.teal,
                  'Measures acidity or alkalinity',
                ),
                const SizedBox(height: 20),
                _buildChartCard(
                  'TDS (ppm)',
                  history,
                  (d) => d.tds,
                  Colors.blue,
                  'Total Dissolved Solids',
                ),
                const SizedBox(height: 20),
                _buildChartCard(
                  'Turbidity (NTU)',
                  history,
                  (d) => d.turbidity,
                  Colors.brown,
                  'Water clarity measurement',
                ),
                const SizedBox(height: 20),
                _buildChartCard(
                  'Temperature (°C)',
                  history,
                  (d) => d.temperature,
                  Colors.orange,
                  'Water temperature',
                ),
                const SizedBox(height: 20),
              ],
            ),
    );
  }

  Widget _buildChartCard(
    String title,
    List<WaterData> data,
    double Function(WaterData) selector,
    Color color,
    String description,
  ) {
    final spots = List<FlSpot>.generate(
      data.length,
      (index) => FlSpot(index.toDouble(), selector(data[index])),
    );
    final showDots = data.length <= 10;
    final average = data.isNotEmpty
        ? data.fold(0.0, (sum, item) => sum + selector(item)) / data.length
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.card,
            AppColors.surfaceOverlay,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: color.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.show_chart_rounded,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppStyles.headingStyle,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: AppStyles.captionStyle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    drawVerticalLine: false,
                    horizontalInterval: null,
                  ),
                  titlesData: const FlTitlesData(
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: const FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: color,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: showDots),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withValues(alpha: 0.15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total readings: ${data.length}',
                  style: AppStyles.captionStyle,
                ),
                Text(
                  'Average: ${average.toStringAsFixed(2)}',
                  style: AppStyles.captionStyle.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(BuildContext context, List<WaterData> history) {
    final stats = WaterDataStats.fromList(history);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistics',
          style: AppStyles.titleStyle.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildStatCard(context, 'pH Level', stats.minPh, stats.avgPh,
                stats.maxPh, Icons.science_rounded),
            _buildStatCard(context, 'TDS (ppm)', stats.minTds, stats.avgTds,
                stats.maxTds, Icons.water_drop_rounded),
            _buildStatCard(context, 'Turbidity (NTU)', stats.minTurbidity,
                stats.avgTurbidity, stats.maxTurbidity, Icons.blur_on_rounded),
            _buildStatCard(
                context,
                'Temperature (°C)',
                stats.minTemperature,
                stats.avgTemperature,
                stats.maxTemperature,
                Icons.thermostat_rounded),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String label, double min,
      double avg, double max, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .primary
              .withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: AppStyles.labelStyle.copyWith(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildStatRow('Min', min),
          const SizedBox(height: 4),
          _buildStatRow('Avg', avg),
          const SizedBox(height: 4),
          _buildStatRow('Max', max),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppStyles.labelStyle.copyWith(fontSize: 10),
        ),
        Text(
          value.toStringAsFixed(2),
          style: AppStyles.labelStyle.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
