import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Study Planner',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> _goals = [
    {'subject': 'Mathématiques', 'hours': 3, 'done': false},
    {'subject': 'Flutter', 'hours': 5, 'done': true},
  ];

  void _deleteGoal(int index) {
    setState(() {
      _goals.removeAt(index);
    });
  }

  void _toggleGoal(int index) {
    setState(() {
      _goals[index]['done'] = !_goals[index]['done'];
    });
  }

  int get _totalGoals => _goals.length;
  int get _totalHours {
    int sum = 0;
    for (var g in _goals) {
      sum += g['hours'] as int;
    }
    return sum;
  }
  int get _doneCount {
    int count = 0;
    for (var g in _goals) {
      if (g['done'] == true) count++;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Study Planner'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              color: Colors.indigo.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(label: 'Goals', value: '$_totalGoals'),
                    _StatItem(label: 'Hours', value: '$_totalHours'),
                    _StatItem(label: 'Done', value: '$_doneCount'),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _goals.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.book_outlined, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('No goals yet — add one!'),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _goals.length,
                    itemBuilder: (context, index) {
                      final goal = _goals[index];
                      final bool isDone = goal['done'] as bool;
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: Icon(
                            Icons.circle,
                            color: isDone ? Colors.green : Colors.indigo,
                          ),
                          title: Text(
                            goal['subject'],
                            style: TextStyle(
                              decoration: isDone ? TextDecoration.lineThrough : null,
                              color: isDone ? Colors.grey : Colors.black,
                            ),
                          ),
                          subtitle: Text('${goal['hours']} heures'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  isDone ? Icons.check_circle : Icons.check_circle_outline,
                                ),
                                onPressed: () => _toggleGoal(index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteGoal(index),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}