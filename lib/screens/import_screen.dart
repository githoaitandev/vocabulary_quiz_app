import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../services/vocabulary_parser.dart';
import '../widgets/common_widgets.dart';

class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  final TextEditingController _textController = TextEditingController();
  VocabularyParseResult? _parseResult;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load sample text
    _textController.text = VocabularyParser.getSampleText();
    _parseText();
  }

  void _parseText() {
    setState(() {
      String text = _textController.text;
      _parseResult = VocabularyParser.parseText(text);
    });
  }

  Future<void> _importFromFile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      VocabularyParseResult? result = await VocabularyParser.importFromFile();
      
      if (result != null && !result.isEmpty) {
        setState(() {
          _textController.text = _generateTextFromItems(result.items);
          _parseResult = result;
        });
        
        if (result.hasErrors) {
          _showParseResultDialog(result);
        } else {
          SuccessSnackBar.show(context, 'Imported ${result.items.length} vocabulary items');
        }
      } else if (result != null && result.hasErrors) {
        ErrorSnackBar.show(context, result.errors.first);
      }
    } catch (e) {
      ErrorSnackBar.show(context, 'Error importing file: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showParseResultDialog(VocabularyParseResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Results'),
        content: SingleChildScrollView(
          child: Text(result.summary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _generateTextFromItems(List<VocabularyItem> items) {
    return items.map((item) {
      String line = '${item.word}\t${item.meaning}';
      if (item.example != null) {
        line += ' | ${item.example}';
      }
      return line;
    }).join('\n');
  }

  void _saveVocabulary() {
    if (_parseResult != null && _parseResult!.items.isNotEmpty) {
      AppState().importVocabulary(_parseResult!.items);
      
      SuccessSnackBar.show(context, 'Saved ${_parseResult!.items.length} vocabulary items');
      
      Navigator.of(context).pop(true); // Return true để indicate success
    } else {
      ErrorSnackBar.show(context, 'No valid vocabulary items to save');
    }
  }

  void _clearAll() {
    setState(() {
      _textController.clear();
      _parseResult = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Vocabulary'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _clearAll,
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear All',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Import buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _importFromFile,
                    icon: _isLoading 
                      ? const SizedBox(
                          width: 16, 
                          height: 16, 
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.file_upload),
                    label: const Text('Import from File'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (_parseResult?.items.isNotEmpty ?? false) ? _saveVocabulary : null,
                    icon: const Icon(Icons.save),
                    label: Text('Save ${_parseResult?.items.length ?? 0} items'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Format instruction với tooltip
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Format: word<TAB>meaning | example',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Tooltip(
                          message: 'Use TAB key to separate word and meaning. Use | to separate meaning and example.',
                          child: Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Example: attend a meeting<TAB>tham dự cuộc họp | All department heads...',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            _textController.text = VocabularyParser.getSampleText();
                            _parseText();
                          },
                          icon: const Icon(Icons.auto_fix_high, size: 16),
                          label: const Text('Load Sample'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final clipboardData = await Clipboard.getData('text/plain');
                            if (clipboardData?.text != null) {
                              _textController.text = clipboardData!.text!;
                              _parseText();
                              SuccessSnackBar.show(context, 'Pasted from clipboard');
                            }
                          },
                          icon: const Icon(Icons.content_paste, size: 16),
                          label: const Text('Paste'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Text input area
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Paste vocabulary here:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      onChanged: (_) => _parseText(),
                      maxLines: null,
                      expands: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Paste your vocabulary list here...',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Errors display
            if (_parseResult != null && _parseResult!.hasErrors) ...[
              Card(
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Errors (${_parseResult!.errors.length}):',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ...(_parseResult!.errors.take(5).map((error) => Text(
                        error,
                        style: const TextStyle(fontSize: 12, color: Colors.red),
                      ))),
                      if (_parseResult!.errors.length > 5)
                        Text(
                          '... and ${_parseResult!.errors.length - 5} more errors',
                          style: const TextStyle(fontSize: 12, color: Colors.red),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Preview area
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preview (${_parseResult?.items.length ?? 0} items):',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: (_parseResult?.items.isEmpty ?? true)
                          ? const Center(
                              child: Text(
                                'No valid vocabulary items found',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _parseResult!.items.length,
                              itemBuilder: (context, index) {
                                final item = _parseResult!.items[index];
                                return ListTile(
                                  dense: true,
                                  leading: CircleAvatar(
                                    radius: 12,
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  ),
                                  title: Text(
                                    item.word,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.meaning),
                                      if (item.example != null)
                                        Text(
                                          item.example!,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}