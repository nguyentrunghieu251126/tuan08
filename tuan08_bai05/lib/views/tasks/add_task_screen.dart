import 'package:flutter/material.dart';

import '../../models/task.dart';
import '../../services/notification_service.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final titleCtrl = TextEditingController();
  final timeCtrl = TextEditingController();
  TimeOfDay? picked;

  @override
  void dispose() {
    titleCtrl.dispose();
    timeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: picked ?? TimeOfDay.now(),
    );
    if (t != null && mounted) {
      setState(() {
        picked = t;
        timeCtrl.text = t.format(context);
      });
    }
  }

  void _save() {
    if (titleCtrl.text.trim().isEmpty || picked == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nhập tên nhiệm vụ và chọn giờ nhắc')),
      );
      return;
    }
    final task = Task(
      id: NotificationService.newId(),
      title: titleCtrl.text.trim(),
      hour: picked!.hour,
      minute: picked!.minute,
    );
    Navigator.pop(context, task);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm nhiệm vụ mới')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Tên nhiệm vụ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: timeCtrl,
              readOnly: true,
              onTap: _pickTime,
              decoration: const InputDecoration(
                labelText: 'Giờ nhắc',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.access_time),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _save, child: const Text('Lưu nhiệm vụ')),
          ],
        ),
      ),
    );
  }
}
