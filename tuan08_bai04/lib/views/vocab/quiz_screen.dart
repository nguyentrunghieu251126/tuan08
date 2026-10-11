import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/word.dart';
import '../../services/vocab_file_service.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  static const int totalQuestions = 10;
  final _random = Random();

  List<Word> words = [];
  int asked = 0, correct = 0, wrong = 0;
  Word? qWord;
  String shownMeaning = '';
  bool isPairCorrect = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    words = await VocabFileService().loadWords();
    _newQuestion();
  }

  void _newQuestion() {
    if (words.isEmpty) {
      setState(() => qWord = null);
      return;
    }
    final w = words[_random.nextInt(words.length)];
    final others = words.where((e) => e.meaning != w.meaning).toList();
    final showRight = others.isEmpty || _random.nextBool();
    setState(() {
      qWord = w;
      isPairCorrect = showRight;
      shownMeaning = showRight
          ? w.meaning
          : others[_random.nextInt(others.length)].meaning;
    });
  }

  void _answer(bool userSaysCorrect) {
    setState(() {
      asked++;
      if (userSaysCorrect == isPairCorrect) {
        correct++;
      } else {
        wrong++;
      }
    });
    if (asked >= totalQuestions) {
      _showResult();
    } else {
      _newQuestion();
    }
  }

  void _restart() {
    setState(() {
      asked = 0;
      correct = 0;
      wrong = 0;
    });
    _newQuestion();
  }

  void _showResult() {
    final rate = asked == 0 ? 0 : correct * 100 / asked;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Kết thúc bài kiểm tra'),
        content: Text(
          'Tổng số câu: $asked\n'
          '✔ Đúng: $correct\n'
          '✘ Sai: $wrong\n'
          'Tỷ lệ chính xác: ${rate.toStringAsFixed(1)}%',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _restart();
            },
            child: const Text('Làm lại'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Thoát'),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      text,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trắc nghiệm Đúng / Sai')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: qWord == null
            ? const Center(
                child: Text('Chưa có từ nào. Hãy thêm từ ở Trang chính.'),
              )
            : Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _badge('✔ Đúng: $correct', Colors.green),
                      Text('Câu ${asked + 1}/$totalQuestions'),
                      _badge('✘ Sai: $wrong', Colors.orange),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    qWord!.word,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      shownMeaning,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _answer(true),
                        icon: const Icon(Icons.check),
                        label: const Text('Đúng'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _answer(false),
                        icon: const Icon(Icons.close),
                        label: const Text('Sai'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
      ),
    );
  }
}
