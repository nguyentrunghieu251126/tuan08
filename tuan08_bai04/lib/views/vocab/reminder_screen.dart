import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../services/notification_service.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final noti = NotificationService();
  List<PendingNotificationRequest> pending = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await noti.getPending();
    setState(() => pending = list);
  }

  Future<void> _cancel(int id) async {
    await noti.cancel(id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch nhắc')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: pending.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 100),
                  Center(child: Text('Không có lịch nhắc nào đang chờ')),
                ],
              )
            : ListView.builder(
                itemCount: pending.length,
                itemBuilder: (context, i) {
                  final p = pending[i];
                  return ListTile(
                    leading: const Icon(Icons.alarm),
                    title: Text(p.title ?? ''),
                    subtitle: Text(
                      p.payload ?? p.body ?? '',
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      tooltip: 'Hủy lịch nhắc',
                      onPressed: () => _cancel(p.id),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
