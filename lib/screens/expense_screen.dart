import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/expense.dart';
import '../services/database_service.dart';

class ExpenseScreen extends StatelessWidget {
  const ExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('expenses').listenable(),
      builder: (context, box, child) {
        final expenses = DatabaseService.getExpenses();

        double totalExpense = 0;

        for (var expense in expenses) {
          totalExpense += expense.amount;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Expenses'),
            centerTitle: true,
          ),

          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _showAddExpenseDialog(context);
            },
            child: const Icon(Icons.add),
          ),

          body: Column(
            children: [
              // Total expense
              Card(
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(18),

                  child: Row(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet,
                        size: 35,
                      ),

                      const SizedBox(width: 15),

                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [
                          const Text(
                            'Total Expense',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            '৳${totalExpense.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Expense history
              Expanded(
                child: expenses.isEmpty
                    ? const Center(
                  child: Text(
                    'No expenses added yet.',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(10),

                  itemCount: expenses.length,

                  itemBuilder: (context, index) {
                    final expense =
                    expenses[expenses.length -
                        1 -
                        index];

                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.shopping_cart),
                        ),

                        title: Text(
                          expense.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        subtitle: Text(
                          '${expense.date.day}/${expense.date.month}/${expense.date.year}',
                        ),

                        trailing: Text(
                          '৳${expense.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text('Add Expense'),

          content: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              TextField(
                controller: titleController,

                decoration: const InputDecoration(
                  labelText: 'Expense Title',
                  hintText: 'Example: Rice, Chicken, Gas',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: amountController,

                keyboardType:
                const TextInputType.numberWithOptions(
                  decimal: true,
                ),

                decoration: const InputDecoration(
                  labelText: 'Amount',
                  hintText: 'Example: 1200',
                  prefixText: '৳ ',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () async {
                final title =
                titleController.text.trim();

                final amount =
                    double.tryParse(
                      amountController.text.trim(),
                    ) ??
                        0;

                if (title.isEmpty || amount <= 0) {
                  return;
                }
                final now = DateTime.now();

                final expense = Expense(
                  title: title,
                  amount: amount,
                  date: now,
                );

                await DatabaseService.addExpense(
                  expense,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },

              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}