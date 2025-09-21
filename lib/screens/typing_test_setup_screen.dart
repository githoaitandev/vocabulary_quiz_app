import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/common_widgets.dart';
import 'typing_test_screen.dart';

class TypingTestSetupScreen extends StatefulWidget {
  const TypingTestSetupScreen({super.key});

  @override
  State<TypingTestSetupScreen> createState() => _TypingTestSetupScreenState();
}

class _TypingTestSetupScreenState extends State<TypingTestSetupScreen> {
  AppState get appState => AppState();

  // Configuration settings
  int _questionCount = 10;
  bool _shuffle = true;
  bool _caseSensitive = false;

  // Presets
  final List<Map<String, dynamic>> _presets = [
    {
      'name': 'Quick Test',
      'description': '10 random words',
      'config': TypingTestConfig.quick,
      'icon': Icons.flash_on,
    },
    {
      'name': 'Standard Test',
      'description': '20 random words',
      'config': TypingTestConfig.standard,
      'icon': Icons.quiz,
    },
    {
      'name': 'Comprehensive',
      'description': 'All vocabulary',
      'config': TypingTestConfig.comprehensive,
      'icon': Icons.library_books,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Set default question count based on available vocabulary size
    final availableCount = TypingTestGenerator.getMaxQuestionCount(appState.vocabularyList, preferUntested: true);
    _questionCount = (availableCount * 0.3).round().clamp(1, availableCount > 0 ? availableCount : 1);
  }

  void _applyPreset(TypingTestConfig config) {
    setState(() {
      final availableCount = TypingTestGenerator.getMaxQuestionCount(appState.vocabularyList, preferUntested: true);
      // Clamp preset questionCount to available count
      _questionCount = config.questionCount == -1 
          ? availableCount 
          : config.questionCount.clamp(1, availableCount > 0 ? availableCount : 1);
      _shuffle = config.shuffle;
      _caseSensitive = config.caseSensitive;
    });
  }

  void _startTypingTest() async {
    try {
      // Validate before generating
      if (!TypingTestGenerator.canGenerateTypingTest(appState.vocabularyList, preferUntested: true)) {
        if (appState.audioEnabled) {
          await AudioService().playFeedback(AudioFeedbackType.systemClick);
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot generate typing test with current settings')),
        );
        return;
      }
      
      // Play click sound
      if (appState.audioEnabled) {
        await AudioService().playFeedback(AudioFeedbackType.systemClick);
      }

      // Create config with validated question count
      final availableCount = TypingTestGenerator.getMaxQuestionCount(appState.vocabularyList, preferUntested: true);
      final validQuestionCount = _questionCount.clamp(1, availableCount > 0 ? availableCount : 1);
      
      final config = TypingTestConfig(
        questionCount: validQuestionCount,
        shuffle: _shuffle,
        caseSensitive: _caseSensitive,
      );

      // Generate typing test with available vocabulary (prefer typing-untested)
      final session = TypingTestGenerator.generateTypingTest(
        vocabularyItems: appState.vocabularyList,
        config: config,
        preferUntested: true,
      );

      // Start session
      appState.startNewTypingTestSession(session);

      // Navigate to typing test screen
      if (mounted) {
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const TypingTestScreen(),
          ),
        );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting typing test: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildStatusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vocabularyCount = appState.vocabularyCount;
    final availableCount = TypingTestGenerator.getMaxQuestionCount(appState.vocabularyList, preferUntested: true);
    final hasUntestedWords = appState.vocabularyList.where((item) => !item.isTypingTested).isNotEmpty;
    final canStart = availableCount > 0 && _questionCount > 0 && hasUntestedWords;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Typing Test Setup'),
        elevation: 0,
      ),
      body: vocabularyCount == 0
          ? const Center(
              child: EmptyStateWidget(
                icon: Icons.quiz_outlined,
                title: 'No Vocabulary Available',
                subtitle: 'Import vocabulary first to create a typing test',
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
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
                          Row(
                            children: [
                              Icon(Icons.book, color: Theme.of(context).primaryColor),
                              const SizedBox(width: 8),
                              Text(
                                'Available Vocabulary',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$vocabularyCount words available for typing test',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              _buildStatusChip('${appState.vocabularyList.where((item) => !item.isTypingTested).length} typing untested', Colors.orange),
                              _buildStatusChip('${appState.quizTestedCount} quiz tested', Colors.blue),
                              _buildStatusChip('${appState.typingTestedCount} typing tested', Colors.green),
                              _buildStatusChip('${appState.bothTestedCount} both tested', Colors.purple),
                            ],
                          ),
                          if (appState.vocabularyList.where((item) => !item.isTypingTested).isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Test will prioritize typing-untested words',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                          // Show reset message if all words are typing tested
                          if (appState.vocabularyList.where((item) => !item.isTypingTested).isEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.orange.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.orange, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'All vocabulary has been typing tested. Consider resetting typing status to practice untested words.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange[700],
                                        fontWeight: FontWeight.w500,
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
                  ),
                  
                  const SizedBox(height: 16),

                  Text(
                    'Quick Setup',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Compact preset buttons in a single row
                  SizedBox(
                    height: 80,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _presets.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final preset = _presets[index];
                        return SizedBox(
                          width: 120,
                          child: Card(
                            elevation: 2,
                            child: InkWell(
                              onTap: () => _applyPreset(preset['config']),
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      preset['icon'],
                                      size: 24,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      preset['name'],
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      preset['description'],
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
                                'Number of Words',
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
                            value: _questionCount.toDouble().clamp(1, availableCount > 0 ? availableCount.toDouble() : 1),
                            min: 1,
                            max: availableCount > 0 ? availableCount.toDouble() : 1,
                            divisions: availableCount > 1 ? availableCount - 1 : 1,
                            onChanged: availableCount > 0 ? (value) {
                              setState(() {
                                _questionCount = value.round();
                              });
                            } : null,
                          ),
                          Text(
                            'Range: 1 to $availableCount available words',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Options
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Options',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          SwitchListTile(
                            title: const Text('Shuffle Words'),
                            subtitle: const Text('Randomize word order'),
                            value: _shuffle,
                            onChanged: (value) {
                              setState(() {
                                _shuffle = value;
                              });
                            },
                          ),
                          SwitchListTile(
                            title: const Text('Case Sensitive'),
                            subtitle: const Text('Exact case matching required'),
                            value: _caseSensitive,
                            onChanged: (value) {
                              setState(() {
                                _caseSensitive = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Start button
                  ElevatedButton(
                    onPressed: canStart ? _startTypingTest : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canStart ? Theme.of(context).primaryColor : Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.keyboard),
                        const SizedBox(width: 8),
                        Text(
                          'Start Typing Test',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }
}