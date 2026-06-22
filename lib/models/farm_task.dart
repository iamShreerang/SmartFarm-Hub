import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskType { watering, fertilization, pesticide, harvesting, planting, pruning, other }
enum TaskStatus { pending, completed, skipped }

class FarmTask {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final TaskType type;
  final TaskStatus status;
  final DateTime scheduledDate;
  final String? cropId;
  final String? cropName;
  final bool notificationEnabled;
  final DateTime createdAt;

  FarmTask({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.type,
    this.status = TaskStatus.pending,
    required this.scheduledDate,
    this.cropId,
    this.cropName,
    this.notificationEnabled = true,
    required this.createdAt,
  });

  factory FarmTask.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return FarmTask(
      id: doc.id,
      userId: d['userId'] ?? '',
      title: d['title'] ?? '',
      description: d['description'],
      type: TaskType.values.firstWhere(
        (e) => e.name == d['type'],
        orElse: () => TaskType.other,
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.name == d['status'],
        orElse: () => TaskStatus.pending,
      ),
      scheduledDate: (d['scheduledDate'] as Timestamp).toDate(),
      cropId: d['cropId'],
      cropName: d['cropName'],
      notificationEnabled: d['notificationEnabled'] ?? true,
      createdAt: (d['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'title': title,
        'description': description,
        'type': type.name,
        'status': status.name,
        'scheduledDate': Timestamp.fromDate(scheduledDate),
        'cropId': cropId,
        'cropName': cropName,
        'notificationEnabled': notificationEnabled,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  bool get isOverdue =>
      status == TaskStatus.pending &&
      scheduledDate.isBefore(DateTime.now());

  FarmTask copyWith({TaskStatus? status}) => FarmTask(
        id: id,
        userId: userId,
        title: title,
        description: description,
        type: type,
        status: status ?? this.status,
        scheduledDate: scheduledDate,
        cropId: cropId,
        cropName: cropName,
        notificationEnabled: notificationEnabled,
        createdAt: createdAt,
      );
}
