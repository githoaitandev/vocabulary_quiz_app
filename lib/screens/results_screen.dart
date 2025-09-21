import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';
import 'review_screen.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  AppState get appState => AppState();
  QuizSession? get quizSession => appState.currentQuizSession;
  TypingTestSession? get typingTestSession => appState.currentTypingTestSession;

  bool get isQuizResult => quizSession != null && quizSession!.isCompleted;
  bool get isTypingTestResult => typingTestSession != null && typingTestSession!.isCompleted;

  @override
  void initState() {
    super.initState();
    
    if (!isQuizResult && !isTypingTestResult) {
      // No completed session, navigate back
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      });
    } else {
      // Mark vocabulary as tested
      _markVocabularyAsTested();
    }
  }

  void _markVocabularyAsTested() {
    if (isQuizResult && quizSession != null) {
      // Mark only correctly answered vocabulary as tested
      final correctVocabulary = _getCorrectVocabularyFromQuiz(quizSession!);
      appState.markVocabularyQuizTestedIfCorrect(correctVocabulary);
    } else if (isTypingTestResult && typingTestSession != null) {
      // Mark only correctly typed vocabulary as tested
      final correctVocabulary = _getCorrectVocabularyFromTypingTest(typingTestSession!);
      appState.markVocabularyTypingTestedIfCorrect(correctVocabulary);
    }
  }

  List<VocabularyItem> _getCorrectVocabularyFromQuiz(QuizSession session) {
    List<VocabularyItem> correctItems = [];
    for (int i = 0; i < session.questions.length; i++) {
      if (i < session.userAnswers.length && session.questions[i].isCorrect(session.userAnswers[i] ?? '')) {
        final question = session.questions[i];
        if (question.type == QuestionType.wordToMeaning) {
          correctItems.add(VocabularyItem(
            word: question.questionText,
            meaning: question.correctAnswer,
          ));
        } else {
          correctItems.add(VocabularyItem(
            word: question.correctAnswer,
            meaning: question.questionText,
          ));
        }
      }
    }
    return correctItems;
  }

  List<VocabularyItem> _getCorrectVocabularyFromTypingTest(TypingTestSession session) {
    List<VocabularyItem> correctItems = [];
    for (final question in session.questions) {
      // Only mark as tested if the typing was correct
      if (question.status == TypingQuestionStatus.correct) {
        correctItems.add(VocabularyItem(
          word: question.correctWord,
          meaning: question.meaning,
          example: question.example,
        ));
      }
    }
    return correctItems;
  }

  void _startNewQuiz() async {
    // Play click sound if enabled (system sound for navigation)
    if (appState.audioEnabled) {
      await AudioService().playFeedback(AudioFeedbackType.systemClick);
    }
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  void _reviewIncorrectAnswers() async {
    // Play click sound if enabled (system sound for navigation)
    if (appState.audioEnabled) {
      await AudioService().playFeedback(AudioFeedbackType.systemClick);
    }
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ReviewScreen()),
    );
  }

  // Helper methods for getting results data - Priority: Typing test first
  int get totalQuestions {
    if (isTypingTestResult) return typingTestSession!.totalQuestions;
    if (isQuizResult) return quizSession!.questions.length;
    return 0;
  }

  int get correctCount {
    if (isTypingTestResult) return typingTestSession!.correctCount;
    if (isQuizResult) return quizSession!.correctCount;
    return 0;
  }

  int get incorrectCount {
    if (isTypingTestResult) return typingTestSession!.incorrectCount;
    if (isQuizResult) return quizSession!.incorrectQuestionIndices.length;
    return 0;
  }

  double get accuracyPercentage {
    if (isTypingTestResult) return typingTestSession!.accuracyPercentage;
    if (isQuizResult) return quizSession!.accuracyPercentage;
    return 0.0;
  }

  Duration? get testDuration {
    if (isTypingTestResult) return typingTestSession!.testDuration;
    if (isQuizResult) return quizSession!.completionTime;
    return null;
  }

  String get testType {
    if (isTypingTestResult) return 'Typing Test';
    if (isQuizResult) return 'Quiz';
    return 'Test';
  }

  Widget _buildStatRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isQuizResult && !isTypingTestResult) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final accuracy = accuracyPercentage;
    final duration = testDuration;

    // Type-specific data for quiz
    int wordToMeaningCorrect = 0;
    int meaningToWordCorrect = 0;
    int wordToMeaningTotal = 0;
    int meaningToWordTotal = 0;

    if (isQuizResult) {
      for (int i = 0; i < quizSession!.questions.length; i++) {
        final question = quizSession!.questions[i];
        final userAnswer = quizSession!.userAnswers[i];

        if (question.type == QuestionType.wordToMeaning) {
          wordToMeaningTotal++;
          if (userAnswer != null && question.isCorrect(userAnswer)) {
            wordToMeaningCorrect++;
          }
        } else {
          meaningToWordTotal++;
          if (userAnswer != null && question.isCorrect(userAnswer)) {
            meaningToWordCorrect++;
          }
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('$testType Results'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Score card
            Card(
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Icon(
                      accuracy >= 80 ? Icons.emoji_events : 
                      accuracy >= 60 ? Icons.thumb_up : Icons.thumb_down,
                      size: 64,
                      color: accuracy >= 80 ? Colors.amber : 
                             accuracy >= 60 ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '$correctCount / $totalQuestions',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${accuracy.toStringAsFixed(1)}% Correct',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    if (duration != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Time: ${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Performance message
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  accuracy >= 80 ? 'Excellent work! 🎉' :
                  accuracy >= 60 ? 'Good job! Keep practicing! 👍' :
                  'Keep studying and try again! 💪',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action buttons
            if (incorrectCount > 0) ...[
              ElevatedButton.icon(
                onPressed: _reviewIncorrectAnswers,
                icon: const Icon(Icons.rate_review),
                label: Text('Review $incorrectCount Incorrect Answers'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 16),
            ],

            ElevatedButton.icon(
              onPressed: _startNewQuiz,
              icon: const Icon(Icons.refresh),
              label: Text('Start New $testType'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),

            const Spacer(),

            // Summary stats
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$testType Summary',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Overall stats
                    _buildStatRow('Total Questions', '$totalQuestions'),
                    _buildStatRow('Correct Answers', '$correctCount', Colors.green),
                    _buildStatRow('Incorrect Answers', '$incorrectCount', Colors.red),
                    _buildStatRow('Accuracy', '${accuracy.toStringAsFixed(1)}%', 
                      accuracy >= 80 ? Colors.green : accuracy >= 60 ? Colors.orange : Colors.red),
                    if (duration != null)
                      _buildStatRow('Completion Time', '${duration.inMinutes}m ${duration.inSeconds % 60}s'),
                    
                    const SizedBox(height: 12),
                    
                    // Question type breakdown (only for quiz)
                    if (isQuizResult && (wordToMeaningTotal > 0 || meaningToWordTotal > 0)) ...[
                      const Divider(),
                      const Text(
                        'Performance by Question Type',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (wordToMeaningTotal > 0)
                        _buildStatRow('Word → Meaning', '$wordToMeaningCorrect/$wordToMeaningTotal (${((wordToMeaningCorrect / wordToMeaningTotal) * 100).toStringAsFixed(0)}%)', 
                          Colors.blue),
                      if (meaningToWordTotal > 0)
                        _buildStatRow('Meaning → Word', '$meaningToWordCorrect/$meaningToWordTotal (${((meaningToWordCorrect / meaningToWordTotal) * 100).toStringAsFixed(0)}%)', 
                          Colors.green),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}