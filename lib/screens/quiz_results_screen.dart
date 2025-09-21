import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/results_widgets.dart';
import 'review_screen.dart';

class QuizResultsScreen extends StatefulWidget {
  const QuizResultsScreen({super.key});

  @override
  State<QuizResultsScreen> createState() => _QuizResultsScreenState();
}

class _QuizResultsScreenState extends State<QuizResultsScreen> {
  AppState get appState => AppState();
  QuizSession? get quizSession => appState.currentQuizSession;

  @override
  void initState() {
    super.initState();
    
    if (quizSession == null || !quizSession!.isCompleted) {
      // No completed quiz session, navigate back
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      });
    } else {
      // Mark vocabulary as tested
      _markVocabularyAsTested();
    }
  }

  void _markVocabularyAsTested() {
    if (quizSession != null) {
      // Mark only correctly answered vocabulary as tested
      final correctVocabulary = _getCorrectVocabularyFromQuiz(quizSession!);
      appState.markVocabularyQuizTestedIfCorrect(correctVocabulary);
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

  void _startNewQuiz() {
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  void _reviewIncorrectAnswers() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ReviewScreen()),
    );
  }

  Widget _buildQuestionTypeBreakdown() {
    if (quizSession == null) return const SizedBox.shrink();

    int wordToMeaningCorrect = 0;
    int meaningToWordCorrect = 0;
    int wordToMeaningTotal = 0;
    int meaningToWordTotal = 0;

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

    if (wordToMeaningTotal == 0 && meaningToWordTotal == 0) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
    );
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
    if (quizSession == null || !quizSession!.isCompleted) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final session = quizSession!;
    final accuracy = session.accuracyPercentage;
    final duration = session.completionTime;
    final correctCount = session.correctCount;
    final totalQuestions = session.questions.length;
    final incorrectCount = session.incorrectQuestionIndices.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
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
              testType: 'Quiz',
              onReviewIncorrect: _reviewIncorrectAnswers,
              onStartNew: _startNewQuiz,
              appState: appState,
            ),

            const Spacer(),

            // Summary stats with question type breakdown
            ResultsStatsCard(
              testType: 'Quiz',
              totalQuestions: totalQuestions,
              correctCount: correctCount,
              incorrectCount: incorrectCount,
              accuracyPercentage: accuracy,
              testDuration: duration,
              additionalStats: _buildQuestionTypeBreakdown(),
            ),
          ],
        ),
      ),
    );
  }
}