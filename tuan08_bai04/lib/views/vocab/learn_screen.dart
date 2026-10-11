import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/word.dart';
import '../../services/notification_service.dart';
import '../../services/vocab_file_service.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  final answerCtrl = TextEditingController();
  final _random = Random();
  List<Word> words = [];
  Word? current;
  int correct = 0;
  int wrong = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    answerCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    words = await VocabFileService().loadWords();
    _nextWord();
  }

  void _nextWord() {
    setState(() {
      current = words.isEmpty ? null : words[_random.nextInt(words.length)];
    });
  }

  Future<void> _check() async {
    if (current == null) return;
    final answer = answerCtrl.text.trim().toLowerCase();
    final isRight = answer == current!.meaning.trim().toLowerCase();

    setState(() => isRight ? correct++ : wrong++);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isRight ? 'Chính xác!' : 'Sai rồi! Nghĩa đúng: ${current!.meaning}',
        ),
        backgroundColor: isRight ? Colors.green : Colors.red,
      ),
    );

    if (!isRight && wrong % 3 == 0) {
      await NotificationService().showNow(
        title: 'Cố lên nào!',
        body: 'Bạn đã trả lời sai $wrong từ. Hãy ôn tập lại nhé!',
        channelId: 'vocab_channel',
        channelName: 'Học từ vựng',
      );
    }

    answerCtrl.clear();
    _nextWord();
  }

  Widget _counter(IconData icon, int n, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 4),
        Text('$n từ', style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ôn tập từ mới')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _counter(Icons.check, correct, Colors.greenAccent.shade400),
                _counter(Icons.close, wrong, Colors.orange),
              ],
            ),
            const SizedBox(height: 24),
            if (current == null)
              const Text('Chưa có từ nào. Hãy thêm từ ở Trang chính.')
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      current!.word,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: answerCtrl,
                      onSubmitted: (_) => _check(),
                      decoration: const InputDecoration(
                        hintText: 'Nhập nghĩa tiếng Việt',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _check,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade900,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text('Check'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
