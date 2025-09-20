import 'typing_question.dart';
import 'vocabulary_item.dart';

class TypingTestSession {
  final List<TypingQuestion> questions;
  int _currentIndex;
  DateTime? startTime;
  DateTime? endTime;

  TypingTestSession({
    required this.questions,
    int currentIndex = 0,
  }) : _currentIndex = currentIndex {
    startTime = DateTime.now();
  }

  /// Tạo typing test session từ vocabulary items
  factory TypingTestSession.fromVocabulary({
    required List<VocabularyItem> vocabularyItems,
    bool shuffle = true,
  }) {
    List<VocabularyItem> items = List.from(vocabularyItems);
    if (shuffle) {
      items.shuffle();
    }

    List<TypingQuestion> questions = items
        .map((item) => TypingQuestion.fromVocabularyItem(item))
        .toList();

    return TypingTestSession(questions: questions);
  }

  /// Current question index
  int get currentIndex => _currentIndex;

  /// Current question
  TypingQuestion? get currentQuestion {
    if (_currentIndex >= 0 && _currentIndex < questions.length) {
      return questions[_currentIndex];
    }
    return null;
  }

  /// Total số questions
  int get totalQuestions => questions.length;

  /// Số questions đã answered
  int get answeredCount => questions.where((q) => q.isAnswered).length;

  /// Số câu trả lời đúng
  int get correctCount => questions.where((q) => q.isCorrect).length;

  /// Số câu trả lời sai
  int get incorrectCount => questions.where((q) => 
      q.status == TypingQuestionStatus.incorrect).length;

  /// Progress percentage (0.0 - 1.0)
  double get progress => totalQuestions > 0 ? answeredCount / totalQuestions : 0.0;

  /// Accuracy percentage (0.0 - 100.0)
  double get accuracyPercentage {
    if (answeredCount == 0) return 0.0;
    return (correctCount / answeredCount) * 100;
  }

  /// Check xem test đã hoàn thành chưa
  bool get isCompleted => answeredCount == totalQuestions;

  /// Check có previous question không
  bool get hasPrevious => _currentIndex > 0;

  /// Check có next question không
  bool get hasNext => _currentIndex < totalQuestions - 1;

  /// Submit answer cho current question
  bool submitCurrentAnswer(String answer) {
    final current = currentQuestion;
    if (current == null) return false;

    current.submitAnswer(answer);
    return current.isCorrect;
  }

  /// Move to next question
  bool nextQuestion() {
    if (hasNext) {
      _currentIndex++;
      return true;
    }
    return false;
  }

  /// Move to previous question
  bool previousQuestion() {
    if (hasPrevious) {
      _currentIndex--;
      return true;
    }
    return false;
  }

  /// Go to specific question index
  bool goToQuestion(int index) {
    if (index >= 0 && index < totalQuestions) {
      _currentIndex = index;
      return true;
    }
    return false;
  }

  /// Finish test và set end time
  void finishTest() {
    endTime = DateTime.now();
  }

  /// Duration của test (nếu đã finish)
  Duration? get testDuration {
    if (startTime != null && endTime != null) {
      return endTime!.difference(startTime!);
    }
    return null;
  }

  /// Get incorrect questions for review
  List<TypingQuestion> get incorrectQuestions {
    return questions.where((q) => 
        q.status == TypingQuestionStatus.incorrect).toList();
  }

  /// Get indices of incorrect questions
  List<int> get incorrectQuestionIndices {
    List<int> indices = [];
    for (int i = 0; i < questions.length; i++) {
      if (questions[i].status == TypingQuestionStatus.incorrect) {
        indices.add(i);
      }
    }
    return indices;
  }

  /// Reset entire session
  void reset() {
    for (var question in questions) {
      question.reset();
    }
    _currentIndex = 0;
    startTime = DateTime.now();
    endTime = null;
  }

  /// Restart từ question đầu tiên (không reset answers)
  void restart() {
    _currentIndex = 0;
  }

  /// Get session statistics
  Map<String, dynamic> get statistics {
    return {
      'totalQuestions': totalQuestions,
      'answeredCount': answeredCount,
      'correctCount': correctCount,
      'incorrectCount': incorrectCount,
      'accuracy': accuracyPercentage,
      'progress': progress,
      'isCompleted': isCompleted,
      'duration': testDuration?.inSeconds,
    };
  }

  /// Dispose session để free memory
  void dispose() {
    // Clear references if needed
    questions.clear();
  }

  @override
  String toString() {
    return 'TypingTestSession: $answeredCount/$totalQuestions questions answered, '
           '$correctCount correct (${accuracyPercentage.toStringAsFixed(1)}%)';
  }
}