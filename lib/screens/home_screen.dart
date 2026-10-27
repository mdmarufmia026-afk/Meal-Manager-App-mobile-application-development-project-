import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../services/database_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('members').listenable(),
      builder: (context, membersBox, child) {
        return ValueListenableBuilder(
          valueListenable: Hive.box('meals').listenable(),
          builder: (context, mealsBox, child) {
            return ValueListenableBuilder(
              valueListenable: Hive.box('expenses').listenable(),
              builder: (context, expensesBox, child) {
                final members = DatabaseService.getMembers();
                final meals = DatabaseService.getMeals();
                final expenses = DatabaseService.getExpenses();

                int totalMeals = 0;

                for (var meal in meals) {
                  totalMeals += meal.count;
                }

                double totalExpense = 0;

                for (var expense in expenses) {
                  totalExpense += expense.amount;
                }

                double mealRate = totalMeals == 0
                    ? 0
                    : totalExpense / totalMeals;

                return Scaffold(
                  appBar: AppBar(
                    title: const Text('Meal Manager'),
                    centerTitle: true,
                  ),

                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [

                        const Text(
                          'Dashboard',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          children: [

                            Expanded(
                              child: _dashboardCard(
                                'Members',
                                members.length.toString(),
                                Icons.people,
                                Colors.blue,
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: _dashboardCard(
                                'Total Meals',
                                totalMeals.toString(),
                                Icons.restaurant,
                                Colors.green,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [

                            Expanded(
                              child: _dashboardCard(
                                'Expense',
                                '৳${totalExpense.toStringAsFixed(0)}',
                                Icons.money,
                                Colors.orange,
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: _dashboardCard(
                                'Meal Rate',
                                '৳${mealRate.toStringAsFixed(2)}',
                                Icons.calculate,
                                Colors.purple,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        const Text(
                          'Recent Meals',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        if (meals.isEmpty)
                          const Card(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Center(
                                child: Text(
                                  'No meal data yet.',
                                ),
                              ),
                            ),
                          ),

                        ...meals.reversed.take(5).map(
                              (meal) {
                            return Card(
                              child: ListTile(
                                leading: const CircleAvatar(
                                  child: Icon(Icons.restaurant),
                                ),

                                title: Text(meal.memberName),

                                subtitle: Text(
                                  '${meal.date.day}/${meal.date.month}/${meal.date.year}',
                                ),

                                trailing: Text(
                                  '${meal.count} meal',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _dashboardCard(
      String title,
      String value,
      IconData icon,
      Color color,
      ) {
    return Card(
      elevation: 3,

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            Icon(
              icon,
              size: 35,
              color: color,
            ),

            const SizedBox(height: 8),

            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}