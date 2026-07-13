import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFFF5F5F7);
  static const surface = Color(0xFFFBF9F8);
  static const primary = Color(0xFF1A237E);
  static const onSurface = Color(0xFF1B1C1C);
  static const onSurfaceVariant = Color(0xFF454652);
  static const outline = Color(0xFFE0E0E0);
  static const success = Color(0xFF2E7D32);
  static const successLight = Color(0xFF5AA958);
  static const progressBar = Color(0xFFEAE8E7);
  static const cardDone = Color(0xFFF0EDED);
  static const inputFill = Color(0xFFEEEEEE);
  static const error = Color(0xFFBA1A1A);
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Study Planner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.surface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.primary,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.inputFill,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.error, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
          labelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.6,
            color: AppColors.onSurfaceVariant,
          ),
          hintStyle: const TextStyle(
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
          ),
          errorStyle: const TextStyle(fontSize: 12, color: AppColors.error),
        ),
      ),
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

  Future<void> _openAddGoalScreen() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => const AddGoalScreen()),
    );

    if (result != null && mounted) {
      setState(() {
        _goals.add(result);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${result['subject']}" added to your goals'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primary,
        ),
      );
    }
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

  static const _pageMargin = 20.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('My Study Planner (G6)'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.outline),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: _pageMargin),
            child: _DailyProgressBar(done: _doneCount, total: _totalGoals),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: _pageMargin),
            child: _StatsCard(
              goals: _totalGoals,
              hours: _totalHours,
              done: _doneCount,
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: _pageMargin),
            child: Text(
              "Today's Focus",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _goals.isEmpty
                ? const _EmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _pageMargin,
                    ),
                    itemCount: _goals.length,
                    itemBuilder: (context, index) {
                      final goal = _goals[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _GoalCard(
                          subject: goal['subject'] as String,
                          hours: goal['hours'] as int,
                          isDone: goal['done'] as bool,
                          onToggle: () => _toggleGoal(index),
                          onDelete: () => _deleteGoal(index),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddGoalScreen,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _hoursController = TextEditingController();
  final _subjectFocus = FocusNode();
  bool _isSaving = false;

  static const _pageMargin = 20.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _subjectFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _hoursController.dispose();
    _subjectFocus.dispose();
    super.dispose();
  }

  String? _validateSubject(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Subject cannot be empty';
    }
    return null;
  }

  String? _validateHours(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Hours cannot be empty';
    }
    final hours = int.tryParse(value.trim());
    if (hours == null) {
      return 'Please enter a valid number';
    }
    if (hours <= 0) {
      return 'Hours must be greater than 0';
    }
    return null;
  }

  Future<void> _saveGoal() async {
    if (_isSaving) return;

    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);

    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'subject': _subjectController.text.trim(),
        'hours': int.parse(_hoursController.text.trim()),
        'done': false,
      });
      return;
    }

    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Goal'),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, color: AppColors.outline),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(_pageMargin),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'New Study Goal',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Add a subject and how many hours you plan to study.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _subjectController,
                  focusNode: _subjectFocus,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'SUBJECT',
                    hintText: 'e.g., Flutter Programming',
                  ),
                  validator: _validateSubject,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _hoursController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'HOURS',
                    hintText: 'e.g., 3',
                  ),
                  validator: _validateHours,
                  onFieldSubmitted: (_) => _saveGoal(),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _saveGoal,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.primary.withValues(
                        alpha: 0.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Save Goal'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0FF),
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.menu_book_outlined,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No goals yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Plan your study sessions and track your progress. Tap the + button to add your first goal.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.outline),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 18, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text(
                    'ADD YOUR FIRST GOAL',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.8,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyProgressBar extends StatelessWidget {
  final int done;
  final int total;

  const _DailyProgressBar({required this.done, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.progressBar,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'DAILY PROGRESS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.8,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          Text(
            '$done/$total Done',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final int goals;
  final int hours;
  final int done;

  const _StatsCard({
    required this.goals,
    required this.hours,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _StatItem(
                icon: Icons.format_list_bulleted,
                iconColor: AppColors.primary,
                value: '$goals',
                label: 'GOALS',
              ),
            ),
            const VerticalDivider(width: 1, color: AppColors.outline),
            Expanded(
              child: _StatItem(
                icon: Icons.timer_outlined,
                iconColor: AppColors.primary,
                value: '$hours',
                label: 'HOURS',
              ),
            ),
            const VerticalDivider(width: 1, color: AppColors.outline),
            Expanded(
              child: _StatItem(
                icon: Icons.check_circle,
                iconColor: AppColors.success,
                value: '$done',
                label: 'DONE',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.8,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final String subject;
  final int hours;
  final bool isDone;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _GoalCard({
    required this.subject,
    required this.hours,
    required this.isDone,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('$subject-$hours'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Material(
        color: isDone ? AppColors.cardDone : Colors.white,
        borderRadius: BorderRadius.circular(8),
        elevation: 0,
        child: InkWell(
          onTap: onToggle,
          onLongPress: onDelete,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: isDone
                          ? AppColors.successLight
                          : AppColors.primary,
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(8),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    child: Icon(
                      isDone ? Icons.check_circle : Icons.circle_outlined,
                      color: isDone
                          ? AppColors.success
                          : AppColors.onSurfaceVariant,
                      size: 24,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subject,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDone
                                  ? AppColors.onSurfaceVariant
                                  : AppColors.onSurface,
                              decoration: isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$hours Hours',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
