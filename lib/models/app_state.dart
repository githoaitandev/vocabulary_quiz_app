import 'models.dart';
import '../services/services.dart';

/// Class quản lý toàn bộ app state trong memory
/// Có thể clear/dispose để giải phóng memory
class AppState {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  final List<VocabularyItem> _vocabularyList = [];
  QuizSession? _currentQuizSession;
  TypingTestSession? _currentTypingTestSession;
  bool _audioEnabled = true; // Audio feedback setting
  bool _useCustomSounds = false; // Custom vs system sounds setting

  /// Getter cho vocabulary list
  List<VocabularyItem> get vocabularyList => List.unmodifiable(_vocabularyList);

  /// Getter cho current quiz session
  QuizSession? get currentQuizSession => _currentQuizSession;

  /// Getter cho current typing test session
  TypingTestSession? get currentTypingTestSession => _currentTypingTestSession;

  /// Audio settings
  bool get audioEnabled => _audioEnabled;
  void setAudioEnabled(bool enabled) {
    _audioEnabled = enabled;
  }

  /// Custom sound settings
  bool get useCustomSounds => _useCustomSounds;
  void setUseCustomSounds(bool useCustom) {
    _useCustomSounds = useCustom;
    // Update AudioService setting
    AudioService().setUseCustomSounds(useCustom);
  }

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
    // Clean up any existing sessions
    _currentQuizSession?.dispose();
    _currentTypingTestSession?.dispose();
    _currentTypingTestSession = null;
    
