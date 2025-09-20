import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';
import '../services/services.dart';
import 'import_screen.dart';
import 'quiz_setup_screen.dart';
import 'typing_test_setup_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppState get appState => AppState();

  bool get hasVocabulary => appState.hasVocabulary;
  int get vocabularyCount => appState.vocabularyCount;
  List<VocabularyItem> get vocabularyList => appState.vocabularyList;

  @override
  void initState() {
    super.initState();
  }

  void _navigateToImport() async {
    // Play click sound if enabled (system sound for navigation)
    if (appState.audioEnabled) {
      await AudioService().playFeedback(AudioFeedbackType.systemClick);
    }
    
    if (!mounted) return;
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ImportScreen()),
    );
    
    if (result == true && mounted) {
      setState(() {}); // Refresh UI after import
    }
  }

  void _clearAllData() {
    ConfirmDialog.show(
      context,
      title: 'Clear All Data',
      content: 'Are you sure you want to clear all vocabulary data? This action cannot be undone.',
      confirmLabel: 'Clear',
      confirmColor: Colors.red,
      onConfirm: () {
        appState.clearAll();
        setState(() {});
        SuccessSnackBar.show(context, 'All data cleared');
      },
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Test Status'),
        content: const Text(
          'Choose which test statuses to reset:'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              appState.resetQuizTestStatuses();
              setState(() {});
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Quiz test statuses reset!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Quiz Only'),
          ),
          TextButton(
            onPressed: () {
              appState.resetTypingTestStatuses();
              setState(() {});
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Typing test statuses reset!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Typing Only'),
          ),
          TextButton(
            onPressed: () {
              AppState().resetAllTestStatuses();
              setState(() {});
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All test statuses have been reset'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Both'),
          ),
        ],
      ),
    );
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

  void _startQuiz() async {
    // Play click sound if enabled (system sound for navigation)
    if (appState.audioEnabled) {
      await AudioService().playFeedback(AudioFeedbackType.systemClick);
    }
    
    if (!mounted) return;
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const QuizSetupScreen()),
    );
    
    if (result == true && mounted) {
      setState(() {}); // Refresh UI after quiz setup
    }
  }

  void _startTypingTest() async {
    // Play click sound if enabled (system sound for navigation)
    if (appState.audioEnabled) {
      await AudioService().playFeedback(AudioFeedbackType.systemClick);
    }
    
    if (!mounted) return;
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const TypingTestSetupScreen()),
    );
    
    if (result == true && mounted) {
      setState(() {}); // Refresh UI after typing test setup
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocabulary Quiz App'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (appState.hasVocabulary)
            IconButton(
              onPressed: _clearAllData,
              icon: const Icon(Icons.delete_forever),
              tooltip: 'Clear All Data',
            ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(isWideScreen ? 32.0 : 16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isWideScreen ? 800 : double.infinity,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome card
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(isWideScreen ? 24.0 : 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome to Vocabulary Quiz!',
                          style: TextStyle(
                            fontSize: isWideScreen ? 28 : 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Import your vocabulary list and take interactive quizzes to improve your English.',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(
                              appState.hasVocabulary ? Icons.check_circle : Icons.upload_file,
                              color: appState.hasVocabulary ? Colors.green : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    appState.hasVocabulary
                                        ? '${appState.vocabularyCount} vocabulary items loaded'
                                        : 'No vocabulary loaded',
                                    style: TextStyle(
                                      color: appState.hasVocabulary ? Colors.green : Colors.grey,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (appState.hasVocabulary) ...[
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      children: [
                                        _buildStatusChip('${appState.untestedCount} untested', Colors.grey),
                                        _buildStatusChip('${appState.quizTestedCount} quiz tested', Colors.blue),
                                        _buildStatusChip('${appState.typingTestedCount} typing tested', Colors.orange),
                                        _buildStatusChip('${appState.bothTestedCount} both tested', Colors.green),
                                        if (appState.totalTestedCount > 0)
                                          TextButton(
                                            onPressed: _showResetDialog,
                                            style: TextButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              minimumSize: Size.zero,
                                            ),
                                            child: const Text('Reset', style: TextStyle(fontSize: 12)),
                                          ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Action buttons
                if (isWideScreen) ...[
                  // Wide screen - row layout
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _navigateToImport,
                          icon: const Icon(Icons.upload_file),
                          label: Text(appState.hasVocabulary ? 'Import New Vocabulary' : 'Import Vocabulary'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: appState.hasVocabulary ? _startQuiz : null,
                          icon: const Icon(Icons.quiz),
                          label: const Text('Start Quiz'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(20),
                            backgroundColor: appState.hasVocabulary ? null : Colors.grey[300],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: appState.hasVocabulary ? _startTypingTest : null,
                          icon: const Icon(Icons.keyboard),
                          label: const Text('Typing Test'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(20),
                            backgroundColor: appState.hasVocabulary ? null : Colors.grey[300],
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // Narrow screen - column layout
                  ElevatedButton.icon(
                    onPressed: _navigateToImport,
                    icon: const Icon(Icons.upload_file),
                    label: Text(appState.hasVocabulary ? 'Import New Vocabulary' : 'Import Vocabulary'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),

                  const SizedBox(height: 16),

                  ElevatedButton.icon(
                    onPressed: appState.hasVocabulary ? _startQuiz : null,
                    icon: const Icon(Icons.quiz),
                    label: const Text('Start Quiz'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: appState.hasVocabulary ? null : Colors.grey[300],
                    ),
                  ),

                  const SizedBox(height: 16),

                  ElevatedButton.icon(
                    onPressed: appState.hasVocabulary ? _startTypingTest : null,
                    icon: const Icon(Icons.keyboard),
                    label: const Text('Typing Test'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: appState.hasVocabulary ? null : Colors.grey[300],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Vocabulary preview or empty state
                if (appState.hasVocabulary) ...[
                  const Text(
                    'Vocabulary Preview:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Card(
                      child: ListView.builder(
                        itemCount: appState.vocabularyList.length,
                        itemBuilder: (context, index) {
                          final item = appState.vocabularyList[index];
                          return ListTile(
                            dense: !isWideScreen,
                            leading: CircleAvatar(
                              radius: isWideScreen ? 16 : 12,
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(fontSize: isWideScreen ? 12 : 10),
                              ),
                            ),
                            title: Text(
                              item.word,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: isWideScreen ? 18 : 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.meaning,
                                  style: TextStyle(
                                    fontSize: isWideScreen ? 16 : 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (item.example != null)
                                  Text(
                                    item.example!,
                                    style: TextStyle(
                                      fontSize: isWideScreen ? 12 : 10,
                                      color: Colors.grey[600],
                                      fontStyle: FontStyle.italic,
                                    ),
                                    maxLines: isWideScreen ? 2 : 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: Center(
                      child: EmptyStateWidget(
                        icon: Icons.book_outlined,
                        title: 'No vocabulary loaded',
                        subtitle: 'Import your vocabulary list to get started with quizzes',
                        actionLabel: 'Import Vocabulary',
                        onAction: _navigateToImport,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}