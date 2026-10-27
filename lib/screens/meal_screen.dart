import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/meal.dart';
import '../models/member.dart';
import '../services/database_service.dart';

class MealScreen extends StatelessWidget {
  const MealScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mealsBox = Hive.box('meals');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meals'),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showMealDialog(context);
        },
        child: const Icon(Icons.add),
      ),

      body: ValueListenableBuilder(
        valueListenable: mealsBox.listenable(),
        builder: (context, Box box, _) {
          final meals = DatabaseService.getMeals();

          if (meals.isEmpty) {
            return const Center(
              child: Text(
                'No meal records yet',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: meals.length,
            itemBuilder: (context, index) {
              final meal = meals[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      meal.count.toString(),
                    ),
                  ),

                  title: Text(
                    meal.memberName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: Text(
                    '${meal.count} meal(s) • '
                        '${meal.date.day}/${meal.date.month}/${meal.date.year}',
                  ),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      // EDIT BUTTON
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _showMealDialog(
                            context,
                            editIndex: index,
                            existingMeal: meal,
                          );
                        },
                      ),

                      // DELETE BUTTON
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _deleteMeal(
                            context,
                            index,
                            meal,
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
      ),
    );
  }

  // ==================================================
  // ADD / EDIT MEAL
  // ==================================================

  void _showMealDialog(
      BuildContext context, {
        int? editIndex,
        Meal? existingMeal,
      }) {
    final members = DatabaseService.getMembers();

    if (members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a member first.'),
        ),
      );
      return;
    }

    String selectedMember =
        existingMeal?.memberName ?? members.first.name;

    final countController = TextEditingController(
      text: existingMeal?.count.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            editIndex == null ? 'Add Meal' : 'Edit Meal',
          ),

          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // MEMBER
                  DropdownButtonFormField<String>(
                    initialValue: selectedMember,
                    decoration: const InputDecoration(
                      labelText: 'Member',
                      border: OutlineInputBorder(),
                    ),

                    items: members.map((Member member) {
                      return DropdownMenuItem<String>(
                        value: member.name,
                        child: Text(member.name),
                      );
                    }).toList(),

                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedMember = value;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 15),

                  // MEAL COUNT
                  TextField(
                    controller: countController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Meal Count',
                      hintText: 'Example: 1',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              );
            },
          ),

          actions: [

            // CANCEL
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),

            // ADD / UPDATE
            ElevatedButton(
              onPressed: () async {
                final count = int.tryParse(
                  countController.text.trim(),
                );

                if (count == null || count <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter a valid meal count.',
                      ),
                    ),
                  );
                  return;
                }

                final mealsBox = Hive.box('meals');

                // ============================
                // EDIT
                // ============================

                if (editIndex != null) {
                  final oldMeal = existingMeal!;

                  final updatedMeal = Meal(
                    memberName: selectedMember,
                    date: oldMeal.date,
                    count: count,
                  );

                  await mealsBox.putAt(
                    editIndex,
                    updatedMeal.toMap(),
                  );
                }

                // ============================
                // ADD
                // ============================

                else {
                  final newMeal = Meal(
                    memberName: selectedMember,
                    date: DateTime.now(),
                    count: count,
                  );

                  await DatabaseService.addMeal(newMeal);
                }

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },

              child: Text(
                editIndex == null ? 'Add' : 'Update',
              ),
            ),
          ],
        );
      },
    );
  }

  // ==================================================
  // DELETE MEAL
  // ==================================================

  void _deleteMeal(
      BuildContext context,
      int index,
      Meal meal,
      ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Meal'),

          content: Text(
            'Are you sure you want to delete '
                '${meal.count} meal(s) of ${meal.memberName}?',
          ),

          actions: [

            // CANCEL
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),

            // DELETE
            ElevatedButton(
              onPressed: () async {
                final mealsBox = Hive.box('meals');

                await mealsBox.deleteAt(index);

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Meal deleted successfully.',
                      ),
                    ),
                  );
                }
              },

              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}