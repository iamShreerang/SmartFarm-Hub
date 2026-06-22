import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart' as ap;
import '../../providers/task_provider.dart';
import '../../providers/crop_provider.dart';
import '../../models/farm_task.dart';
import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskProvider>();
    final selectedDate = tasks.selectedDate;

    return Scaffold(
      appBar: AppBar(title: const Text('Farming Calendar')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: selectedDate,
            selectedDayPredicate: (day) => isSameDay(day, selectedDate),
            calendarFormat: CalendarFormat.month,
            eventLoader: (day) => tasks.tasksForDate(day),
            onDaySelected: (selected, _) =>
                tasks.selectDate(selected),
            calendarStyle: CalendarStyle(
              selectedDecoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            child: SectionHeader(
              title:
                  'Tasks for ${DateFormat('d MMM').format(selectedDate)}',
              actionLabel: 'Add Task',
              onAction: () => _showAddTaskSheet(context),
            ),
          ),
          Expanded(
            child: _TasksForSelectedDay(
              tasks: tasks.tasksForDate(selectedDate),
              onComplete: (id) => context.read<TaskProvider>().completeTask(id),
              onDelete: (id) => context.read<TaskProvider>().deleteTask(id),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskSheet(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddTaskSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _AddTaskSheet(),
    );
  }
}

class _TasksForSelectedDay extends StatelessWidget {
  final List<FarmTask> tasks;
  final ValueChanged<String> onComplete;
  final ValueChanged<String> onDelete;

  const _TasksForSelectedDay({
    required this.tasks,
    required this.onComplete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const Center(
        child: Text('No tasks for this day.',
            style: TextStyle(color: AppColors.textGrey)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: tasks.length,
      itemBuilder: (_, i) => _TaskTile(
        task: tasks[i],
        onComplete: onComplete,
        onDelete: onDelete,
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final FarmTask task;
  final ValueChanged<String> onComplete;
  final ValueChanged<String> onDelete;

  const _TaskTile(
      {required this.task,
      required this.onComplete,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.status == TaskStatus.completed;

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(task.id),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _typeColor(task.type).withOpacity(0.15),
            child: Icon(_typeIcon(task.type),
                color: _typeColor(task.type), size: 20),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration: isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              color: isCompleted ? AppColors.textGrey : null,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: task.cropName != null
              ? Text('Crop: ${task.cropName}',
                  style: TextStyle(color: AppColors.textGrey))
              : null,
          trailing: isCompleted
              ? const Icon(Icons.check_circle,
                  color: AppColors.success)
              : IconButton(
                  icon: const Icon(Icons.check_circle_outline,
                      color: AppColors.primary),
                  onPressed: () => onComplete(task.id),
                ),
        ),
      ),
    );
  }

  IconData _typeIcon(TaskType type) {
    switch (type) {
      case TaskType.watering:
        return Icons.water_drop;
      case TaskType.fertilization:
        return Icons.science;
      case TaskType.pesticide:
        return Icons.bug_report;
      case TaskType.harvesting:
        return Icons.agriculture;
      case TaskType.planting:
        return Icons.grass;
      case TaskType.pruning:
        return Icons.content_cut;
      default:
        return Icons.task;
    }
  }

  Color _typeColor(TaskType type) {
    switch (type) {
      case TaskType.watering:
        return AppColors.info;
      case TaskType.fertilization:
        return AppColors.success;
      case TaskType.pesticide:
        return AppColors.warning;
      case TaskType.harvesting:
        return AppColors.accent;
      default:
        return AppColors.primary;
    }
  }
}

class _AddTaskSheet extends StatefulWidget {
  const _AddTaskSheet();

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  TaskType _taskType = TaskType.watering;
  String? _selectedCropId;
  String? _selectedCropName;
  bool _notificationEnabled = true;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final userId = context.read<ap.AuthProvider>().profile!.uid;
    final selectedDate = context.read<TaskProvider>().selectedDate;

    final success = await context.read<TaskProvider>().addTask(
          userId: userId,
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          type: _taskType,
          scheduledDate: selectedDate,
          cropId: _selectedCropId,
          cropName: _selectedCropName,
          notificationEnabled: _notificationEnabled,
        );

    if (mounted) {
      Navigator.pop(context);
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to add task'),
              backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final crops = context.watch<CropProvider>().crops;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Task',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            AppTextField(
              hintText: 'Task title',
              labelText: 'Title',
              controller: _titleCtrl,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Title is required' : null,
            ),
            const SizedBox(height: 12),
            const Text('Task Type',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: TaskType.values.map((t) {
                return ChoiceChip(
                  label: Text(t.name),
                  selected: _taskType == t,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                      color: _taskType == t
                          ? Colors.white
                          : AppColors.textDark,
                      fontSize: 12),
                  onSelected: (_) => setState(() => _taskType = t),
                );
              }).toList(),
            ),
            if (crops.isNotEmpty) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Related Crop (Optional)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                value: _selectedCropId,
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text('None')),
                  ...crops.map((c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name),
                      )),
                ],
                onChanged: (val) {
                  setState(() {
                    _selectedCropId = val;
                    _selectedCropName =
                        crops.firstWhere((c) => c.id == val, orElse: () => crops.first).name;
                  });
                },
              ),
            ],
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Enable Reminder'),
              value: _notificationEnabled,
              activeColor: AppColors.primary,
              onChanged: (v) =>
                  setState(() => _notificationEnabled = v),
            ),
            const SizedBox(height: 12),
            AppButton(label: 'Add Task', onPressed: _save),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
