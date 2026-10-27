
import 'package:hive/hive.dart';

import '../models/member.dart';
import '../models/meal.dart';
import '../models/expense.dart';
import '../models/deposit.dart';

class DatabaseService {
  static final Box membersBox = Hive.box('members');
  static final Box mealsBox = Hive.box('meals');
  static final Box expensesBox = Hive.box('expenses');
  static final Box depositsBox = Hive.box('deposits');

  // MEMBERS

  static Future<void> addMember(Member member) async {
    await membersBox.add(member.toMap());
  }

  static List<Member> getMembers() {
    return membersBox.values
        .map((e) => Member.fromMap(e))
        .toList();
  }

  static Future<void> deleteMember(int index) async {
    // Keep meal and deposit history unchanged.
    await membersBox.deleteAt(index);
  }

  // MEALS

  static Future<void> addMeal(Meal meal) async {
    await mealsBox.add(meal.toMap());
  }

  static List<Meal> getMeals() {
    return mealsBox.values
        .map((e) => Meal.fromMap(e))
        .toList();
  }

  // EXPENSES

  static Future<void> addExpense(Expense expense) async {
    await expensesBox.add(expense.toMap());
  }

  static List<Expense> getExpenses() {
    return expensesBox.values
        .map((e) => Expense.fromMap(e))
        .toList();
  }

  // DEPOSITS

  static Future<void> addDeposit(Deposit deposit) async {
    await depositsBox.add(deposit.toMap());
  }

  static List<Deposit> getDeposits() {
    return depositsBox.values
        .map((e) => Deposit.fromMap(e))
        .toList();
  }
}
