class VocabularyItem {
  final String word;
  final String meaning;
  final String? example;

  VocabularyItem({
    required this.word,
    required this.meaning,
    this.example,
  });

  /// Parse từ format: word<tab>meaning | example
  /// Ví dụ: "attend a meeting\ttham dự cuộc họp | All department heads must attend..."
  factory VocabularyItem.fromTabSeparated(String line) {
    final parts = line.split('\t');
    if (parts.length < 2) {
      throw FormatException('Invalid format: expected word<tab>meaning');
    }

    final word = parts[0].trim();
    final meaningAndExample = parts[1].trim();

    // Tách meaning và example bằng dấu |
    final meaningParts = meaningAndExample.split('|');
    final meaning = meaningParts[0].trim();
    final example = meaningParts.length > 1 ? meaningParts[1].trim() : null;

    return VocabularyItem(
      word: word,
      meaning: meaning,
      example: example,
    );
  }

  /// Chuyển về string để hiển thị
  @override
  String toString() {
    if (example != null) {
      return '$word: $meaning\nExample: $example';
    }
    return '$word: $meaning';
  }

  /// So sánh 2 VocabularyItem
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VocabularyItem &&
        other.word == word &&
        other.meaning == meaning &&
        other.example == example;
  }

  @override
  int get hashCode => Object.hash(word, meaning, example);
}