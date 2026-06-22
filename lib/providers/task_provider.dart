import 'package:flutter/material.dart';
import '../models/farm_task.dart';
import '../services/task_service.dart';
import '../services/notification_service.dart';
import 'package:uuid/uuid.dart';

class TaskProvider extends ChangeNotifier {
  final _taskService = TaskService();
  final _uuid = const Uuid();

  List<FarmTask> _tasks = [];
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();

  List<FarmTask> get tasks => _tasks;
  bool get isLoading => _isLoading;
  DateTime get selectedDate => _selectedDate;

  List<FarmTask> get pendingTasks =>
      _tasks.where((t) => t.status == TaskStatus.pending).toList();

  List<FarmTask> get overdueTasks =>
      _tasks.where((t) => t.isOverdue).toList();

  List<FarmTask> tasksForDate(DateTime date) => _tasks
      .where((t) =>
          t.scheduledDate.year == date.year &&
          t.scheduledDate.month == date.month &&
          t.scheduledDate.day == date.day)
      .toList();

  void watchTasks(String userId) {
    _taskService.watchTasks(userId).listen((tasks) {
      _tasks = tasks;
      notifyListeners();
    });
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  Future<bool> addTask({
    required String userId,
    required String title,
    String? description,
    required TaskType type,
    required DateTime scheduledDate,
    String? cropId,
    String? cropName,
    bool notificationEnabled = true,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final task = FarmTask(
        id: _uuid.v4(),
        userId: userId,
        title: title,
        description: description,
        type: type,
        scheduledDate: scheduledDate,
        cropId: cropId,
        cropName: cropName,
        notificationEnabled: notificationEnabled,
        createdAt: DateTime.now(),
      );
      await _taskService.addTask(task);
      if (notificationEnabled) {
        await NotificationService.scheduleTaskReminder(task);
      }
      return true;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> completeTask(String taskId) async {
    await _taskService.updateTaskStatus(taskId, TaskStatus.completed);
    await NotificationService.cancelTaskReminder(taskId);
  }

  Future<void> deleteTask(String taskId) async {
    await _taskService.deleteTask(taskId);
    await NotificationService.cancelTaskReminder(taskId);
  }
}
