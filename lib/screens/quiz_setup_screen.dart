import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/quiz_generator.dart';
import 'quiz_screen.dart';

class QuizSetupScreen extends StatefulWidget {
  const QuizSetupScreen({super.key});

  @override
  State<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen> {
  AppState get appState => AppState();
  
  int _questionCount = 10;
  double _wordToMeaningRatio = 0.5;
  bool _isGenerating = false;

  late int _maxQuestions;

  @override
  void initState() {
    super.initState();
    _maxQuestions = QuizGenerator.getMaxQuestionCount(appState.vocabularyList);
    if (_questionCount > _maxQuestions) {
      _questionCount = _maxQuestions;
    }
  }

  void _generateQuiz() async {
    if (!QuizGenerator.canGenerateQuiz(appState.vocabularyList, _questionCount)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot generate quiz with current settings')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      // Delay ngắn để show loading
      await Future.delayed(const Duration(milliseconds: 500));

      List<Question> questions = QuizGenerator.generateQuiz(
        vocabularyItems: appState.vocabularyList,
        questionCount: _questionCount,
        wordToMeaningRatio: _wordToMeaningRatio,
      );

      // Tạo quiz session
      appState.startNewQuizSession(questions);

      if (mounted) {
        // Navigate to quiz screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const QuizScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating quiz: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  void _usePreset(QuizConfig config) {
    setState(() {
      _questionCount = config.questionCount.clamp(1, _maxQuestions);
      _wordToMeaningRatio = config.wordToMeaningRatio;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Setup'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Vocabulary info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vocabulary Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Total vocabulary items: ${appState.vocabularyCount}'),
                    Text('Maximum quiz questions: $_maxQuestions'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Preset buttons
            const Text(
              'Quick Setup',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => _usePreset(QuizConfig.small),
                  child: const Text('Small (10)'),
                ),
                ElevatedButton(
                  onPressed: () => _usePreset(QuizConfig.medium),
                  child: const Text('Medium (20)'),
                ),
                ElevatedButton(
                  onPressed: () => _usePreset(QuizConfig.large),
                  child: const Text('Large (30)'),
                ),
                ElevatedButton(
                  onPressed: () => _usePreset(QuizConfig.wordFocused),
                  child: const Text('Word Focus'),
                ),
                ElevatedButton(
                  onPressed: () => _usePreset(QuizConfig.meaningFocused),
                  child: const Text('Meaning Focus'),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Custom settings
            const Text(
              'Custom Settings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Question count slider
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Number of Questions: $_questionCount',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Slider(
                      value: _questionCount.toDouble(),
                      min: 1,
                      max: _maxQuestions.toDouble(),
                      divisions: _maxQuestions - 1,
                      onChanged: (value) {
                        setState(() {
                          _questionCount = value.round();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Question type ratio
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Question Type Mix',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Meaning→Word'),
                        Expanded(
                          child: Slider(
                            value: _wordToMeaningRatio,
                            min: 0.0,
                            max: 1.0,
                            divisions: 10,
                            onChanged: (value) {
                              setState(() {
                                _wordToMeaningRatio = value;
                              });
                            },
                          ),
                        ),
                        const Text('Word→Meaning'),
                      ],
                    ),
                    Text(
                      'Word→Meaning: ${(_wordToMeaningRatio * 100).round()}% | '
                      'Meaning→Word: ${((1 - _wordToMeaningRatio) * 100).round()}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const Spacer(),
            
            // Generate button
            ElevatedButton.icon(
              onPressed: _isGenerating ? null : _generateQuiz,
              icon: _isGenerating 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.play_arrow),
              label: Text(_isGenerating ? 'Generating Quiz...' : 'Start Quiz'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Info text
            Text(
              'This will create a new quiz with your selected settings.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}