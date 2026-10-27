
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/member.dart';
import '../models/deposit.dart';
import '../services/database_service.dart';

class MemberScreen extends StatefulWidget {
  const MemberScreen({super.key});

  @override
  State<MemberScreen> createState() => _MemberScreenState();
}

class _MemberScreenState extends State<MemberScreen> {
  late int selectedMonth;
  late int selectedYear;

  final int currentYear = DateTime.now().year;

  final List<String> monthNames = const [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();
    selectedMonth = DateTime.now().month;
    selectedYear = DateTime.now().year;
  }

  @override
  Widget build(BuildContext context) {
    final membersBox = Hive.box('members');
    final depositsBox = Hive.box('deposits');

    return AnimatedBuilder(
      animation: Listenable.merge([
        membersBox.listenable(),
        depositsBox.listenable(),
      ]),
      builder: (context, child) {
        final members = DatabaseService.getMembers();
        final deposits = DatabaseService.getDeposits();

        // Calculate a member's deposit for the selected month.
        double getMonthlyDeposit(String memberName) {
          return deposits
              .where((deposit) =>
          deposit.memberName == memberName &&
              deposit.date.month == selectedMonth &&
              deposit.date.year == selectedYear)
              .fold<double>(
            0.0,
                (total, deposit) => total + deposit.amount,
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Members'),
            centerTitle: true,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddMemberDialog(context),
            tooltip: 'Add Member',
            child: const Icon(Icons.person_add),
          ),
          body: Column(
            children: [
              // Month and year selectors.
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: selectedMonth,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Month',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
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
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        items: List.generate(
                          7,
                              (index) {
                            final year = currentYear - 3 + index;
                            return DropdownMenuItem<int>(
                              value: year,
                              child: Text(year.toString()),
                            );
                          },
                        ),
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
              ),

              // Selected month summary.
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                child: Card(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer,
                  child: ListTile(
                    leading: const Icon(Icons.account_balance_wallet),
                    title: Text(
                      'Total Deposit - '
                          '${monthNames[selectedMonth - 1]} $selectedYear',
                    ),
                    subtitle: Text(
                      '৳${deposits
                          .where((deposit) =>
                      deposit.date.month == selectedMonth &&
                          deposit.date.year == selectedYear)
                          .fold<double>(
                        0.0,
                            (total, deposit) => total + deposit.amount,
                      )
                          .toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              // Member list.
              Expanded(
                child: members.isEmpty
                    ? const Center(
                  child: Text(
                    'No members added yet.',
                    style: TextStyle(fontSize: 18),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    final monthlyDeposit =
                    getMonthlyDeposit(member.name);

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            member.name.isNotEmpty
                                ? member.name[0].toUpperCase()
                                : '?',
                          ),
                        ),
                        title: Text(
                          member.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Monthly Deposit: ৳'
                              '${monthlyDeposit.toStringAsFixed(2)}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Add Deposit',
                              icon: const Icon(
                                Icons.add_card,
                                color: Colors.green,
                              ),
                              onPressed: () {
                                _showAddDepositDialog(
                                  context,
                                  index,
                                  member,
                                );
                              },
                            ),
                            IconButton(
                              tooltip: 'Delete Member',
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () async {
                                final confirm =
                                await showDialog<bool>(
                                  context: context,
                                  builder: (dialogContext) =>
                                      AlertDialog(
                                        title: const Text(
                                          'Delete Member',
                                        ),
                                        content: Text(
                                          'Delete ${member.name}?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(
                                                  dialogContext,
                                                  false,
                                                ),
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () =>
                                                Navigator.pop(
                                                  dialogContext,
                                                  true,
                                                ),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                );

                                if (confirm == true) {
                                  await DatabaseService
                                      .deleteMember(index);
                                }
                              },
                            ),
                          ],
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

  // Add a new member.
  void _showAddMemberDialog(BuildContext context) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Member'),
        content: TextField(
          controller: nameController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Member Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();

              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a member name.'),
                  ),
                );
                return;
              }

              await DatabaseService.addMember(
                Member(name: name, deposit: 0),
              );

              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // Add a deposit with its date.
  void _showAddDepositDialog(
      BuildContext context,
      int index,
      Member member,
      ) {
    final amountController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text('Add Deposit - ${member.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  keyboardType:
                  const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Deposit Amount',
                    prefixText: '৳ ',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_month),
                  title: const Text('Deposit Date'),
                  subtitle: Text(
                    '${selectedDate.day}/'
                        '${selectedDate.month}/'
                        '${selectedDate.year}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_calendar),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: dialogContext,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );

                      if (picked != null) {
                        setDialogState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(
                  amountController.text.trim(),
                );

                if (amount == null ||
                    !amount.isFinite ||
                    amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Enter a valid amount.'),
                    ),
                  );
                  return;
                }

                // Save the dated deposit transaction.
                final deposit = Deposit(
                  memberName: member.name,
                  amount: amount,
                  date: selectedDate,
                );

                await Hive.box('deposits').add(deposit.toMap());

                // Also maintain the member's lifetime deposit total.
                final updatedMember = Member(
                  name: member.name,
                  deposit: member.deposit + amount,
                );

                await Hive.box('members').putAt(
                  index,
                  updatedMember.toMap(),
                );

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Deposit saved successfully.'),
                    ),
                  );
                }
              },
              child: const Text('Save Deposit'),
            ),
          ],
        ),
      ),
    );
  }
}
