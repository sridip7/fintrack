import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/summary_card.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/transaction_list_item.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final txProvider = Provider.of<TransactionProvider>(context);
    final userEmail = authProvider.currentUserEmail ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: txProvider.isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
              ),
            )
          : RefreshIndicator(
              onRefresh: () => txProvider.loadTransactions(userEmail),
              color: Theme.of(context).colorScheme.primary,
              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Financial summary card
                    SummaryCard(
                      totalBalance: txProvider.totalBalance,
                      totalIncome: txProvider.totalIncome,
                      totalExpenses: txProvider.totalExpenses,
                    ),
                    const SizedBox(height: 24),

                    // Quick analytics chart
                    CategoryPieChart(
                      categoryExpenses: txProvider.categoryExpenses,
                    ),
                    const SizedBox(height: 24),

                    // Recent transactions title
                    Text(
                      'Recent Transactions',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Scrollable transaction list
                    if (txProvider.transactions.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 56,
                              color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.2),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No transactions recorded yet',
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap the + button to add one!',
                              style: TextStyle(
                                color: isDark ? Colors.white.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.4),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: txProvider.recentTransactions.length,
                        itemBuilder: (context, index) {
                          final transaction = txProvider.recentTransactions[index];
                          return Dismissible(
                            key: Key(transaction.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6.0),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20.0),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            onDismissed: (direction) async {
                              // Perform delete
                              await txProvider.deleteTransaction(userEmail, transaction.id);

                              if (context.mounted) {
                                // Show confirmation snackbar with Undo
                                ScaffoldMessenger.of(context).clearSnackBars();
                                final controller = ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('"${transaction.title}" deleted'),
                                    backgroundColor: const Color(0xFFEF4444),
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 3),
                                    action: SnackBarAction(
                                      label: 'UNDO',
                                      textColor: Colors.white,
                                      onPressed: () {
                                        txProvider.addTransaction(userEmail, transaction);
                                      },
                                    ),
                                  ),
                                );
                                Future.delayed(const Duration(seconds: 3), () {
                                  try {
                                    controller.close();
                                  } catch (_) {}
                                });
                              }
                            },
                            child: TransactionListItem(transaction: transaction),
                          );
                        },
                      ),
                    
                    // Extra spacing at bottom for notched bottom navigation bar
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
    );
  }
}
