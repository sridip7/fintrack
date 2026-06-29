import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/weekly_bar_chart.dart';

import '../providers/settings_provider.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final txProvider = Provider.of<TransactionProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);
    final currencyFormatter = NumberFormat.currency(symbol: settings.currencySymbol, decimalDigits: 2);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate highest spending category
    TransactionCategory? highestCategory;
    double highestAmount = 0.0;
    
    txProvider.categoryExpenses.forEach((category, amount) {
      if (amount > highestAmount) {
        highestAmount = amount;
        highestCategory = category;
      }
    });

    // Calculate lowest spending category
    TransactionCategory? lowestCategory;
    double lowestAmount = double.infinity;
    
    txProvider.categoryExpenses.forEach((category, amount) {
      if (amount > 0 && amount < lowestAmount) {
        lowestAmount = amount;
        lowestCategory = category;
      }
    });

    // Calculate average daily spending in the last 7 days
    double totalLast7Days = 0.0;
    final now = DateTime.now();
    final sevenDaysAgo = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 7));
    
    for (var tx in txProvider.transactions) {
      if (tx.type == TransactionType.expense && tx.date.isAfter(sevenDaysAgo)) {
        totalLast7Days += tx.amount;
      }
    }
    final double avgDailySpending = totalLast7Days / 7;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Category distribution card
            CategoryPieChart(categoryExpenses: txProvider.categoryExpenses),
            const SizedBox(height: 20),

            // Weekly bar chart comparison
            WeeklyBarChart(transactions: txProvider.transactions),
            const SizedBox(height: 20),

            // Insights panel
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                      : [Colors.white, const Color(0xFFF1F5F9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.3)),
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
                  Row(
                    children: [
                      Icon(Icons.analytics, color: Theme.of(context).colorScheme.primary, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Monthly Insights',
                        style: TextStyle(
                          color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.8),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Top category insights
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (highestCategory?.color ?? const Color(0xFF6366F1)).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          highestCategory?.icon ?? Icons.shopping_bag,
                          color: highestCategory?.color ?? const Color(0xFF6366F1),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Highest Expense Category',
                              style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 12),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              highestCategory != null
                                  ? '${highestCategory!.displayName} (${currencyFormatter.format(highestAmount)})'
                                  : 'No spending recorded yet',
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Lowest category insights
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (lowestCategory?.color ?? const Color(0xFFF59E0B)).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          lowestCategory?.icon ?? Icons.shopping_basket,
                          color: lowestCategory?.color ?? const Color(0xFFF59E0B),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lowest Expense Category',
                              style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 12),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              lowestCategory != null
                                  ? '${lowestCategory!.displayName} (${currencyFormatter.format(lowestAmount)})'
                                  : 'No spending recorded yet',
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Daily Average spending insights
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.query_stats,
                          color: Color(0xFF10B981),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Average Daily Spending (Last 7 Days)',
                              style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 12),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              currencyFormatter.format(avgDailySpending),
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Extra spacing at bottom for notched bottom navigation bar
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
