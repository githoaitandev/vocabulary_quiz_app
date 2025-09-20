enum VocabularyTestStatus {
  untested,    // Chưa test
  quizTested,  // Đã test qua quiz
  typingTested, // Đã test qua typing
  bothTested,  // Đã test cả quiz và typing
}

class VocabularyItem {
  final String word;
  final String meaning;
  final String? example;
  
  // Tracking fields
  VocabularyTestStatus _testStatus;
  DateTime? _lastQuizTestedAt;
  DateTime? _lastTypingTestedAt;
  int _quizTestCount;
  int _typingTestCount;

  VocabularyItem({
    required this.word,
    required this.meaning,
    this.example,
    VocabularyTestStatus testStatus = VocabularyTestStatus.untested,
    DateTime? lastQuizTestedAt,
    DateTime? lastTypingTestedAt,
    int quizTestCount = 0,
    int typingTestCount = 0,
  }) : _testStatus = testStatus,
       _lastQuizTestedAt = lastQuizTestedAt,
       _lastTypingTestedAt = lastTypingTestedAt,
       _quizTestCount = quizTestCount,
       _typingTestCount = typingTestCount;

  /// Parse từ format: word[TAB]meaning | example
  /// Ví dụ: "attend a meeting\ttham dự cuộc họp | All department heads must attend..."
  factory VocabularyItem.fromTabSeparated(String line) {
    final parts = line.split('\t');
    if (parts.length < 2) {
      throw FormatException('Invalid format: expected word[TAB]meaning');
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
      // Default untested status for new imports
      testStatus: VocabularyTestStatus.untested,
    );
  }

  // Getters for test status
  VocabularyTestStatus get testStatus => _testStatus;
  DateTime? get lastQuizTestedAt => _lastQuizTestedAt;
  DateTime? get lastTypingTestedAt => _lastTypingTestedAt;
  int get quizTestCount => _quizTestCount;
  int get typingTestCount => _typingTestCount;
  
  // Convenience getters
  bool get isUntested => _testStatus == VocabularyTestStatus.untested;
  bool get isQuizTested => _testStatus == VocabularyTestStatus.quizTested || _testStatus == VocabularyTestStatus.bothTested;
  bool get isTypingTested => _testStatus == VocabularyTestStatus.typingTested || _testStatus == VocabularyTestStatus.bothTested;
  bool get isBothTested => _testStatus == VocabularyTestStatus.bothTested;
  bool get hasBeenTested => _testStatus != VocabularyTestStatus.untested;
  
  /// Mark as tested in quiz
  void markQuizTested() {
    _lastQuizTestedAt = DateTime.now();
    _quizTestCount++;
    
    switch (_testStatus) {
      case VocabularyTestStatus.untested:
        _testStatus = VocabularyTestStatus.quizTested;
        break;
      case VocabularyTestStatus.typingTested:
        _testStatus = VocabularyTestStatus.bothTested;
        break;
      case VocabularyTestStatus.quizTested:
      case VocabularyTestStatus.bothTested:
        // Already marked, just update timestamp and count
        break;
    }
  }
  
  /// Mark as tested in typing test
  void markTypingTested() {
    _lastTypingTestedAt = DateTime.now();
    _typingTestCount++;
    
    switch (_testStatus) {
      case VocabularyTestStatus.untested:
        _testStatus = VocabularyTestStatus.typingTested;
        break;
      case VocabularyTestStatus.quizTested:
        _testStatus = VocabularyTestStatus.bothTested;
        break;
      case VocabularyTestStatus.typingTested:
      case VocabularyTestStatus.bothTested:
        // Already marked, just update timestamp and count
        break;
    }
  }
  
  /// Reset test status
  void resetTestStatus() {
    _testStatus = VocabularyTestStatus.untested;
    _lastQuizTestedAt = null;
    _lastTypingTestedAt = null;
    _quizTestCount = 0;
    _typingTestCount = 0;
  }
  
  /// Reset only quiz test status
  void resetQuizTestStatus() {
    _lastQuizTestedAt = null;
    _quizTestCount = 0;
    
    switch (_testStatus) {
      case VocabularyTestStatus.quizTested:
        _testStatus = VocabularyTestStatus.untested;
        break;
      case VocabularyTestStatus.bothTested:
        _testStatus = VocabularyTestStatus.typingTested;
        break;
      case VocabularyTestStatus.untested:
      case VocabularyTestStatus.typingTested:
        // No change needed
        break;
    }
  }
  
  /// Reset only typing test status
  void resetTypingTestStatus() {
    _lastTypingTestedAt = null;
    _typingTestCount = 0;
    
    switch (_testStatus) {
      case VocabularyTestStatus.typingTested:
        _testStatus = VocabularyTestStatus.untested;
        break;
      case VocabularyTestStatus.bothTested:
        _testStatus = VocabularyTestStatus.quizTested;
        break;
      case VocabularyTestStatus.untested:
      case VocabularyTestStatus.quizTested:
        // No change needed
        break;
    }
  }
  
  /// Get last tested time (either quiz or typing)
  DateTime? get lastTestedAt {
    if (_lastQuizTestedAt == null && _lastTypingTestedAt == null) {
      return null;
    }
    if (_lastQuizTestedAt == null) return _lastTypingTestedAt;
    if (_lastTypingTestedAt == null) return _lastQuizTestedAt;
    
    return _lastQuizTestedAt!.isAfter(_lastTypingTestedAt!) 
        ? _lastQuizTestedAt 
        : _lastTypingTestedAt;
  }
  
  /// Get total test count
  int get totalTestCount => _quizTestCount + _typingTestCount;

  /// Chuyển về string để hiển thị
  @override
  String toString() {
    if (example != null) {
      return '$word: $meaning\nExample: $example';
    }
    return '$word: $meaning';
  }

  /// So sánh 2 VocabularyItem (chỉ dựa trên word, meaning, example - không so sánh test status)
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