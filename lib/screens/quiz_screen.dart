import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../models/models.dart';
import '../services/services.dart';
import 'home_screen.dart';
import 'quiz_results_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  AppState get appState => AppState();
  QuizSession? get quizSession => appState.currentQuizSession;
  
  String? _selectedAnswer;
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _showTimer = true;
  bool _showAnswerFeedback = false;
  bool _isAnswerCorrect = false;

  @override
  void initState() {
    super.initState();
    final session = quizSession;
    if (session == null) {
      // No quiz session, navigate back
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
      return;
    }
    
    _selectedAnswer = session.currentAnswer;
    _startTimer();
  }

  void _startTimer() {
    if (_showTimer) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _elapsedSeconds++;
        });
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _selectAnswer(String answer) async {
    final isCorrect = answer == quizSession!.currentQuestion!.correctAnswer;
    
    setState(() {
      _selectedAnswer = answer;
      _showAnswerFeedback = true;
      _isAnswerCorrect = isCorrect;
    });
    
    quizSession!.answerCurrentQuestion(answer);
    
    // Play audio feedback if enabled
    if (appState.audioEnabled) {
      if (isCorrect) {
        await AudioService().playFeedback(AudioFeedbackType.correct);
      } else {
        await AudioService().playFeedback(AudioFeedbackType.incorrect);
      }
    }
  }

  void _nextQuestion() {
    if (quizSession!.nextQuestion()) {
      setState(() {
        _selectedAnswer = quizSession!.currentAnswer;
        _showAnswerFeedback = false;
        _isAnswerCorrect = false;
      });
    } else {
      _finishQuiz();
    }
  }

  void _previousQuestion() {
    if (quizSession!.previousQuestion()) {
      setState(() {
        _selectedAnswer = quizSession!.currentAnswer;
        _showAnswerFeedback = false;
        _isAnswerCorrect = false;
      });
    }
  }

  void _finishQuiz() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Finish Quiz'),
        content: Text(
          'Are you sure you want to finish the quiz?\n\n'
          'Progress: ${quizSession!.answeredCount}/${quizSession!.questions.length} questions answered'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continue Quiz'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              _submitQuiz();
            },
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }

  void _submitQuiz() async {
    quizSession!.finishQuiz();
    _timer?.cancel();
    
    // Play completion sound if enabled
    if (appState.audioEnabled) {
      await AudioService().playFeedback(AudioFeedbackType.completion);
    }
    
    // Navigate to results screen
    if (!mounted) return;
    try {
      Navigator.of(context).pushReplacementNamed('/quiz-results');
    } catch (e) {
      // Fallback: if named route fails, use direct route
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const QuizResultsScreen()),
        );
      }
    }
  }

  void _exitQuiz() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Quiz'),
        content: const Text('Are you sure you want to exit? Your progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () {
              if (mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Continue Quiz'),
          ),
          TextButton(
            onPressed: () async {
              // Clean up quiz session
              appState.endCurrentQuizSession();
              
              // Close dialog first
              if (mounted) {
                Navigator.of(context).pop();
              }
              
              // Then navigate back to home screen, clearing all routes
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildQuestionCard() {
    final session = quizSession;
    if (session == null) {
      return const Center(child: Text('No quiz session available'));
    }
    
    final question = session.currentQuestion;
    if (question == null) {
      return const Center(child: Text('No current question available'));
    }
    
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
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Answer options
            ...question.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final isSelected = _selectedAnswer == option;
              final isCorrect = option == question.correctAnswer;
              
              // Determine color based on feedback state
              Color? optionColor;
              Color? textColor;
              if (_showAnswerFeedback) {
                if (isSelected && _isAnswerCorrect) {
                  optionColor = Colors.green[100];
                  textColor = Colors.green[800];
                } else if (isSelected && !_isAnswerCorrect) {
                  optionColor = Colors.red[100];
                  textColor = Colors.red[800];
                } else if (isCorrect && !_isAnswerCorrect) {
                  optionColor = Colors.green[50];
                  textColor = Colors.green[700];
                }
              }
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Container(
                  decoration: BoxDecoration(
                    color: optionColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _showAnswerFeedback && isSelected
                          ? (_isAnswerCorrect ? Colors.green : Colors.red)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: RadioListTile<String>(
                    title: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: textColor ?? Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                            color: _showAnswerFeedback && isSelected
                                ? (_isAnswerCorrect ? Colors.green : Colors.red)
                                : null,
                          ),
                          child: Center(
                            child: _showAnswerFeedback && isSelected
                                ? Icon(
                                    _isAnswerCorrect ? Icons.check : Icons.close,
                                    size: 16,
                                    color: Colors.white,
                                  )
                                : Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ),
                        if (_showAnswerFeedback && isCorrect && !_isAnswerCorrect)
                          Icon(
                            Icons.check_circle,
                            color: Colors.green[700],
                            size: 20,
                          ),
                      ],
                    ),
                    value: option,
                    groupValue: _selectedAnswer,
                    onChanged: _showAnswerFeedback ? null : (value) {
                      if (value != null) {
                        _selectAnswer(value);
                      }
                    },
                    activeColor: _showAnswerFeedback
                        ? (_isAnswerCorrect ? Colors.green : Colors.red)
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
              );
            }),
            
            // Feedback message
            if (_showAnswerFeedback) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isAnswerCorrect ? Colors.green[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isAnswerCorrect ? Colors.green[300]! : Colors.red[300]!,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isAnswerCorrect ? Icons.check_circle : Icons.cancel,
                      color: _isAnswerCorrect ? Colors.green[700] : Colors.red[700],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _isAnswerCorrect
                            ? 'Correct! Well done!'
                            : 'Incorrect. The correct answer is: ${question.correctAnswer}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _isAnswerCorrect ? Colors.green[800] : Colors.red[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = (quizSession!.currentIndex + 1) / quizSession!.questions.length;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Question ${quizSession!.currentIndex + 1} of ${quizSession!.questions.length}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            if (_showTimer)
              Row(
                children: [
                  const Icon(Icons.timer, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(_elapsedSeconds),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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

  Widget _buildNavigationButtons() {
    final isFirstQuestion = quizSession!.currentIndex == 0;
    final isLastQuestion = quizSession!.currentIndex == quizSession!.questions.length - 1;
    
    return Row(
      children: [
        // Previous button
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isFirstQuestion ? null : _previousQuestion,
            icon: const Icon(Icons.chevron_left),
            label: const Text('Previous'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(12),
            ),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Next/Finish button
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: _selectedAnswer != null 
              ? (isLastQuestion ? _finishQuiz : _nextQuestion)
              : null,
            icon: Icon(isLastQuestion ? Icons.check : Icons.chevron_right),
            label: Text(isLastQuestion ? 'Finish Quiz' : 'Next'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(12),
              backgroundColor: isLastQuestion 
                ? Colors.green 
                : Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (quizSession == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return KeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKeyEvent: (KeyEvent event) {
        final session = quizSession;
        if (session == null) return;
        
        if (event is KeyDownEvent) {
          // Number keys 1-4 để chọn đáp án
          if (event.logicalKey.keyId >= LogicalKeyboardKey.digit1.keyId &&
              event.logicalKey.keyId <= LogicalKeyboardKey.digit4.keyId) {
            final optionIndex = event.logicalKey.keyId - LogicalKeyboardKey.digit1.keyId;
            final question = session.currentQuestion;
            if (question != null && optionIndex < question.options.length) {
              _selectAnswer(question.options[optionIndex]);
            }
          }
          // Arrow keys để navigate
          else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            _previousQuestion();
          }
          else if (event.logicalKey == LogicalKeyboardKey.arrowRight || 
                   event.logicalKey == LogicalKeyboardKey.enter) {
            if (_selectedAnswer != null) {
              if (session.currentIndex == session.questions.length - 1) {
                _finishQuiz();
              } else {
                _nextQuestion();
              }
            }
          }
        }
      },
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Session'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _exitQuiz,
        ),
        actions: [
          // Audio toggle
          IconButton(
            icon: Icon(appState.audioEnabled ? Icons.volume_up : Icons.volume_off),
            onPressed: () async {
              final bool newAudioState = !appState.audioEnabled;
              setState(() {
                appState.setAudioEnabled(newAudioState);
              });
              
              // Play test sound when enabling (system sound for UI feedback)
              if (newAudioState) {
                await AudioService().playFeedback(AudioFeedbackType.systemClick);
              }
              
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(newAudioState ? 'Audio feedback enabled' : 'Audio feedback disabled'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            tooltip: appState.audioEnabled ? 'Disable Audio' : 'Enable Audio',
          ),
          // Sound settings
          PopupMenuButton<String>(
            icon: const Icon(Icons.tune),
            tooltip: 'Sound Settings',
            onSelected: (value) async {
              if (value == 'toggle_custom_sounds') {
                final bool newCustomState = !appState.useCustomSounds;
                setState(() {
                  appState.setUseCustomSounds(newCustomState);
                });
                
                // Play test sound with new setting (system sound for UI feedback)
                if (appState.audioEnabled) {
                  await AudioService().playFeedback(AudioFeedbackType.systemClick);
                }
                
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(newCustomState ? 'Using custom sounds' : 'Using system sounds'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'toggle_custom_sounds',
                child: Row(
                  children: [
                    Icon(appState.useCustomSounds ? Icons.check_box : Icons.check_box_outline_blank),
                    const SizedBox(width: 8),
                    const Text('Use Custom Sounds'),
                  ],
                ),
              ),
            ],
          ),
          // Keyboard shortcuts info
          Tooltip(
            message: 'Keyboard shortcuts:\n1-4: Select answers\n←→: Navigate\nEnter: Next/Finish',
            child: IconButton(
              icon: const Icon(Icons.keyboard),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Use 1-4 keys to select answers, ←→ to navigate, Enter to continue'),
                    duration: Duration(seconds: 3),
                  ),
                );
              },
            ),
          ),
          IconButton(
            icon: Icon(_showTimer ? Icons.timer : Icons.timer_off),
            onPressed: () {
              setState(() {
                _showTimer = !_showTimer;
                if (_showTimer) {
                  _startTimer();
                } else {
                  _timer?.cancel();
                }
              });
            },
            tooltip: _showTimer ? 'Hide Timer' : 'Show Timer',
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
            
            // Question card
            Expanded(
              child: _buildQuestionCard(),
            ),
            
            const SizedBox(height: 20),
            
            // Navigation buttons
            _buildNavigationButtons(),
          ],
        ),
      ),
      ), // Close Scaffold
    ); // Close KeyboardListener
  }
}