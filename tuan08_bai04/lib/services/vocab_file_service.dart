import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/word.dart';

/// Đọc / ghi danh sách từ vựng vào file vocab.txt (Bài tập 4)
class VocabFileService {
  Future<File> get _file async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/vocab.txt');
  }

  Future<List<Word>> loadWords() async {
    try {
      final file = await _file;
      final content = await file.readAsString();
      return content
          .split("\n")
          .where((e) => e.trim().isNotEmpty)
          .map((e) => Word.fromString(e))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Ghi thêm 1 từ vào cuối file (FileMode.append – mục 1.2 của tài liệu)
  Future<void> addWord(Word w) async {
    final file = await _file;
    await file.writeAsString("${w.toFileString()}\n", mode: FileMode.append);
  }
}
