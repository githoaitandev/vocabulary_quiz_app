import 'package:flutter/material.dart';
import '../models/models.dart';
import 'review_screen.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
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
    }
  }

  void _startNewQuiz() {
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  void _reviewIncorrectAnswers() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ReviewScreen()),
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

    final correctCount = quizSession!.correctCount;
    final totalCount = quizSession!.questions.length;
    final accuracy = quizSession!.accuracyPercentage;
    final completionTime = quizSession!.completionTime;
    final incorrectCount = quizSession!.incorrectQuestionIndices.length;

    // Phân tích theo loại câu hỏi
    int wordToMeaningCorrect = 0;
    int meaningToWordCorrect = 0;
    int wordToMeaningTotal = 0;
    int meaningToWordTotal = 0;

    for (int i = 0; i < quizSession!.questions.length; i++) {
      final question = quizSession!.questions[i];
      final userAnswer = quizSession!.userAnswers[i];
      final isCorrect = userAnswer != null && question.isCorrect(userAnswer);

      if (question.type == QuestionType.wordToMeaning) {
        wordToMeaningTotal++;
        if (isCorrect) wordToMeaningCorrect++;
      } else {
        meaningToWordTotal++;
        if (isCorrect) meaningToWordCorrect++;
      }
    }

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
                      '$correctCount / $totalCount',
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
                    if (completionTime != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Time: ${completionTime.inMinutes}:${(completionTime.inSeconds % 60).toString().padLeft(2, '0')}',
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
            if (quizSession!.incorrectQuestionIndices.isNotEmpty) ...[
              ElevatedButton.icon(
                onPressed: _reviewIncorrectAnswers,
                icon: const Icon(Icons.rate_review),
                label: Text('Review ${quizSession!.incorrectQuestionIndices.length} Incorrect Answers'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 16),
            ],

            ElevatedButton.icon(
              onPressed: _startNewQuiz,
              icon: const Icon(Icons.refresh),
              label: const Text('Start New Quiz'),
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
                    const Text(
                      'Quiz Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Overall stats
                    _buildStatRow('Total Questions', '$totalCount'),
                    _buildStatRow('Correct Answers', '$correctCount', Colors.green),
                    _buildStatRow('Incorrect Answers', '$incorrectCount', Colors.red),
                    _buildStatRow('Accuracy', '${accuracy.toStringAsFixed(1)}%', 
                      accuracy >= 80 ? Colors.green : accuracy >= 60 ? Colors.orange : Colors.red),
                    if (completionTime != null)
                      _buildStatRow('Completion Time', '${completionTime.inMinutes}m ${completionTime.inSeconds % 60}s'),
                    
                    const SizedBox(height: 12),
                    
                    // Question type breakdown
                    if (wordToMeaningTotal > 0 || meaningToWordTotal > 0) ...[
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