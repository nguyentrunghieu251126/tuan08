class Word {
  String word;
  String meaning;

  Word({required this.word, required this.meaning});

  String toFileString() => "$word|$meaning";

  static Word fromString(String line) {
    final parts = line.split("|");
    return Word(word: parts[0], meaning: parts.length > 1 ? parts[1] : "");
  }
}
