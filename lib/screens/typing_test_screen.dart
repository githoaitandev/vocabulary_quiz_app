import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/common_widgets.dart';
import 'typing_results_screen.dart';

class TypingTestScreen extends StatefulWidget {
  const TypingTestScreen({super.key});

  @override
  State<TypingTestScreen> createState() => _TypingTestScreenState();
}

class _TypingTestScreenState extends State<TypingTestScreen>
    with TickerProviderStateMixin {
  AppState get appState => AppState();
  TypingTestSession? get session => appState.currentTypingTestSession;

  final TextEditingController _answerController = TextEditingController();
  final FocusNode _answerFocusNode = FocusNode();

  // Animation controllers
  late AnimationController _feedbackController;
  late AnimationController _progressController;
  late Animation<double> _feedbackAnimation;
  late Animation<double> _progressAnimation;

  // State
  bool _showFeedback = false;
  bool _isCorrect = false;
  String _feedbackMessage = '';
  Color _feedbackColor = Colors.green;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _answerFocusNode.requestFocus();

    // Check if session exists
    if (session == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
      });
    }
  }

  void _setupAnimations() {
    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _feedbackAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _feedbackController,
      curve: Curves.bounceOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    // Update progress animation when progress changes
    _updateProgressAnimation();
  }

  void _updateProgressAnimation() {
    if (session != null) {
      _progressController.animateTo(session!.progress);
    }
  }

  void _submitAnswer() async {
    if (session == null) return;

    final answer = _answerController.text.trim();
    if (answer.isEmpty) return;

    // Submit answer
    final isCorrect = session!.submitCurrentAnswer(answer);

    // Update state and show feedback
    setState(() {
      _isCorrect = isCorrect;
      _feedbackMessage = isCorrect ? 'Correct!' : 'Incorrect!';
      _feedbackColor = isCorrect ? Colors.green : Colors.red;
      _showFeedback = true;
    });

    // Play audio feedback
    if (appState.audioEnabled) {
      if (isCorrect) {
        await AudioService().playFeedback(AudioFeedbackType.correct);
      } else {
        await AudioService().playFeedback(AudioFeedbackType.incorrect);
      }
    }

    // Animate feedback
    _feedbackController.forward();

    // Clear input
    _answerController.clear();

    // Wait for feedback display
    await Future.delayed(const Duration(milliseconds: 1500));

    // Hide feedback
    _feedbackController.reverse();
    setState(() {
      _showFeedback = false;
    });

    // Check if test completed
    if (session!.isCompleted) {
      _finishTest();
    } else {
      // Move to next question
      session!.nextQuestion();
      _updateProgressAnimation();
      setState(() {});
      
      // Refocus input
      _answerFocusNode.requestFocus();
    }
  }

  void _finishTest() async {
    session?.finishTest();
    
    // Play completion sound
    if (appState.audioEnabled) {
      await AudioService().playFeedback(AudioFeedbackType.completion);
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const TypingResultsScreen(),
        ),
      );
    }
  }

  void _skipQuestion() {
    if (session == null) return;

    // Submit empty answer (will be marked incorrect)
    session!.submitCurrentAnswer('');
    
    setState(() {
      _showFeedback = false;
    });

    _answerController.clear();

    // Check if test completed
    if (session!.isCompleted) {
      _finishTest();
    } else {
      // Move to next question
      session!.nextQuestion();
      _updateProgressAnimation();
      setState(() {});
      
      // Refocus input
      _answerFocusNode.requestFocus();
    }
  }

  void _exitTest() {
    ConfirmDialog.show(
      context,
      title: 'Exit Typing Test',
      content: 'Are you sure you want to exit? Your progress will be lost.',
      confirmLabel: 'Exit',
      confirmColor: Colors.red,
      onConfirm: () {
        appState.endCurrentTypingTestSession();
        Navigator.of(context).pop();
      },
    );
  }

  Widget _buildCurrentQuestion() {
    final currentQuestion = session?.currentQuestion;
    if (currentQuestion == null) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question header
            Row(
              children: [
                Icon(
                  Icons.translate,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Type the English word:',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),

            // Meaning
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Meaning:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentQuestion.meaning,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  // Example if available
                  if (currentQuestion.example != null && 
                      currentQuestion.example!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Example:',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentQuestion.example!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerInput() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Your Answer:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),

            // Text input
            TextField(
              controller: _answerController,
              focusNode: _answerFocusNode,
              decoration: InputDecoration(
                hintText: 'Type the English word here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.keyboard),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _answerController.clear();
                  },
                ),
              ),
              style: Theme.of(context).textTheme.titleMedium,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submitAnswer(),
              autofocus: true,
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitAnswer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check),
                        SizedBox(width: 8),
                        Text('Submit'),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                OutlinedButton(
                  onPressed: _skipQuestion,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Skip'),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Hint text
            Text(
              'Press Enter to submit or use the button above',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    if (session == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${session!.answeredCount} / ${session!.totalQuestions}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                LinearProgressIndicator(
                  value: _progressAnimation.value,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Correct: ${session!.correctCount}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Incorrect: ${session!.incorrectCount}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (session!.answeredCount > 0)
                      Text(
                        'Accuracy: ${session!.accuracyPercentage.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeedback() {
    if (!_showFeedback) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _feedbackAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _feedbackAnimation.value,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _feedbackColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: _feedbackColor.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isCorrect ? Icons.check_circle : Icons.cancel,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  _feedbackMessage,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                // Show correct answer if incorrect
                if (!_isCorrect && session?.currentQuestion != null) ...[
                  const SizedBox(width: 16),
                  Text(
                    'Correct: ${session!.currentQuestion!.correctWord}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (session == null) {
      return const Scaffold(
        body: Center(
          child: LoadingWidget(message: 'Loading typing test...'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Typing Test'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _exitTest,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Typing Test Help'),
                  content: const Text(
                    'Read the meaning and example, then type the correct English word.\n\n'
                    '• Press Enter or tap Submit to check your answer\n'
                    '• Use Skip to move to the next word\n'
                    '• Answers are case-insensitive by default\n'
                    '• Your progress is tracked automatically',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Progress bar
              _buildProgressBar(),
              
              // Main content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Current question
                      _buildCurrentQuestion(),
                      
                      const SizedBox(height: 20),
                      
                      // Answer input
                      _buildAnswerInput(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Feedback overlay
          if (_showFeedback)
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: _buildFeedback(),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _answerController.dispose();
    _answerFocusNode.dispose();
    _feedbackController.dispose();
    _progressController.dispose();
    super.dispose();
  }
}