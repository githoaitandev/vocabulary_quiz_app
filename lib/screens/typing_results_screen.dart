import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/results_widgets.dart';
import 'review_screen.dart';

class TypingResultsScreen extends StatefulWidget {
  const TypingResultsScreen({super.key});

  @override
  State<TypingResultsScreen> createState() => _TypingResultsScreenState();
}

class _TypingResultsScreenState extends State<TypingResultsScreen> {
  AppState get appState => AppState();
  TypingTestSession? get typingTestSession => appState.currentTypingTestSession;

  @override
  void initState() {
    super.initState();
    
    if (typingTestSession == null || !typingTestSession!.isCompleted) {
      // No completed typing test session, navigate back
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      });
    } else {
      // Mark vocabulary as tested
      _markVocabularyAsTested();
    }
  }

  void _markVocabularyAsTested() {
    if (typingTestSession != null) {
      // Mark only correctly typed vocabulary as tested
      final correctVocabulary = _getCorrectVocabularyFromTypingTest(typingTestSession!);
      appState.markVocabularyTypingTestedIfCorrect(correctVocabulary);
    }
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

  void _startNewQuiz() {
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  void _reviewIncorrectAnswers() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ReviewScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (typingTestSession == null || !typingTestSession!.isCompleted) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final session = typingTestSession!;
    final accuracy = session.accuracyPercentage;
    final duration = session.testDuration;
    final correctCount = session.correctCount;
    final totalQuestions = session.totalQuestions;
    final incorrectCount = session.incorrectCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Typing Test Results'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Score card
            ResultsScoreCard(
              correctCount: correctCount,
              totalQuestions: totalQuestions,
              accuracyPercentage: accuracy,
              testDuration: duration,
            ),

            const SizedBox(height: 24),

            // Performance message
            ResultsPerformanceMessage(accuracyPercentage: accuracy),

            const SizedBox(height: 24),

            // Action buttons
            ResultsActionButtons(
              incorrectCount: incorrectCount,
              testType: 'Typing Test',
              onReviewIncorrect: _reviewIncorrectAnswers,
              onStartNew: _startNewQuiz,
              appState: appState,
            ),

            const Spacer(),

            // Summary stats
            ResultsStatsCard(
              testType: 'Typing Test',
              totalQuestions: totalQuestions,
              correctCount: correctCount,
              incorrectCount: incorrectCount,
              accuracyPercentage: accuracy,
              testDuration: duration,
            ),
          ],
        ),
      ),
    );
  }
}