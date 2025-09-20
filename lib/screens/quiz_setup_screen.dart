import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';
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
    _maxQuestions = QuizGenerator.getMaxQuestionCount(appState.vocabularyList, preferUntested: true);
    if (_questionCount > _maxQuestions) {
      _questionCount = _maxQuestions;
    }
  }

  void _generateQuiz() async {
    if (!QuizGenerator.canGenerateQuiz(appState.vocabularyList, _questionCount, preferUntested: true)) {
      // Play error sound if enabled (system sound for operations)
      if (appState.audioEnabled) {
        await AudioService().playFeedback(AudioFeedbackType.systemClick);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot generate quiz with current settings')),
      );
      return;
    }

    // Play click sound if enabled (system sound for navigation)
    if (appState.audioEnabled) {
      await AudioService().playFeedback(AudioFeedbackType.systemClick);
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
        preferUntested: true,
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
      // Play error sound if enabled (system sound for operations)
      if (appState.audioEnabled) {
        await AudioService().playFeedback(AudioFeedbackType.systemClick);
      }
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
      // Refresh max questions in case vocabulary status changed
      _maxQuestions = QuizGenerator.getMaxQuestionCount(appState.vocabularyList, preferUntested: true);
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
      body: appState.vocabularyCount == 0
          ? const Center(
              child: Text('No vocabulary available. Import vocabulary first.'),
            )
          : SingleChildScrollView(
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
                    Text('Quiz untested: ${appState.vocabularyList.where((item) => !item.isQuizTested).length}'),
                    Text('Quiz tested: ${appState.quizTestedCount}'),
                    Text('Typing tested: ${appState.typingTestedCount}'),
                    Text('Both tested: ${appState.bothTestedCount}'),
                    const SizedBox(height: 8),
                    Text(
                      appState.vocabularyList.where((item) => !item.isQuizTested).isNotEmpty
                          ? 'Quiz will prioritize quiz-untested words'
                          : 'All words have been quiz tested - using full vocabulary',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: appState.vocabularyList.where((item) => !item.isQuizTested).isNotEmpty ? Colors.blue : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Preset buttons
            Text(
              'Quick Setup',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // Improved preset buttons layout
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 5, // Number of presets
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final presets = [
                    {'name': 'Small', 'desc': '10 questions', 'config': QuizConfig.small, 'icon': Icons.flash_on},
                    {'name': 'Medium', 'desc': '20 questions', 'config': QuizConfig.medium, 'icon': Icons.quiz},
                    {'name': 'Large', 'desc': '30 questions', 'config': QuizConfig.large, 'icon': Icons.library_books},
                    {'name': 'Word Focus', 'desc': '80% W→M', 'config': QuizConfig.wordFocused, 'icon': Icons.abc},
                    {'name': 'Meaning Focus', 'desc': '80% M→W', 'config': QuizConfig.meaningFocused, 'icon': Icons.translate},
                  ];
                  
                  final preset = presets[index];
                  return SizedBox(
                    width: 100,
                    child: Card(
                      elevation: 2,
                      child: InkWell(
                        onTap: () => _usePreset(preset['config'] as QuizConfig),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                preset['icon'] as IconData,
                                size: 24,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                preset['name'] as String,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                preset['desc'] as String,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Custom settings
            Text(
              'Custom Settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Number of Questions',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '$_questionCount',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: _questionCount.toDouble().clamp(1, _maxQuestions > 0 ? _maxQuestions.toDouble() : 1),
                      min: 1,
                      max: _maxQuestions > 0 ? _maxQuestions.toDouble() : 1,
                      divisions: _maxQuestions > 1 ? _maxQuestions - 1 : 1,
                      onChanged: _maxQuestions > 0 ? (value) {
                        setState(() {
                          _questionCount = value.round();
                        });
                      } : null,
                    ),
                    Text(
                      'Range: 1 to $_maxQuestions available questions',
                      style: Theme.of(context).textTheme.bodySmall,
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
                    Text(
                      'Question Type Mix',
                      style: Theme.of(context).textTheme.titleMedium,
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
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Generate button
            ElevatedButton(
              onPressed: _isGenerating ? null : _generateQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _isGenerating 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.play_arrow),
                  const SizedBox(width: 8),
                  Text(
                    _isGenerating ? 'Generating Quiz...' : 'Start Quiz',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}