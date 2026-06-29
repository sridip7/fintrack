import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/settings_provider.dart';

class WeeklyBarChart extends StatelessWidget {
  final List<Transaction> transactions;

  const WeeklyBarChart({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Generate the last 7 days (including today)
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final List<DateTime> last7Days = List.generate(7, (i) {
      return todayMidnight.subtract(Duration(days: 6 - i));
    });

    // Map each day to total expense
    final Map<DateTime, double> dailyExpenses = {};
    for (var day in last7Days) {
      dailyExpenses[day] = 0.0;
    }

    for (var tx in transactions) {
      if (tx.type == TransactionType.expense) {
        final txMidnight = DateTime(tx.date.year, tx.date.month, tx.date.day);
        if (dailyExpenses.containsKey(txMidnight)) {
          dailyExpenses[txMidnight] = (dailyExpenses[txMidnight] ?? 0.0) + tx.amount;
        }
      }
    }

    final double maxExpense = dailyExpenses.values.fold(0.0, (max, val) => val > max ? val : max);
    final double maxY = maxExpense == 0 ? 100.0 : maxExpense * 1.15;

    // Build bar groups
    final List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < 7; i++) {
      final day = last7Days[i];
      final amount = dailyExpenses[day] ?? 0.0;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: amount,
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              width: 14,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: maxY,
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Expenses (Last 7 Days)',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => const Color(0xFF1E293B),
                    tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final day = last7Days[group.x];
                      final weekdayStr = DateFormat.E().format(day);
                      return BarTooltipItem(
                        '$weekdayStr\n${settings.currencySymbol}${rod.toY.toStringAsFixed(2)}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= 7) return const SizedBox();
                        final day = last7Days[index];
                        final weekdayName = DateFormat.E().format(day)[0]; // First letter, e.g., 'M', 'T'
                        return SideTitleWidget(
                          meta: meta,
                          space: 8,
                          child: Text(
                            weekdayName,
                            style: TextStyle(
                              color: isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.5),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: barGroups,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
