import 'package:hive_ce/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String? parentId; // Parent task of a recurring task.

  @HiveField(2)
  String title;

  @HiveField(3)
  int energyReward;

  @HiveField(4)
  bool isCompleted;

  @HiveField(5)
  DateTime? completedAt;

  @HiveField(6)
  TaskCategory category;

  @HiveField(7)
  final DateTime createdDate;

  @HiveField(8)
  int numCompleted;

  @HiveField(9)
  bool isRecurring;

  @HiveField(10)
  List<int>? recurringDays;

  Task({
    required this.id,
    this.parentId,
    required this.title,
    required this.energyReward,
    this.isCompleted = false,
    this.completedAt,
    required this.category,
    DateTime? createdDate,
    this.numCompleted = 0,
    required this.isRecurring,
    List<int>? recurringDays,
  }) : createdDate = createdDate ?? DateTime.now(),
       recurringDays = recurringDays ?? [];

  factory Task.create({
    required String title,
    required int energyReward,
    required TaskCategory category,
    required bool isRecurring,
    String? parentId,
    List<int>? recurringDays,
  }) {
    final now = DateTime.now();
    return Task(
      id: now.millisecondsSinceEpoch.toString(),
      parentId: parentId,
      title: title,
      energyReward: energyReward,
      category: category,
      createdDate: now,
      numCompleted: 0,
      isRecurring: isRecurring,
      recurringDays: recurringDays ?? [],
    );
  }

  void complete() {
    isCompleted = true;
    completedAt = DateTime.now();
  }

  void reset() {
    isCompleted = false;
    completedAt = null;
  }
}

@HiveType(typeId: 1)
enum TaskCategory {
  @HiveField(0)
  selfCare,
  @HiveField(1)
  productivity,
  @HiveField(2)
  exercise,
  @HiveField(3)
  mindfulness,
}
