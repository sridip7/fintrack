import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../models/category.dart';
import '../widgets/transaction_list_item.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _searchQuery = '';
  String _activeFilter = 'All'; // 'All', 'Today', 'Week', 'Month', 'Year', 'Custom'
  DateTimeRange? _dateRangeFilter;

  void _applyQuickFilter(String filter) {
    setState(() {
      _activeFilter = filter;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      switch (filter) {
        case 'All':
          _dateRangeFilter = null;
          break;
        case 'Today':
          _dateRangeFilter = DateTimeRange(start: today, end: today);
          break;
        case 'Week':
          // Start of week (Monday)
          final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
          _dateRangeFilter = DateTimeRange(start: startOfWeek, end: today);
          break;
        case 'Month':
          final startOfMonth = DateTime(now.year, now.month, 1);
          final endOfMonth = DateTime(now.year, now.month + 1, 0); // Last day of month
          _dateRangeFilter = DateTimeRange(start: startOfMonth, end: endOfMonth);
          break;
        case 'Year':
          final startOfYear = DateTime(now.year, 1, 1);
          final endOfYear = DateTime(now.year, 12, 31);
          _dateRangeFilter = DateTimeRange(start: startOfYear, end: endOfYear);
          break;
      }
    });
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: now,
      initialDateRange: _dateRangeFilter,
      helpText: 'Select Custom Date Range',
      fieldStartHintText: 'dd/mm/yyyy',
      fieldEndHintText: 'dd/mm/yyyy',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _activeFilter = 'Custom';
        _dateRangeFilter = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final txProvider = Provider.of<TransactionProvider>(context);
    final userEmail = authProvider.currentUserEmail ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    // Filter transactions by search query and time filter
    final allTransactions = txProvider.transactions.where((tx) {
      // Time Filter Logic
      if (_dateRangeFilter != null) {
        final start = _dateRangeFilter!.start;
        final end = _dateRangeFilter!.end.add(const Duration(days: 1)); // Include transactions on the end day
        if (tx.date.isBefore(start) || tx.date.isAfter(end)) {
          return false;
        }
      }

      // Search Query Logic
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return tx.title.toLowerCase().contains(query) ||
          tx.category.displayName.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                hintStyle: TextStyle(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.4)
                      : Colors.black.withValues(alpha: 0.4),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.4)
                      : Colors.black.withValues(alpha: 0.4),
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),

          // Quick Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: ['All', 'Today', 'Week', 'Month', 'Year'].map((filter) {
                final isSelected = _activeFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        _applyQuickFilter(filter);
                      }
                    },
                    selectedColor: primaryColor,
                    backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          // Custom Date Range Picker Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _pickDateRange(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _activeFilter == 'Custom' ? primaryColor : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_month,
                            size: 20,
                            color: _activeFilter == 'Custom'
                                ? primaryColor
                                : (isDark ? Colors.white70 : Colors.black87),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _dateRangeFilter == null || _activeFilter != 'Custom'
                                  ? 'Custom Range...'
                                  : '${DateFormat('dd/MM/yyyy').format(_dateRangeFilter!.start)} - ${DateFormat('dd/MM/yyyy').format(_dateRangeFilter!.end)}',
                              style: TextStyle(
                                color: _activeFilter == 'Custom'
                                    ? primaryColor
                                    : (isDark ? Colors.white : Colors.black87),
                                fontWeight: _activeFilter == 'Custom' ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ),
                          if (_activeFilter == 'Custom')
                            GestureDetector(
                              onTap: () {
                                _applyQuickFilter('All');
                              },
                              child: Icon(Icons.close, size: 20, color: primaryColor),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Transaction count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
            child: Text(
              '${allTransactions.length} transaction${allTransactions.length == 1 ? '' : 's'}',
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.5)
                    : Colors.black.withValues(alpha: 0.5),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Transaction list
          Expanded(
            child: allTransactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchQuery.isEmpty && _dateRangeFilter == null
                              ? Icons.receipt_long
                              : Icons.search_off,
                          size: 56,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.2)
                              : Colors.black.withValues(alpha: 0.2),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty && _dateRangeFilter == null
                              ? 'No transactions yet'
                              : 'No matching transactions',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 4.0),
                    itemCount: allTransactions.length + 1, // +1 for bottom spacing
                    itemBuilder: (context, index) {
                      if (index == allTransactions.length) {
                        return const SizedBox(height: 80);
                      }
                      final transaction = allTransactions[index];
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
                          await txProvider.deleteTransaction(
                              userEmail, transaction.id);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            final controller = ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('"${transaction.title}" deleted'),
                                backgroundColor: const Color(0xFFEF4444),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 3),
                                action: SnackBarAction(
                                  label: 'UNDO',
                                  textColor: Colors.white,
                                  onPressed: () {
                                    txProvider.addTransaction(
                                        userEmail, transaction);
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
          ),
        ],
      ),
    );
  }
}
