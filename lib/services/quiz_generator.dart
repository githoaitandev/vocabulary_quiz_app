import 'dart:math';
import '../models/models.dart';

class QuizGenerator {
  static final Random _random = Random();

  /// Tạo quiz từ danh sách vocabulary
  /// [vocabularyItems] - Danh sách từ vựng
  /// [questionCount] - Số câu hỏi muốn tạo
  /// [wordToMeaningRatio] - Tỷ lệ câu hỏi Word→Meaning (0.0 - 1.0)
  /// [preferUntested] - Ưu tiên từ chưa test (default: true)
  static List<Question> generateQuiz({
    required List<VocabularyItem> vocabularyItems,
    required int questionCount,
    double wordToMeaningRatio = 0.5, // 50% Word→Meaning, 50% Meaning→Word
    bool preferUntested = true,
  }) {
    // Filter to prefer quiz-untested vocabulary
    List<VocabularyItem> availableItems = vocabularyItems;
    if (preferUntested) {
      final quizUntestedItems = vocabularyItems.where((item) => !item.isQuizTested).toList();
      if (quizUntestedItems.isNotEmpty) {
        availableItems = quizUntestedItems;
      }
      // If no quiz-untested items, fall back to all items
    }
    
    // Check if we have any vocabulary at all
    if (vocabularyItems.isEmpty) {
      throw Exception('Need at least 1 vocabulary item to generate quiz');
    }
    
    // Check if we have any items available for questions
    if (availableItems.isEmpty) {
      throw Exception('No vocabulary items available for quiz');
    }

    if (questionCount > availableItems.length) {
      questionCount = availableItems.length;
    }

    List<Question> questions = [];
    
    // Shuffle vocabulary để random
    List<VocabularyItem> shuffledVocab = List.from(availableItems)..shuffle(_random);
    
    // Tính số câu hỏi cho mỗi loại
    int wordToMeaningCount = (questionCount * wordToMeaningRatio).round();
    // int meaningToWordCount = questionCount - wordToMeaningCount; // Unused for now

    // Tạo câu hỏi Word → Meaning
    for (int i = 0; i < wordToMeaningCount && i < shuffledVocab.length; i++) {
      Question question = _createWordToMeaningQuestion(
        shuffledVocab[i], 
        vocabularyItems, // Use full vocabulary list for wrong answers
      );
      questions.add(question);
    }

    // Tạo câu hỏi Meaning → Word
    for (int i = wordToMeaningCount; i < questionCount && i < shuffledVocab.length; i++) {
      Question question = _createMeaningToWordQuestion(
        shuffledVocab[i], 
        vocabularyItems, // Use full vocabulary list for wrong answers
      );
      questions.add(question);
    }

    // Shuffle câu hỏi
    questions.shuffle(_random);
    
    return questions;
  }

  /// Tạo câu hỏi Word → Meaning
  static Question _createWordToMeaningQuestion(
    VocabularyItem correctItem,
    List<VocabularyItem> allItems,
  ) {
    // Lấy tối đa 3 đáp án sai (có thể ít hơn nếu không đủ vocabulary)
    List<String> wrongAnswers = _getRandomMeanings(correctItem, allItems, 3);
    
    // Tạo danh sách tất cả đáp án
    List<String> options = [correctItem.meaning, ...wrongAnswers];
    
    // Shuffle đáp án
    options.shuffle(_random);

    return Question(
      questionText: correctItem.word,
      correctAnswer: correctItem.meaning,
      options: options,
      type: QuestionType.wordToMeaning,
    );
  }

  /// Tạo câu hỏi Meaning → Word
  static Question _createMeaningToWordQuestion(
    VocabularyItem correctItem,
    List<VocabularyItem> allItems,
  ) {
    // Lấy tối đa 3 đáp án sai (có thể ít hơn nếu không đủ vocabulary, thậm chí 0)
    List<String> wrongAnswers = _getRandomWords(correctItem, allItems, 3);
    
    // Tạo danh sách tất cả đáp án
    List<String> options = [correctItem.word, ...wrongAnswers];
    
    // Shuffle đáp án
    options.shuffle(_random);

    return Question(
      questionText: correctItem.meaning,
      correctAnswer: correctItem.word,
      options: options,
      type: QuestionType.meaningToWord,
    );
  }

