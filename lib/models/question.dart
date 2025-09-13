enum QuestionType {
  wordToMeaning,  // Hiện word, chọn meaning
  meaningToWord,  // Hiện meaning, chọn word
}

class Question {
  final String questionText;
  final String correctAnswer;
  final List<String> options;  // Bao gồm cả đáp án đúng và sai
  final QuestionType type;

  Question({
    required this.questionText,
    required this.correctAnswer,
    required this.options,
    required this.type,
  });

  /// Kiểm tra đáp án có đúng không
  bool isCorrect(String selectedAnswer) {
    return selectedAnswer == correctAnswer;
  }

  /// Lấy index của đáp án đúng trong danh sách options
  int get correctAnswerIndex {
    return options.indexOf(correctAnswer);
  }

  @override
  String toString() {
    return 'Question: $questionText\nOptions: ${options.join(", ")}\nCorrect: $correctAnswer';
  }
}