    _currentQuizSession = QuizSession(questions: questions);
  }

  /// Kết thúc quiz session hiện tại
  void endCurrentQuizSession() {
    _currentQuizSession?.dispose();
    _currentQuizSession = null;
  }

  /// Tạo typing test session mới
  void startNewTypingTestSession(TypingTestSession session) {
    // Clean up any existing sessions
    _currentTypingTestSession?.dispose();
    _currentQuizSession?.dispose();
    _currentQuizSession = null;
    
    _currentTypingTestSession = session;
  }

  /// Kết thúc typing test session hiện tại
  void endCurrentTypingTestSession() {
    _currentTypingTestSession?.dispose();
    _currentTypingTestSession = null;
  }

  /// Clear toàn bộ app data (giải phóng memory)
  void clearAll() {
    clearVocabulary();
    endCurrentQuizSession();
    endCurrentTypingTestSession();
  }

  /// Reset app về trạng thái ban đầu
  void reset() {
    clearAll();
  }

  /// Kiểm tra có vocabulary không
  bool get hasVocabulary => _vocabularyList.isNotEmpty;

  /// Kiểm tra có quiz session không
  bool get hasQuizSession => _currentQuizSession != null;

  /// Kiểm tra có typing test session không
  bool get hasTypingTestSession => _currentTypingTestSession != null;

  /// Số lượng vocabulary items
  int get vocabularyCount => _vocabularyList.length;
  
  /// Vocabulary tracking getters
  int get untestedCount => _vocabularyList.where((item) => item.isUntested).length;
  int get quizTestedCount => _vocabularyList.where((item) => item.isQuizTested).length;
  int get typingTestedCount => _vocabularyList.where((item) => item.isTypingTested).length;
  int get bothTestedCount => _vocabularyList.where((item) => item.isBothTested).length;
  int get totalTestedCount => _vocabularyList.where((item) => item.hasBeenTested).length;
  
  /// Get vocabulary by test status
  List<VocabularyItem> get untestedVocabulary => 
      _vocabularyList.where((item) => item.isUntested).toList();
  List<VocabularyItem> get quizTestedVocabulary => 
      _vocabularyList.where((item) => item.isQuizTested).toList();
  List<VocabularyItem> get typingTestedVocabulary => 
      _vocabularyList.where((item) => item.isTypingTested).toList();
  List<VocabularyItem> get bothTestedVocabulary => 
      _vocabularyList.where((item) => item.isBothTested).toList();
  List<VocabularyItem> get allTestedVocabulary => 
      _vocabularyList.where((item) => item.hasBeenTested).toList();
  
  /// Get available vocabulary for quiz (prefer quiz-untested, fallback to all)
  List<VocabularyItem> get availableForQuiz {
    final quizUntested = _vocabularyList.where((item) => !item.isQuizTested).toList();
    return quizUntested.isNotEmpty ? quizUntested : _vocabularyList;
  }
  
  /// Get available vocabulary for typing test (prefer typing-untested, fallback to all)
  List<VocabularyItem> get availableForTypingTest {
    final typingUntested = _vocabularyList.where((item) => !item.isTypingTested).toList();
    return typingUntested.isNotEmpty ? typingUntested : _vocabularyList;
  }
  
  /// Mark vocabulary items as tested after completing quiz
  void markVocabularyQuizTested(List<VocabularyItem> testedItems) {
    for (final item in testedItems) {
      // Find the actual item in our list and mark it
      final index = _vocabularyList.indexWhere((vocabItem) => 
          vocabItem.word == item.word && vocabItem.meaning == item.meaning);
      if (index != -1) {
        _vocabularyList[index].markQuizTested();
      }
    }
  }
  
  /// Mark vocabulary items as tested after completing typing test
  void markVocabularyTypingTested(List<VocabularyItem> testedItems) {
    for (final item in testedItems) {
      // Find the actual item in our list and mark it
      final index = _vocabularyList.indexWhere((vocabItem) => 
          vocabItem.word == item.word && vocabItem.meaning == item.meaning);
      if (index != -1) {
        _vocabularyList[index].markTypingTested();
      }
    }
  }
  
  /// Mark vocabulary items as quiz tested only if answered correctly
  void markVocabularyQuizTestedIfCorrect(List<VocabularyItem> correctItems) {
    for (final item in correctItems) {
      final index = _vocabularyList.indexWhere((vocabItem) => 
          vocabItem.word == item.word && vocabItem.meaning == item.meaning);
      if (index != -1) {
        _vocabularyList[index].markQuizTested();
      }
    }
  }
  
  /// Mark vocabulary items as typing tested only if typed correctly
  void markVocabularyTypingTestedIfCorrect(List<VocabularyItem> correctItems) {
    for (final item in correctItems) {
      final index = _vocabularyList.indexWhere((vocabItem) => 
          vocabItem.word.trim() == item.word.trim() && vocabItem.meaning.trim() == item.meaning.trim());
      if (index != -1) {
        _vocabularyList[index].markTypingTested();
      }
    }
  }
  
  /// Reset all test statuses
  void resetAllTestStatuses() {
    for (final item in _vocabularyList) {
      item.resetTestStatus();
    }
  }
  
  /// Reset only quiz test statuses
  void resetQuizTestStatuses() {
    for (final item in _vocabularyList) {
      item.resetQuizTestStatus();
    }
  }
  
  /// Reset only typing test statuses
  void resetTypingTestStatuses() {
    for (final item in _vocabularyList) {
      item.resetTypingTestStatus();
    }
  }
  
  /// Reset test status for specific vocabulary
  void resetTestStatus(VocabularyItem vocabularyItem) {
    final index = _vocabularyList.indexWhere((item) => 
        item.word == vocabularyItem.word && item.meaning == vocabularyItem.meaning);
    if (index != -1) {
      _vocabularyList[index].resetTestStatus();
    }
  }

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

  /// Lấy thống kê typing test session hiện tại (nếu có)
  Map<String, dynamic>? get currentTypingTestStats {
    if (_currentTypingTestSession == null) return null;
    
    return _currentTypingTestSession!.statistics;
  }
  
  /// Get vocabulary statistics
  Map<String, dynamic> get vocabularyStats {
    return {
      'total': vocabularyCount,
      'untested': untestedCount,
      'quizTested': quizTestedCount,
      'typingTested': typingTestedCount,
      'bothTested': bothTestedCount,
      'totalTested': totalTestedCount,
      'untestedPercentage': vocabularyCount > 0 ? (untestedCount / vocabularyCount * 100) : 0,
      'testedPercentage': vocabularyCount > 0 ? (totalTestedCount / vocabularyCount * 100) : 0,
    };
  }
}