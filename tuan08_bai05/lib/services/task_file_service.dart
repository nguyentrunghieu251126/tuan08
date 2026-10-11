import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/task.dart';

class TaskFileService {
  Future<File> get _file async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/tasks.txt');
  }

  Future<List<Task>> loadTasks() async {
    try {
      final content = await (await _file).readAsString();
      return content
          .split('\n')
          .where((e) => e.trim().isNotEmpty)
          .map(Task.fromString)
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final file = await _file;
    await file.writeAsString(tasks.map((e) => e.toFileString()).join('\n'));
  }
}
