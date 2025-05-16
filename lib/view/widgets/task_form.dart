import 'package:birdo/controllers/task_controller.dart';
import 'package:birdo/core/theme/app_theme.dart';
import 'package:birdo/model/entities/task.dart';
import 'package:birdo/model/managers/task_manager.dart';
import 'package:birdo/view/widgets/common/chunky_button.dart';
import 'package:birdo/view/widgets/common/chunky_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TaskForm extends StatefulWidget {
  final VoidCallback? onTaskAdded;

  const TaskForm({super.key, this.onTaskAdded});

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  TaskCategory _selectedCategory = TaskCategory.productivity;
  bool _isRecurring = true;
  /* Elli: This should be better managed via enums mapping to weekdays, which
     should be defined in `task.dart`. */
  final List<bool> _selectedDays = List.filled(7, true);
  String? _selectedDaysError;

  final List<String> _dayInitials = ['M', 'Tu', 'W', 'Th', 'F', 'Sa', 'Su'];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text.trim();
      final taskController = Provider.of<TaskController>(context, listen: false);
      final taskManager = Provider.of<TaskManager>(context, listen: false);
      
      // Validate that at least one day was selected.
      if (_isRecurring && !_selectedDays.contains(true)) {
        setState(() {
          _selectedDaysError = 'Please select at least one day';
        });
        return;
      } else {
        setState(() {
          _selectedDaysError = null;
        });
      }

      // Get the current date from the task manager
      final targetDate = taskManager.currentDay;

      // Convert the selected days bool list to a list of weekday ints.
      final List<int> recurringDays = _isRecurring
      ? _selectedDays
          .asMap()
          .entries
          .where((entry) => entry.value)
          .map((entry) => entry.key + 1)
          .toList()
      : [];

      // Use the task controller to create the task
      taskController.createTask(
        title,
        5, // Default energy reward
        _selectedCategory,
        _isRecurring,
        recurringDays,
        date: targetDate,
      );

      _titleController.clear();

      if (widget.onTaskAdded != null) {
        widget.onTaskAdded!();
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppTheme.spacing.medium),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Consumer<TaskManager>(
              builder: (context, taskManager, child) {
                String dateText = 'Today';

                final now = DateTime.now();
                final currentDay = taskManager.currentDay;
                if (currentDay.year != now.year ||
                    currentDay.month != now.month ||
                    currentDay.day != now.day) {
                  dateText =
                      '${currentDay.year}-${currentDay.month.toString().padLeft(2, '0')}-${currentDay.day.toString().padLeft(2, '0')}';
                }

                return Text(
                  'Add Task for $dateText',
                  style: AppTheme.typography.h5.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.colors.primary,
                  ),
                  textAlign: TextAlign.center,
                );
              },
            ),
            SizedBox(height: AppTheme.spacing.large),

            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Task Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radius.medium),
                ),
                filled: true,
                fillColor: AppTheme.colors.surface,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a task title';
                }
                return null;
              },
            ),
            SizedBox(height: AppTheme.spacing.medium),

            DropdownButtonFormField<TaskCategory>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radius.medium),
                ),
                filled: true,
                fillColor: AppTheme.colors.surface,
              ),
              items:
                  TaskCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(_getCategoryName(category)),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
            ),
            SizedBox(height: AppTheme.spacing.large),

            CheckboxListTile(
              title: const Text('Repeat Task?'),
              value: _isRecurring,
              onChanged: (bool? value) {
                if (value != null) {
                  setState(() {
                    _isRecurring = value;
                  });
                }
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),

            if (_isRecurring) ...[
              SizedBox(height: AppTheme.spacing.small),
              Text('Repeat on'),
              SizedBox(height: AppTheme.spacing.small),

              ToggleButtons(
                isSelected: _selectedDays,
                onPressed: (int index) {
                  setState(() {
                    _selectedDays[index] = !_selectedDays[index];
                  });
                },
                borderRadius: BorderRadius.circular(AppTheme.radius.medium),
                selectedColor: AppTheme.colors.onPrimary,
                fillColor: AppTheme.colors.surfaceDark,
                color: AppTheme.colors.primary,
                constraints: BoxConstraints(minHeight: 40, minWidth: 40),
                children: _dayInitials.map((label) => Text(label)).toList(),
              ),

              if (_selectedDaysError != null) ...[
                SizedBox(height: AppTheme.spacing.small),
                Text(
                  _selectedDaysError!,
                  style: TextStyle(color: AppTheme.colors.error, fontSize: 12),
                ),
              ],
            ] else ... [
              Text(
                'Recurring tasks help build lasting habits 💪',
                style: TextStyle(fontSize: 16),
              ),
            ],
            SizedBox(height: AppTheme.spacing.large),

            ChunkyButton(
              text: 'Create Task',
              onPressed: _saveTask,
              type: ButtonType.primary,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryName(TaskCategory category) {
    switch (category) {
      case TaskCategory.selfCare:
        return 'Self Care';
      case TaskCategory.productivity:
        return 'Productivity';
      case TaskCategory.exercise:
        return 'Exercise';
      case TaskCategory.mindfulness:
        return 'Mindfulness';
    }
  }
}

void showTaskFormDialog(BuildContext context, {VoidCallback? onTaskAdded}) {
  showDialog(
    context: context,
    builder:
        (context) => Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,

          insetPadding: EdgeInsets.symmetric(
            horizontal: AppTheme.spacing.large,
            vertical: AppTheme.spacing.xlarge,
          ),
          child: ChunkyCard(
            color: AppTheme.colors.surface,
            borderRadius: AppTheme.radius.large,

            child: TaskForm(onTaskAdded: onTaskAdded),
          ),
        ),
  );
}
