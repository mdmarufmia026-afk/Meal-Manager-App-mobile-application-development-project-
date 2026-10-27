
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/member.dart';
import '../models/meal.dart';
import '../models/expense.dart';
import '../models/deposit.dart';
import '../services/database_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late int selectedMonth;
  late int selectedYear;

  final List<String> monthNames = const [
    'January', 'February', 'March', 'April',
    'May', 'June', 'July', 'August',
    'September', 'October', 'November', 'December',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedMonth = now.month;
    selectedYear = now.year;
  }

  bool isSelectedMonth(DateTime date) {
    return date.month == selectedMonth &&
        date.year == selectedYear;
  }

  @override
  Widget build(BuildContext context) {
    final listenable = Listenable.merge([
      Hive.box('members').listenable(),
      Hive.box('meals').listenable(),
      Hive.box('expenses').listenable(),
      Hive.box('deposits').listenable(),
    ]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Report'),
        centerTitle: true,
      ),
      body: AnimatedBuilder(
        animation: listenable,
        builder: (context, child) {
          final members = DatabaseService.getMembers();

          final List<Meal> meals =
          DatabaseService.getMeals()
              .where((meal) => isSelectedMonth(meal.date))
              .toList();

          final List<Expense> expenses =
          DatabaseService.getExpenses()
              .where((expense) => isSelectedMonth(expense.date))
              .toList();

          final List<Deposit> deposits =
          DatabaseService.getDeposits()
              .where((deposit) => isSelectedMonth(deposit.date))
              .toList();

          final int totalMeals = meals.fold<int>(
            0,
                (sum, meal) => sum + meal.count,
          );

          final double totalExpense = expenses.fold<double>(
            0,
                (sum, expense) => sum + expense.amount,
          );

          final double totalDeposit = deposits.fold<double>(
            0,
                (sum, deposit) => sum + deposit.amount,
          );

          final double mealRate = totalMeals > 0
              ? totalExpense / totalMeals
              : 0;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // MONTH AND YEAR SELECTOR
              const Text(
                'Select Report Month',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: selectedMonth,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Month',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(
                        12,
                            (index) => DropdownMenuItem<int>(
                          value: index + 1,
                          child: Text(monthNames[index]),
                        ),
                      ),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedMonth = value;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: selectedYear,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Year',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(7, (index) {
                        final year = DateTime.now().year - 3 + index;
                        return DropdownMenuItem<int>(
                          value: year,
                          child: Text('$year'),
                        );
                      }),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedYear = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // MONTHLY SUMMARY
              _summaryCard(
                'Total Meals',
                '$totalMeals',
                Icons.restaurant,
              ),
              _summaryCard(
                'Total Expense',
                '৳ ${totalExpense.toStringAsFixed(2)}',
                Icons.shopping_cart,
              ),
              _summaryCard(
                'Total Deposit',
                '৳ ${totalDeposit.toStringAsFixed(2)}',
                Icons.account_balance_wallet,
              ),
              _summaryCard(
                'Meal Rate',
                '৳ ${mealRate.toStringAsFixed(2)}',
                Icons.calculate,
              ),

              const SizedBox(height: 20),

              // MEMBER-WISE SETTLEMENT
              const Text(
                'Member-wise Monthly Settlement',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              const Text(
                'Balance = Monthly Deposit - Monthly Meal Cost',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 8),

              if (members.isEmpty)
                const Text('No members found.'),

              ...members.map((Member member) {
                final int memberMeals = meals
                    .where((meal) => meal.memberName == member.name)
                    .fold<int>(
                  0,
                      (sum, meal) => sum + meal.count,
                );

                final double memberDeposit = deposits
                    .where((deposit) =>
                deposit.memberName == member.name)
                    .fold<double>(
                  0,
                      (sum, deposit) => sum + deposit.amount,
                );

                final double mealCost = memberMeals * mealRate;
                final double balance = memberDeposit - mealCost;

                String status;
                if (balance > 0.009) {
                  status = 'Receive ৳${balance.toStringAsFixed(2)}';
                } else if (balance < -0.009) {
                  status = 'Pay ৳${(-balance).toStringAsFixed(2)}';
                } else {
                  status = 'Settled';
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        _detailRow('Meals', '$memberMeals'),
                        _detailRow(
                          'Deposit this month',
                          '৳ ${memberDeposit.toStringAsFixed(2)}',
                        ),
                        _detailRow(
                          'Meal cost',
                          '৳ ${mealCost.toStringAsFixed(2)}',
                        ),
                        const SizedBox(height: 6),
                        Text(
                          status,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: balance > 0.009
                                ? Colors.green
                                : balance < -0.009
                                ? Colors.red
                                : Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 20),

              // MONTHLY EXPENSE HISTORY
              const Text(
                'Monthly Expense History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              if (expenses.isEmpty)
                const Text('No expenses for this month.'),

              ...expenses.map((Expense expense) {
                return Card(
                  child: ListTile(
                    title: Text(expense.title),
                    subtitle: Text(
                      '${expense.date.day}/'
                          '${expense.date.month}/'
                          '${expense.date.year}',
                    ),
                    trailing: Text(
                      '৳ ${expense.amount.toStringAsFixed(2)}',
                    ),
                  ),
                );
              }),

              const SizedBox(height: 20),

              // MONTHLY DEPOSIT HISTORY
              const Text(
                'Monthly Deposit History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              if (deposits.isEmpty)
                const Text(
                  'No deposits recorded for this month.',
                ),

              ...deposits.map((Deposit deposit) {
                return Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.green,
                    ),
                    title: Text(deposit.memberName),
                    subtitle: Text(
                      '${deposit.date.day}/'
                          '${deposit.date.month}/'
                          '${deposit.date.year}',
                    ),
                    trailing: Text(
                      '৳ ${deposit.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _summaryCard(
      String title,
      String value,
      IconData icon,
      ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 30),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(title)),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
