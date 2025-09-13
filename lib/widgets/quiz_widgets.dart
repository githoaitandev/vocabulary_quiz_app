import 'package:flutter/material.dart';
import '../models/models.dart';

class QuestionWidget extends StatelessWidget {
  final Question question;
  final String? selectedAnswer;
  final ValueChanged<String> onAnswerSelected;

  const QuestionWidget({
    super.key,
    required this.question,
    required this.selectedAnswer,
    required this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question type indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: question.type == QuestionType.wordToMeaning 
                  ? Colors.blue[100] 
                  : Colors.green[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                question.type == QuestionType.wordToMeaning 
                  ? 'Word → Meaning' 
                  : 'Meaning → Word',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: question.type == QuestionType.wordToMeaning 
                    ? Colors.blue[700] 
                    : Colors.green[700],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Question text
            Text(
              question.questionText,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Answer options
            ...question.options.map((option) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: RadioListTile<String>(
                title: Text(
                  option,
                  style: const TextStyle(fontSize: 16),
                ),
                value: option,
                groupValue: selectedAnswer,
                onChanged: (value) {
                  if (value != null) {
                    onAnswerSelected(value);
                  }
                },
                activeColor: Theme.of(context).colorScheme.primary,
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class ProgressIndicatorWidget extends StatelessWidget {
  final int currentIndex;
  final int totalQuestions;
  final int elapsedSeconds;
  final bool showTimer;

  const ProgressIndicatorWidget({
    super.key,
    required this.currentIndex,
    required this.totalQuestions,
    required this.elapsedSeconds,
    this.showTimer = true,
  });

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = (currentIndex + 1) / totalQuestions;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Question ${currentIndex + 1} of $totalQuestions',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            if (showTimer)
              Row(
                children: [
                  const Icon(Icons.timer, size: 16),
                  const SizedBox(width: 4),
                  Text(_formatTime(elapsedSeconds)),
                ],
              ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}