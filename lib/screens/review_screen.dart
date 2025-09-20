import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  AppState get appState => AppState();
  QuizSession? get quizSession => appState.currentQuizSession;
  TypingTestSession? get typingTestSession => appState.currentTypingTestSession;
  
  int _currentReviewIndex = 0;
  late List<int> _incorrectIndices;
  late bool _isTypingTestReview;

  @override
  void initState() {
    super.initState();
    
    // Check if we have typing test session first, then quiz session
    if (typingTestSession != null && typingTestSession!.isCompleted) {
      _isTypingTestReview = true;
      _incorrectIndices = _getTypingTestIncorrectIndices();
    } else if (quizSession != null && quizSession!.isCompleted) {
      _isTypingTestReview = false;
      _incorrectIndices = quizSession!.incorrectQuestionIndices;
    } else {
      // No completed session, navigate back
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
      });
      return;
    }
    
    if (_incorrectIndices.isEmpty) {
      // No incorrect answers, navigate back
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
      });
    }
  }

  List<int> _getTypingTestIncorrectIndices() {
    if (typingTestSession == null) return [];
    
    List<int> indices = [];
    for (int i = 0; i < typingTestSession!.questions.length; i++) {
      if (typingTestSession!.questions[i].status == TypingQuestionStatus.incorrect) {
        indices.add(i);
      }
    }
    return indices;
  }

  void _nextIncorrectQuestion() async {
    // Play click sound if enabled (system sound for navigation)
    if (appState.audioEnabled) {
      await AudioService().playFeedback(AudioFeedbackType.systemClick);
    }
    if (_currentReviewIndex < _incorrectIndices.length - 1) {
      setState(() {
        _currentReviewIndex++;
      });
    }
  }

  void _previousIncorrectQuestion() async {
    // Play click sound if enabled (system sound for navigation)
    if (appState.audioEnabled) {
      await AudioService().playFeedback(AudioFeedbackType.systemClick);
    }
    if (_currentReviewIndex > 0) {
      setState(() {
        _currentReviewIndex--;
      });
    }
  }

  void _backToResults() async {
    // Play click sound if enabled (system sound for navigation)
    if (appState.audioEnabled) {
      await AudioService().playFeedback(AudioFeedbackType.systemClick);
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Widget _buildReviewCard() {
    if (_isTypingTestReview) {
      return _buildTypingTestReviewCard();
    } else {
      return _buildQuizReviewCard();
    }
  }

  Widget _buildTypingTestReviewCard() {
    final questionIndex = _incorrectIndices[_currentReviewIndex];
    final question = typingTestSession!.questions[questionIndex];

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with question number
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Question ${questionIndex + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.red[700],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Typing Test',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.purple[700],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Meaning
            Text(
              'Meaning:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              question.meaning,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            // Example if available
            if (question.example != null && question.example!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Example:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                question.example!,
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Your answer (incorrect)
            _buildAnswerSection(
              'Your Answer:',
              question.userAnswer.isEmpty ? '(No answer)' : question.userAnswer,
              Colors.red,
              Icons.close,
            ),
            
            const SizedBox(height: 16),
            
            // Correct answer
            _buildAnswerSection(
              'Correct Answer:',
              question.correctWord,
              Colors.green,
              Icons.check,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizReviewCard() {
    final questionIndex = _incorrectIndices[_currentReviewIndex];
    final question = quizSession!.questions[questionIndex];
    final userAnswer = quizSession!.userAnswers[questionIndex];
    final correctAnswer = question.correctAnswer;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with question number
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Question ${questionIndex + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.red[700],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
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
              ],
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
            
            // User's answer (incorrect)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                border: Border.all(color: Colors.red[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.close, color: Colors.red[700], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Your Answer:',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userAnswer ?? 'No answer selected',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Correct answer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                border: Border.all(color: Colors.green[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check, color: Colors.green[700], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Correct Answer:',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    correctAnswer,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // All options for reference
            const Text(
              'All Options:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            ...question.options.map((option) {
              final isCorrect = option == correctAnswer;
              final isUserChoice = option == userAnswer;
              
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isCorrect 
                    ? Colors.green[100]
                    : isUserChoice 
                      ? Colors.red[100]
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(
                      isCorrect ? Icons.check_circle : 
                      isUserChoice ? Icons.cancel : Icons.radio_button_unchecked,
                      size: 16,
                      color: isCorrect ? Colors.green : 
                             isUserChoice ? Colors.red : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          color: isCorrect ? Colors.green[800] : 
                                 isUserChoice ? Colors.red[800] : Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Reviewing ${_currentReviewIndex + 1} of ${_incorrectIndices.length} incorrect answers',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              'Total: ${_incorrectIndices.length} errors',
              style: TextStyle(
                color: Colors.red[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: (_currentReviewIndex + 1) / _incorrectIndices.length,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(Colors.red[400]!),
        ),
      ],
    );
  }

  Widget _buildAnswerSection(String title, String answer, Color color, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            answer,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final isFirst = _currentReviewIndex == 0;
    final isLast = _currentReviewIndex == _incorrectIndices.length - 1;
    
    return Row(
      children: [
        // Previous button
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isFirst ? null : _previousIncorrectQuestion,
            icon: const Icon(Icons.chevron_left),
            label: const Text('Previous'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(12),
            ),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Next button
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isLast ? null : _nextIncorrectQuestion,
            icon: const Icon(Icons.chevron_right),
            label: const Text('Next'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(12),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check if we have any session to review
    bool hasSessionToReview = false;
    if (_isTypingTestReview) {
      hasSessionToReview = typingTestSession != null && typingTestSession!.isCompleted;
    } else {
      hasSessionToReview = quizSession != null && quizSession!.isCompleted;
    }
    
    if (!hasSessionToReview || _incorrectIndices.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isTypingTestReview ? 'Review Typing Test' : 'Review Quiz'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _backToResults,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            },
            tooltip: 'Back to Home',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress bar
            _buildProgressBar(),
            
            const SizedBox(height: 20),
            
            // Review card
            Expanded(
              child: _buildReviewCard(),
            ),
            
            const SizedBox(height: 20),
            
            // Navigation buttons
            _buildNavigationButtons(),
            
            const SizedBox(height: 16),
            
            // Back to results button
            ElevatedButton.icon(
              onPressed: _backToResults,
              icon: const Icon(Icons.assessment),
              label: const Text('Back to Results'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(12),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}