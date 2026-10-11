import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

import '../../models/task.dart';
import '../../services/notification_service.dart';
import '../../services/task_file_service.dart';
import 'add_task_screen.dart';

class TaskHome extends StatefulWidget {
  const TaskHome({super.key});

  @override
  State<TaskHome> createState() => _TaskHomeState();
}

class _TaskHomeState extends State<TaskHome> {
  final fileService = TaskFileService();
  final noti = NotificationService();
  List<Task> tasks = [];

  int get doneCount => tasks.where((t) => t.done).length;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await fileService.loadTasks();
    setState(() => tasks = list);
  }

  Future<void> _save() => fileService.saveTasks(tasks);

  Future<void> _schedule(Task t) async {
    await noti.scheduleAt(
      id: t.id,
      title: 'Nhắc nhiệm vụ',
      body: '${t.title} – lúc ${t.timeText}',
      time: t.nextReminder(),
      channelId: 'daily_task_channel',
      channelName: 'Nhiệm vụ mỗi ngày',
      repeat: DateTimeComponents.time,
    );
  }

  Future<void> _addTask() async {
    final task = await Navigator.push<Task>(
      context,
      MaterialPageRoute(builder: (_) => const AddTaskScreen()),
    );
    if (task == null) return;
    setState(() => tasks.add(task));
    await _save();
    await _schedule(task);
    _snack('Đã lưu "${task.title}", nhắc lúc ${task.timeText} mỗi ngày');
  }

  Future<void> _changeTime(Task t) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: t.hour, minute: t.minute),
    );
    if (picked == null) return;
    setState(() {
      t.hour = picked.hour;
      t.minute = picked.minute;
    });
    await _save();
    if (!t.done) await _schedule(t);
    _snack('Đã đặt nhắc "${t.title}" lúc ${t.timeText}');
  }

  Future<void> _toggleDone(Task t) async {
    if (t.done) {
      setState(() => t.done = false);
      await _save();
      await _schedule(t);
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận'),
        content: Text('Nhiệm vụ "${t.title}" đã hoàn thành?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Có'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => t.done = true);
    await _save();
    await noti.cancel(t.id);
    await noti.showNow(
      id: 9999,
      title: 'Tiến độ hôm nay',
      body: 'Bạn đã hoàn thành $doneCount/${tasks.length} nhiệm vụ',
      channelId: 'daily_task_channel',
      channelName: 'Nhiệm vụ mỗi ngày',
    );
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhiệm vụ mỗi ngày'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            tooltip: 'Hôm nay',
            onPressed: () => _snack(
              'Hôm nay ${DateFormat('dd/MM/yyyy').format(DateTime.now())}: '
              'đã xong $doneCount/${tasks.length} nhiệm vụ',
            ),
          ),
        ],
      ),
      body: tasks.isEmpty
          ? const Center(child: Text('Chưa có nhiệm vụ. Bấm + để thêm.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: tasks.length,
              itemBuilder: (context, i) {
                final t = tasks[i];
                return Card(
                  child: ListTile(
                    leading: Checkbox(
                      value: t.done,
                      onChanged: (_) => _toggleDone(t),
                    ),
                    title: Text(
                      t.title,
                      style: TextStyle(
                        decoration: t.done ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Text('Nhắc lúc ${t.timeText}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.notifications_active_outlined),
                      tooltip: 'Đặt giờ thông báo',
                      onPressed: () => _changeTime(t),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: const Icon(Icons.add),
      ),
    );
  }
}
