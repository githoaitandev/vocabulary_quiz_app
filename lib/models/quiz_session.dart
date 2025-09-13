import 'question.dart';

class QuizSession {
  final List<Question> questions;
  final DateTime startTime;
  
  int currentIndex;
  List<String?> userAnswers;  // null = chưa trả lời
  DateTime? endTime;

  QuizSession({
    required this.questions,
    this.currentIndex = 0,
  }) : startTime = DateTime.now(),
       userAnswers = List.filled(questions.length, null);

  /// Giải phóng memory - clear tất cả data
  void dispose() {
    questions.clear();
    userAnswers.clear();
    endTime = null;
    currentIndex = 0;
  }

  /// Reset quiz session (giữ questions nhưng clear answers)
  void reset() {
    currentIndex = 0;
    userAnswers = List.filled(questions.length, null);
    endTime = null;
  }

  /// Trả lời câu hỏi hiện tại
  void answerCurrentQuestion(String answer) {
    if (currentIndex < questions.length) {
      userAnswers[currentIndex] = answer;
    }
  }

  /// Chuyển câu hỏi tiếp theo
  bool nextQuestion() {
    if (currentIndex < questions.length - 1) {
      currentIndex++;
      return true;
    }
    return false;
  }

  /// Quay lại câu hỏi trước
  bool previousQuestion() {
    if (currentIndex > 0) {
      currentIndex--;
      return true;
    }
    return false;
  }

  /// Hoàn thành quiz
  void finishQuiz() {
    endTime = DateTime.now();
  }

  /// Tổng số câu đúng
  int get correctCount {
    int count = 0;
    for (int i = 0; i < questions.length; i++) {
      if (userAnswers[i] != null && questions[i].isCorrect(userAnswers[i]!)) {
        count++;
      }
    }
    return count;
  }

  /// Tổng số câu đã trả lời
  int get answeredCount {
    return userAnswers.where((answer) => answer != null).length;
  }

  /// Phần trăm đúng
  double get accuracyPercentage {
    if (questions.isEmpty) return 0.0;
    return (correctCount / questions.length) * 100;
  }

  /// Thời gian làm bài (nếu đã hoàn thành)
  Duration? get completionTime {
    if (endTime != null) {
      return endTime!.difference(startTime);
    }
    return null;
  }

  /// Câu hỏi hiện tại
  Question? get currentQuestion {
    if (currentIndex < questions.length) {
      return questions[currentIndex];
    }
    return null;
  }

  /// Đáp án của câu hỏi hiện tại
  String? get currentAnswer {
    if (currentIndex < questions.length) {
      return userAnswers[currentIndex];
    }
    return null;
  }

  /// Danh sách các câu trả lời sai (để review)
  List<int> get incorrectQuestionIndices {
    List<int> incorrect = [];
    for (int i = 0; i < questions.length; i++) {
      if (userAnswers[i] != null && !questions[i].isCorrect(userAnswers[i]!)) {
        incorrect.add(i);
      }
    }
    return incorrect;
  }

  /// Kiểm tra quiz đã hoàn thành chưa
  bool get isCompleted {
    return endTime != null;
  }

  /// Kiểm tra tất cả câu đã được trả lời chưa
  bool get isAllAnswered {
    return answeredCount == questions.length;
  }
}