  /// Lấy random meanings để làm đáp án sai
  static List<String> _getRandomMeanings(
    VocabularyItem excludeItem,
    List<VocabularyItem> allItems,
    int count,
  ) {
    List<String> meanings = allItems
        .where((item) => item.meaning != excludeItem.meaning)
        .map((item) => item.meaning)
        .toList();

    meanings.shuffle(_random);
    // Take only what's available, even if less than requested count
    return meanings.take(count).toList();
  }

  /// Lấy random words để làm đáp án sai
  static List<String> _getRandomWords(
    VocabularyItem excludeItem,
    List<VocabularyItem> allItems,
    int count,
  ) {
    List<String> words = allItems
        .where((item) => item.word != excludeItem.word)
        .map((item) => item.word)
        .toList();

    words.shuffle(_random);
    // Take only what's available, even if less than requested count
    return words.take(count).toList();
  }

  /// Tạo quiz với cấu hình tùy chỉnh
  static List<Question> generateCustomQuiz({
    required List<VocabularyItem> vocabularyItems,
    required QuizConfig config,
    bool preferUntested = true,
  }) {
    return generateQuiz(
      vocabularyItems: vocabularyItems,
      questionCount: config.questionCount,
      wordToMeaningRatio: config.wordToMeaningRatio,
      preferUntested: preferUntested,
    );
  }

  /// Validate có thể tạo quiz không
  static bool canGenerateQuiz(List<VocabularyItem> vocabularyItems, int questionCount, {bool preferUntested = true}) {
    // Check if we have enough total vocabulary for wrong answers (need at least 1 total for minimal quiz)
    if (vocabularyItems.isEmpty) {
      return false;
    }
    
    // Check if we have available items for questions
    List<VocabularyItem> availableItems = vocabularyItems;
    if (preferUntested) {
      final quizUntestedItems = vocabularyItems.where((item) => !item.isQuizTested).toList();
      if (quizUntestedItems.isNotEmpty) {
        availableItems = quizUntestedItems;
      }
    }
    return availableItems.isNotEmpty && questionCount > 0;
  }

  /// Lấy số câu hỏi tối đa có thể tạo
  static int getMaxQuestionCount(List<VocabularyItem> vocabularyItems, {bool preferUntested = true}) {
    List<VocabularyItem> availableItems = vocabularyItems;
    if (preferUntested) {
      final quizUntestedItems = vocabularyItems.where((item) => !item.isQuizTested).toList();
      if (quizUntestedItems.isNotEmpty) {
        availableItems = quizUntestedItems;
      }
    }
    return availableItems.length;
  }
  
  /// Get available vocabulary count for quiz generation
  static int getAvailableVocabularyCount(List<VocabularyItem> vocabularyItems, {bool preferUntested = true}) {
    if (preferUntested) {
      final quizUntestedItems = vocabularyItems.where((item) => !item.isQuizTested).toList();
      if (quizUntestedItems.isNotEmpty) {
        return quizUntestedItems.length;
      }
    }
    return vocabularyItems.length;
  }
}

/// Configuration cho quiz
class QuizConfig {
  final int questionCount;
  final double wordToMeaningRatio; // 0.0 = tất cả Meaning→Word, 1.0 = tất cả Word→Meaning
  final bool shuffleQuestions;
  final bool shuffleOptions;

  const QuizConfig({
    required this.questionCount,
    this.wordToMeaningRatio = 0.5,
    this.shuffleQuestions = true,
    this.shuffleOptions = true,
  });

  // Preset configs
  static const QuizConfig small = QuizConfig(questionCount: 10);
  static const QuizConfig medium = QuizConfig(questionCount: 20);
  static const QuizConfig large = QuizConfig(questionCount: 30);
  
  static const QuizConfig wordFocused = QuizConfig(
    questionCount: 15,
    wordToMeaningRatio: 0.8, // 80% Word→Meaning
  );
  
  static const QuizConfig meaningFocused = QuizConfig(
    questionCount: 15,
    wordToMeaningRatio: 0.2, // 20% Word→Meaning, 80% Meaning→Word
  );
}