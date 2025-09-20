import 'dart:math';
import '../models/models.dart';

class TypingTestGenerator {
  static final Random _random = Random();

  /// Tạo typing test từ danh sách vocabulary
  /// [vocabularyItems] - Danh sách từ vựng
  /// [config] - Cấu hình typing test
  /// [preferUntested] - Ưu tiên từ chưa test (default: true)
  static TypingTestSession generateTypingTest({
    required List<VocabularyItem> vocabularyItems,
    TypingTestConfig? config,
    bool preferUntested = true,
  }) {
    config ??= const TypingTestConfig();

    // Filter to prefer typing-untested vocabulary
    List<VocabularyItem> availableItems = vocabularyItems;
    if (preferUntested) {
      final typingUntestedItems = vocabularyItems.where((item) => !item.isTypingTested).toList();
      if (typingUntestedItems.isNotEmpty) {
        availableItems = typingUntestedItems;
      }
      // If no typing-untested items, fall back to all items
    }

    if (availableItems.isEmpty) {
      throw Exception('Need at least 1 vocabulary item to generate typing test');
    }

    // Lấy số lượng questions theo config
    int questionCount = config.questionCount;
    if (questionCount <= 0 || questionCount > availableItems.length) {
      questionCount = availableItems.length;
    }

    // Chọn vocabulary items cho test
    List<VocabularyItem> selectedItems;
    if (config.shuffle) {
      selectedItems = List.from(availableItems)..shuffle(_random);
      selectedItems = selectedItems.take(questionCount).toList();
    } else {
      selectedItems = availableItems.take(questionCount).toList();
    }

    // Tạo typing test session
    return TypingTestSession.fromVocabulary(
      vocabularyItems: selectedItems,
      shuffle: config.shuffleQuestions,
    );
  }

  /// Validate có thể tạo typing test không
  static bool canGenerateTypingTest(List<VocabularyItem> vocabularyItems, {bool preferUntested = true}) {
    List<VocabularyItem> availableItems = vocabularyItems;
    if (preferUntested) {
      final typingUntestedItems = vocabularyItems.where((item) => !item.isTypingTested).toList();
      if (typingUntestedItems.isNotEmpty) {
        availableItems = typingUntestedItems;
      }
    }
    return availableItems.isNotEmpty;
  }

  /// Lấy số câu hỏi tối đa có thể tạo
  static int getMaxQuestionCount(List<VocabularyItem> vocabularyItems, {bool preferUntested = true}) {
    List<VocabularyItem> availableItems = vocabularyItems;
    if (preferUntested) {
      final typingUntestedItems = vocabularyItems.where((item) => !item.isTypingTested).toList();
      if (typingUntestedItems.isNotEmpty) {
        availableItems = typingUntestedItems;
      }
    }
    return availableItems.length;
  }

  /// Tạo typing test với cấu hình tùy chỉnh
  static TypingTestSession generateCustomTypingTest({
    required List<VocabularyItem> vocabularyItems,
    required TypingTestConfig config,
    bool preferUntested = true,
  }) {
    return generateTypingTest(
      vocabularyItems: vocabularyItems,
      config: config,
      preferUntested: preferUntested,
    );
  }
  
  /// Get available vocabulary count for typing test generation
  static int getAvailableVocabularyCount(List<VocabularyItem> vocabularyItems, {bool preferUntested = true}) {
    if (preferUntested) {
      final untestedItems = vocabularyItems.where((item) => item.isUntested).toList();
      if (untestedItems.isNotEmpty) {
        return untestedItems.length;
      }
    }
    return vocabularyItems.length;
  }
}

/// Configuration cho typing test
class TypingTestConfig {
  final int questionCount;
  final bool shuffle;
  final bool shuffleQuestions;
  final bool caseSensitive;
  final bool allowPartialMatch;

  const TypingTestConfig({
    this.questionCount = -1, // -1 means use all available
    this.shuffle = true,
    this.shuffleQuestions = true,
    this.caseSensitive = false,
    this.allowPartialMatch = false,
  });

  /// Preset configs
  static const TypingTestConfig quick = TypingTestConfig(
    questionCount: 10,
    shuffle: true,
  );

  static const TypingTestConfig standard = TypingTestConfig(
    questionCount: 20,
    shuffle: true,
  );

  static const TypingTestConfig comprehensive = TypingTestConfig(
    questionCount: -1, // Use all
    shuffle: true,
  );

  /// Copy with method để tạo config mới từ config hiện tại
  TypingTestConfig copyWith({
    int? questionCount,
    bool? shuffle,
    bool? shuffleQuestions,
    bool? caseSensitive,
    bool? allowPartialMatch,
  }) {
    return TypingTestConfig(
      questionCount: questionCount ?? this.questionCount,
      shuffle: shuffle ?? this.shuffle,
      shuffleQuestions: shuffleQuestions ?? this.shuffleQuestions,
      caseSensitive: caseSensitive ?? this.caseSensitive,
      allowPartialMatch: allowPartialMatch ?? this.allowPartialMatch,
    );
  }

  @override
  String toString() {
    return 'TypingTestConfig(questions: $questionCount, shuffle: $shuffle)';
  }
}