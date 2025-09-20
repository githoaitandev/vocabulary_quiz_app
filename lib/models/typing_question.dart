import 'vocabulary_item.dart';

enum TypingQuestionStatus {
  pending,    // Chưa trả lời
  correct,    // Đã trả lời đúng
  incorrect,  // Đã trả lời sai
}

class TypingQuestion {
  final String meaning;
  final String? example;
  final String correctWord;
  String userAnswer;
  TypingQuestionStatus status;
  DateTime? answeredAt;

  TypingQuestion({
    required this.meaning,
    this.example,
    required this.correctWord,
    this.userAnswer = '',
    this.status = TypingQuestionStatus.pending,
    this.answeredAt,
  });

  /// Tạo TypingQuestion từ VocabularyItem
  factory TypingQuestion.fromVocabularyItem(VocabularyItem item) {
    return TypingQuestion(
      meaning: item.meaning,
      example: item.example,
      correctWord: item.word,
    );
  }

  /// Kiểm tra đáp án có đúng không (case-insensitive và trim)
  bool checkAnswer(String answer) {
    final normalizedAnswer = answer.trim().toLowerCase();
    final normalizedCorrect = correctWord.trim().toLowerCase();
    return normalizedAnswer == normalizedCorrect;
  }

  /// Submit đáp án và cập nhật status
  void submitAnswer(String answer) {
    userAnswer = answer.trim();
    final isAnswerCorrect = checkAnswer(answer);
    status = isAnswerCorrect 
        ? TypingQuestionStatus.correct 
        : TypingQuestionStatus.incorrect;
    answeredAt = DateTime.now();
  }

  /// Reset question về trạng thái pending
  void reset() {
    userAnswer = '';
    status = TypingQuestionStatus.pending;
    answeredAt = null;
  }

  /// Check xem đã trả lời chưa
  bool get isAnswered => status != TypingQuestionStatus.pending;

  /// Check xem có đúng không
  bool get isCorrect => status == TypingQuestionStatus.correct;

  /// Hiển thị prompt cho user (meaning + example if available)
  String get prompt {
    if (example != null && example!.isNotEmpty) {
      return '$meaning\nExample: $example';
    }
    return meaning;
  }

  @override
  String toString() {
    return 'TypingQuestion: $meaning -> $correctWord (User: $userAnswer, Status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TypingQuestion &&
        other.meaning == meaning &&
        other.correctWord == correctWord;
  }

  @override
  int get hashCode => Object.hash(meaning, correctWord);
}