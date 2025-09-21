import 'package:flutter/material.dart';
import '../services/services.dart';
import '../models/models.dart';

/// Reusable score card component for results screens
class ResultsScoreCard extends StatelessWidget {
  final int correctCount;
  final int totalQuestions;
  final double accuracyPercentage;
  final Duration? testDuration;

  const ResultsScoreCard({
    super.key,
    required this.correctCount,
    required this.totalQuestions,
    required this.accuracyPercentage,
    this.testDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(
              accuracyPercentage >= 80 ? Icons.emoji_events : 
              accuracyPercentage >= 60 ? Icons.thumb_up : Icons.thumb_down,
              size: 64,
              color: accuracyPercentage >= 80 ? Colors.amber : 
                     accuracyPercentage >= 60 ? Colors.green : Colors.orange,
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
              '${accuracyPercentage.toStringAsFixed(1)}% Correct',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            if (testDuration != null) ...[
              const SizedBox(height: 8),
              Text(
                'Time: ${testDuration!.inMinutes}:${(testDuration!.inSeconds % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Reusable action buttons component for results screens
class ResultsActionButtons extends StatelessWidget {
  final int incorrectCount;
  final String testType;
  final VoidCallback onReviewIncorrect;
  final VoidCallback onStartNew;
  final AppState appState;

  const ResultsActionButtons({
    super.key,
    required this.incorrectCount,
    required this.testType,
    required this.onReviewIncorrect,
    required this.onStartNew,
    required this.appState,
  });

  Future<void> _playClickSound() async {
    if (appState.audioEnabled) {
      await AudioService().playFeedback(AudioFeedbackType.systemClick);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (incorrectCount > 0) ...[
          ElevatedButton.icon(
            onPressed: () async {
              await _playClickSound();
              onReviewIncorrect();
            },
            icon: const Icon(Icons.rate_review),
            label: Text('Review $incorrectCount Incorrect Answers'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 16),
        ],
        ElevatedButton.icon(
          onPressed: () async {
            await _playClickSound();
            onStartNew();
          },
          icon: const Icon(Icons.refresh),
          label: Text('Start New $testType'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

/// Reusable stats card component for results screens
class ResultsStatsCard extends StatelessWidget {
  final String testType;
  final int totalQuestions;
  final int correctCount;
  final int incorrectCount;
  final double accuracyPercentage;
  final Duration? testDuration;
  final Widget? additionalStats;

  const ResultsStatsCard({
    super.key,
    required this.testType,
    required this.totalQuestions,
    required this.correctCount,
    required this.incorrectCount,
    required this.accuracyPercentage,
    this.testDuration,
    this.additionalStats,
  });

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
    return Card(
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
            _buildStatRow('Accuracy', '${accuracyPercentage.toStringAsFixed(1)}%', 
              accuracyPercentage >= 80 ? Colors.green : accuracyPercentage >= 60 ? Colors.orange : Colors.red),
            if (testDuration != null)
              _buildStatRow('Completion Time', '${testDuration!.inMinutes}m ${testDuration!.inSeconds % 60}s'),
            
            // Additional stats (e.g., question type breakdown for quiz)
            if (additionalStats != null) ...[
              const SizedBox(height: 12),
              additionalStats!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Performance message widget
class ResultsPerformanceMessage extends StatelessWidget {
  final double accuracyPercentage;

  const ResultsPerformanceMessage({
    super.key,
    required this.accuracyPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          accuracyPercentage >= 80 ? 'Excellent work! 🎉' :
          accuracyPercentage >= 60 ? 'Good job! Keep practicing! 👍' :
          'Keep studying and try again! 💪',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}