import 'models.dart';

/// Class quản lý toàn bộ app state trong memory
/// Có thể clear/dispose để giải phóng memory
class AppState {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  List<VocabularyItem> _vocabularyList = [];
  QuizSession? _currentQuizSession;

  /// Getter cho vocabulary list
  List<VocabularyItem> get vocabularyList => List.unmodifiable(_vocabularyList);

  /// Getter cho current quiz session
  QuizSession? get currentQuizSession => _currentQuizSession;

  /// Import vocabulary từ text
  void importVocabulary(List<VocabularyItem> items) {
    clearVocabulary(); // Clear cũ trước
    _vocabularyList.addAll(items);
  }

  /// Thêm một vocabulary item
  void addVocabularyItem(VocabularyItem item) {
    _vocabularyList.add(item);
  }

  /// Xóa toàn bộ vocabulary
  void clearVocabulary() {
    _vocabularyList.clear();
  }

  /// Tạo quiz session mới
  void startNewQuizSession(List<Question> questions) {
    // Dispose session cũ nếu có
    _currentQuizSession?.dispose();
    _currentQuizSession = QuizSession(questions: questions);
  }

  /// Kết thúc quiz session hiện tại
  void endCurrentQuizSession() {
    _currentQuizSession?.dispose();
    _currentQuizSession = null;
  }

  /// Clear toàn bộ app data (giải phóng memory)
  void clearAll() {
    clearVocabulary();
    endCurrentQuizSession();
  }

  /// Reset app về trạng thái ban đầu
  void reset() {
    clearAll();
  }

  /// Kiểm tra có vocabulary không
  bool get hasVocabulary => _vocabularyList.isNotEmpty;

  /// Kiểm tra có quiz session không
  bool get hasQuizSession => _currentQuizSession != null;

  /// Số lượng vocabulary items
  int get vocabularyCount => _vocabularyList.length;

  /// Lấy thống kê session hiện tại (nếu có)
  Map<String, dynamic>? get currentSessionStats {
    if (_currentQuizSession == null) return null;
    
    return {
      'totalQuestions': _currentQuizSession!.questions.length,
      'correctCount': _currentQuizSession!.correctCount,
      'answeredCount': _currentQuizSession!.answeredCount,
      'accuracy': _currentQuizSession!.accuracyPercentage,
      'isCompleted': _currentQuizSession!.isCompleted,
      'incorrectCount': _currentQuizSession!.incorrectQuestionIndices.length,
    };
  }
}