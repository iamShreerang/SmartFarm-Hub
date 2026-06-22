import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/farm_task.dart';

class TaskService {
  final _firestore = FirebaseFirestore.instance;
  CollectionReference get _tasks => _firestore.collection('tasks');

  Stream<List<FarmTask>> watchTasks(String userId) => _tasks
      .where('userId', isEqualTo: userId)
      .orderBy('scheduledDate')
      .snapshots()
      .map((s) => s.docs.map(FarmTask.fromFirestore).toList());

  Stream<List<FarmTask>> watchTasksForDate(String userId, DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return _tasks
        .where('userId', isEqualTo: userId)
        .where('scheduledDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('scheduledDate', isLessThan: Timestamp.fromDate(end))
        .snapshots()
        .map((s) => s.docs.map(FarmTask.fromFirestore).toList());
  }

  Future<FarmTask> addTask(FarmTask task) async {
    final docRef = await _tasks.add(task.toFirestore());
    return task;
  }

  Future<void> updateTaskStatus(String taskId, TaskStatus status) =>
      _tasks.doc(taskId).update({'status': status.name});

  Future<void> deleteTask(String taskId) => _tasks.doc(taskId).delete();
}
