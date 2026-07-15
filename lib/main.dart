import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

// LOGIC — SQLite database instance (created once and reused)
Database? _database;

// LOGIC — Open or create the SQLite database file on the device
Future<Database> initializeDatabase() async {
  if (_database != null) return _database!;

  try {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'study_planner.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE goals (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            subject TEXT NOT NULL,
            hours INTEGER NOT NULL,
            done INTEGER NOT NULL DEFAULT 0
          )
        ''');
        debugPrint('Goals table created successfully.');
      },
    );

    debugPrint('Database initialized at: $path');
    return _database!;
  } catch (e) {
    debugPrint('Database initialization failed: $e');
    rethrow;
  }
}

// LOGIC — Convert a SQLite row into the app's goal Map format
Map<String, dynamic> _rowToGoal(Map<String, dynamic> row) {
  return {
    'id': row['id'] as int,
    'subject': row['subject'] as String,
    'hours': row['hours'] as int,
    'done': (row['done'] as int) == 1,
  };
}

// LOGIC — SELECT: load all goals from the database
Future<List<Map<String, dynamic>>> loadGoalsFromDatabase() async {
  try {
    final db = await initializeDatabase();
    final rows = await db.query('goals', orderBy: 'id ASC');
    return rows.map(_rowToGoal).toList();
  } catch (e) {
    debugPrint('Failed to load goals: $e');
    rethrow;
  }
}

// LOGIC — INSERT: save a new goal and return it with the generated id
Future<Map<String, dynamic>> insertGoalIntoDatabase({
  required String subject,
  required int hours,
}) async {
  try {
    final db = await initializeDatabase();
    final id = await db.insert('goals', {
      'subject': subject,
      'hours': hours,
      'done': 0,
    });

    debugPrint('Goal inserted with id: $id');
    return {'id': id, 'subject': subject, 'hours': hours, 'done': false};
  } catch (e) {
    debugPrint('Failed to insert goal: $e');
    rethrow;
  }
}

// LOGIC — UPDATE: change the done status of a goal (true → 1, false → 0)
Future<void> updateGoalDoneInDatabase(int id, bool done) async {
  try {
    final db = await initializeDatabase();
    await db.update(
      'goals',
      {'done': done ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
    debugPrint('Goal $id updated: done=${done ? 1 : 0}');
  } catch (e) {
    debugPrint('Failed to update goal: $e');
    rethrow;
  }
}

// LOGIC — DELETE: remove a goal from the database by id
Future<void> deleteGoalFromDatabase(int id) async {
  try {
    final db = await initializeDatabase();
    await db.delete('goals', where: 'id = ?', whereArgs: [id]);
    debugPrint('Goal $id deleted from database.');
  } catch (e) {
    debugPrint('Failed to delete goal: $e');
    rethrow;
  }
}

// STATIC — Design tokens from design.md (Academic Precision palette)
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
  static const primaryFixed = Color(0xFFE0E0FF);
}

// STATIC — Shared layout constants from design.md spacing system
class AppSpacing {
  static const pageMargin = 20.0;
  static const stackSm = 8.0;
  static const stackMd = 16.0;
  static const stackLg = 24.0;
  static const cardRadius = 8.0;
}

// STATIC — Reusable soft shadow from design.md elevation section
const List<BoxShadow> kCardShadow = [
  BoxShadow(color: Color(0x0F000000), blurRadius: 12, offset: Offset(0, 4)),
];

void main() {
  runApp(const MyApp());
}

// STATIC — Root app widget and global theme
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
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            borderSide: const BorderSide(color: AppColors.error, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
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

// LOGIC — Home Screen holds the goals list and all business logic
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // LOGIC — Goals loaded from SQLite (no hardcoded data)
  final List<Map<String, dynamic>> _goals = [];
  bool _isLoading = true;

  // LOGIC — Computed statistics: always derived from _goals, never stored manually
  int get totalGoals => _goals.length;

  int get totalHours =>
      _goals.fold(0, (sum, goal) => sum + (goal['hours'] as int));

  int get completedGoals => _goals.where((goal) => goal['done'] == true).length;

  // LOGIC — Load goals from SQLite when the Home Screen starts
  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    try {
      await initializeDatabase();
      final goals = await loadGoalsFromDatabase();
      if (mounted) {
        setState(() {
          _goals
            ..clear()
            ..addAll(goals);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Could not load goals on startup: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not load saved goals. Please restart the app.',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // LOGIC — Show a confirmation dialog before deleting a goal
  Future<bool> _confirmDelete(String subject) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        title: const Text(
          'Delete Goal',
          style: TextStyle(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "$subject"?',
          style: const TextStyle(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // LOGIC — DELETE: remove goal from SQLite first, then update _goals and UI
  Future<void> _performDelete(int id) async {
    try {
      // Step 1: delete the correct row from SQLite using id
      await deleteGoalFromDatabase(id);
      // Step 2: remove the matching goal from _goals so UI stays in sync
      if (mounted) {
        setState(() {
          _goals.removeWhere((goal) => goal['id'] == id);
        });
      }
    } catch (e) {
      debugPrint('Delete operation failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not delete goal. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
        // Re-sync _goals from database if delete failed
        await _loadGoals();
      }
    }
  }

  // LOGIC — DELETE: ask for confirmation, then delete from database and list
  Future<void> _deleteGoal(int index) async {
    final goal = _goals[index];
    final confirmed = await _confirmDelete(goal['subject'] as String);
    if (confirmed && mounted) {
      await _performDelete(goal['id'] as int);
    }
  }

  // LOGIC — UPDATE: toggle done status in SQLite and the in-memory list
  Future<void> _toggleGoal(int index) async {
    final goal = _goals[index];
    final id = goal['id'] as int;
    final newDone = !(goal['done'] as bool);

    try {
      // Step 1: update the database row by id
      await updateGoalDoneInDatabase(id, newDone);
      // Step 2: update the matching goal in _goals so UI stays in sync
      if (mounted) {
        setState(() {
          final goalIndex = _goals.indexWhere((g) => g['id'] == id);
          if (goalIndex != -1) {
            _goals[goalIndex]['done'] = newDone;
          }
        });
      }
    } catch (e) {
      debugPrint('Toggle operation failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not update goal. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
        // Re-sync _goals from database if update failed
        await _loadGoals();
      }
    }
  }

  // LOGIC — INSERT: save new goal to SQLite, store id in Map, then update UI
  Future<void> _openAddGoalScreen() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => const AddGoalScreen()),
    );

    if (result != null && mounted) {
      try {
        // Step 1: insert into SQLite and capture the generated id
        final savedGoal = await insertGoalIntoDatabase(
          subject: result['subject'] as String,
          hours: result['hours'] as int,
        );

        // Step 2: add goal (with id) to _goals and refresh UI
        setState(() {
          _goals.add(savedGoal);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${savedGoal['subject']}" added to your goals'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      } catch (e) {
        debugPrint('Insert operation failed: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save goal. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // STATIC — Build the Home Screen layout
  @override
  Widget build(BuildContext context) {
    // Connection Point 1 — Logic data (totalGoals, totalHours, completedGoals, _goals)
    // is read here and passed into child widgets for display.
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('My Study Planner (G6)'),
            const SizedBox(height: 2),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                '$completedGoals / $totalGoals Done',
                key: ValueKey('$completedGoals-$totalGoals'),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.outline),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.stackMd),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageMargin,
            ),
            child: DailyProgressBar(
              completedGoals: completedGoals,
              totalGoals: totalGoals,
            ),
          ),
          const SizedBox(height: AppSpacing.stackMd),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageMargin,
            ),
            child: StatsCard(
              totalGoals: totalGoals,
              totalHours: totalHours,
              completedGoals: completedGoals,
            ),
          ),
          const SizedBox(height: AppSpacing.stackLg),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.pageMargin),
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
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _goals.isEmpty
                ? const EmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pageMargin,
                    ),
                    itemCount: _goals.length,
                    itemBuilder: (context, index) {
                      final goal = _goals[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GoalTile(
                          key: ValueKey(goal['id']),
                          subject: goal['subject'] as String,
                          hours: goal['hours'] as int,
                          isDone: goal['done'] as bool,
                          // Connection Point 2 — UI events call logic functions
                          onToggle: () => _toggleGoal(index),
                          onConfirmDelete: () =>
                              _confirmDelete(goal['subject'] as String),
                          onDeleteConfirmed: () =>
                              _performDelete(goal['id'] as int),
                          onLongPressDelete: () => _deleteGoal(index),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        // Connection Point 2 — FAB tap triggers navigation logic
        onPressed: _openAddGoalScreen,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// LOGIC — Add Goal Screen handles form input, validation, and returning data
class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  // LOGIC — Form state and text controllers
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _hoursController = TextEditingController();
  final _subjectFocus = FocusNode();
  bool _isSaving = false;

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

  // LOGIC — Validate subject field
  String? _validateSubject(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Subject cannot be empty';
    }
    return null;
  }

  // LOGIC — Validate hours field
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

  // LOGIC — Validate form and return goal data via Navigator.pop
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

  // STATIC — Build the Add Goal Screen layout
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(this.context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Goal'),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, color: AppColors.outline),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.pageMargin),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // STATIC — Header section
                Container(
                  padding: const EdgeInsets.all(AppSpacing.stackMd),
                  decoration: BoxDecoration(
                    color: AppColors.primaryFixed.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New Study Goal',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      SizedBox(height: AppSpacing.stackSm),
                      Text(
                        'Add a subject and how many hours you plan to study.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.stackLg),

                // STATIC — Subject input field
                TextFormField(
                  controller: _subjectController,
                  focusNode: _subjectFocus,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'SUBJECT',
                    hintText: 'e.g., Flutter Programming',
                    prefixIcon: Icon(
                      Icons.menu_book_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  validator: _validateSubject,
                ),
                const SizedBox(height: AppSpacing.stackMd),

                // STATIC — Hours input field
                TextFormField(
                  controller: _hoursController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'HOURS',
                    hintText: 'e.g., 3',
                    prefixIcon: Icon(
                      Icons.schedule_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  validator: _validateHours,
                  onFieldSubmitted: (_) => _saveGoal(),
                ),
                const SizedBox(height: AppSpacing.stackLg),

                // STATIC — Save button
                SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: _isSaving ? null : _saveGoal,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_rounded, size: 20),
                    label: Text(_isSaving ? 'Saving...' : 'Save Goal'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.primary.withValues(
                        alpha: 0.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.cardRadius,
                        ),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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

// STATIC — Reusable statistic widget (used 3 times in StatsCard)
class StatDisplay extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const StatDisplay({
    super.key,
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
          const SizedBox(height: AppSpacing.stackSm),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Text(
              value,
              key: ValueKey(value),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
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

// STATIC — Stats dashboard card using StatDisplay three times
class StatsCard extends StatelessWidget {
  final int totalGoals;
  final int totalHours;
  final int completedGoals;

  const StatsCard({
    super.key,
    required this.totalGoals,
    required this.totalHours,
    required this.completedGoals,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: kCardShadow,
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: StatDisplay(
                icon: Icons.format_list_bulleted,
                iconColor: AppColors.primary,
                value: '$totalGoals',
                label: 'GOALS',
              ),
            ),
            const VerticalDivider(width: 1, color: AppColors.outline),
            Expanded(
              child: StatDisplay(
                icon: Icons.timer_outlined,
                iconColor: AppColors.primary,
                value: '$totalHours',
                label: 'HOURS',
              ),
            ),
            const VerticalDivider(width: 1, color: AppColors.outline),
            Expanded(
              child: StatDisplay(
                icon: Icons.check_circle,
                iconColor: AppColors.success,
                value: '$completedGoals',
                label: 'DONE',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// STATIC — Daily progress bar with LinearProgressIndicator
class DailyProgressBar extends StatelessWidget {
  final int completedGoals;
  final int totalGoals;

  const DailyProgressBar({
    super.key,
    required this.completedGoals,
    required this.totalGoals,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalGoals == 0 ? 0.0 : completedGoals / totalGoals;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(AppSpacing.stackMd),
      decoration: BoxDecoration(
        color: AppColors.progressBar,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
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
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  '$completedGoals/$totalGoals Done',
                  key: ValueKey('$completedGoals-$totalGoals'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.stackSm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.outline.withValues(alpha: 0.4),
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}

// STATIC — Reusable goal row with smooth completion animations
class GoalTile extends StatelessWidget {
  final String subject;
  final int hours;
  final bool isDone;
  final VoidCallback onToggle;
  final Future<bool> Function() onConfirmDelete;
  final VoidCallback onDeleteConfirmed;
  final VoidCallback onLongPressDelete;

  const GoalTile({
    super.key,
    required this.subject,
    required this.hours,
    required this.isDone,
    required this.onToggle,
    required this.onConfirmDelete,
    required this.onDeleteConfirmed,
    required this.onLongPressDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('$subject-$hours-$isDone'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => onConfirmDelete(),
      onDismissed: (_) => onDeleteConfirmed(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.pageMargin),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isDone ? AppColors.cardDone : Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          boxShadow: kCardShadow,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onToggle,
            onLongPress: onLongPressDelete,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // STATIC — Left color pill (navy = active, green = done)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 4,
                    decoration: BoxDecoration(
                      color: isDone
                          ? AppColors.successLight
                          : AppColors.primary,
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(AppSpacing.cardRadius),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                      child: Icon(
                        isDone ? Icons.check_circle : Icons.circle_outlined,
                        key: ValueKey(isDone),
                        color: isDone
                            ? AppColors.success
                            : AppColors.onSurfaceVariant,
                        size: 24,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDone
                                  ? AppColors.onSurfaceVariant
                                  : AppColors.onSurface,
                              decoration: isDone
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                            child: Text(subject),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$hours Hours',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDone
                                  ? AppColors.onSurfaceVariant.withValues(
                                      alpha: 0.7,
                                    )
                                  : AppColors.onSurfaceVariant,
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

// STATIC — Empty state shown when there are no goals
class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

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
              decoration: const BoxDecoration(
                color: AppColors.primaryFixed,
                shape: BoxShape.circle,
                boxShadow: kCardShadow,
              ),
              child: const Icon(
                Icons.menu_book_outlined,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.stackLg),
            const Text(
              'No study goals yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.stackSm),
            const Text(
              'Tap + to add your first goal.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.stackLg),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.outline),
                boxShadow: kCardShadow,
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
