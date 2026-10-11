import 'package:flutter/material.dart';

import '../../models/word.dart';
import '../../services/notification_service.dart';
import '../../services/vocab_file_service.dart';
import 'learn_screen.dart';
import 'quiz_screen.dart';
import 'reminder_screen.dart';

class VocabHome extends StatefulWidget {
  const VocabHome({super.key});

  @override
  State<VocabHome> createState() => _VocabHomeState();
}

class _VocabHomeState extends State<VocabHome> {
  final wordCtrl = TextEditingController();
  final meaningCtrl = TextEditingController();
  final fileService = VocabFileService();
  final noti = NotificationService();

  @override
  void dispose() {
    wordCtrl.dispose();
    meaningCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveAndRemind() async {
    final w = wordCtrl.text.trim();
    final m = meaningCtrl.text.trim();
    if (w.isEmpty || m.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập từ và nghĩa')),
      );
      return;
    }

    await fileService.addWord(Word(word: w, meaning: m));

    await noti.showNow(
      title: 'Đã lưu từ "$w"',
      body: 'Hãy ôn tập lại sau 10 phút nhé!',
      channelId: 'vocab_channel',
      channelName: 'Học từ vựng',
    );

    await noti.scheduleAt(
      title: 'Ôn từ vựng mới!',
      body: '$w · $m',
      time: DateTime.now().add(const Duration(minutes: 10)),
      channelId: 'vocab_channel',
      channelName: 'Học từ vựng',
      payload: '$w · $m',
    );

    if (!mounted) return;
    wordCtrl.clear();
    meaningCtrl.clear();
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã lưu và lên lịch nhắc học từ sau 10 phút'),
      ),
    );
  }

  void _open(Widget screen) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ứng dụng học từ vựng')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 36, color: Colors.blue),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Trợ lý học từ vựng',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Trang chính'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Học từ'),
              onTap: () => _open(const LearnScreen()),
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Kiểm tra từ'),
              onTap: () => _open(const QuizScreen()),
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Lịch nhắc'),
              onTap: () => _open(const ReminderScreen()),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: wordCtrl,
              decoration: const InputDecoration(labelText: 'Từ'),
            ),
            TextField(
              controller: meaningCtrl,
              decoration: const InputDecoration(labelText: 'Nghĩa'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveAndRemind,
              child: const Text('Lưu & Nhắc học sau 10 phút'),
            ),
          ],
        ),
      ),
    );
  }
}
