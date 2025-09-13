import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../models/models.dart';

class VocabularyParseResult {
  final List<VocabularyItem> items;
  final List<String> errors;
  final int totalLines;
  final int successfulLines;

  VocabularyParseResult({
    required this.items,
    required this.errors,
    required this.totalLines,
    required this.successfulLines,
  });

  bool get hasErrors => errors.isNotEmpty;
  bool get isEmpty => items.isEmpty;
  
  String get summary {
    if (isEmpty) return 'No vocabulary items were imported.';
    
    final buffer = StringBuffer();
    buffer.write('Successfully imported $successfulLines/$totalLines items');
    
    if (hasErrors) {
      buffer.write('\n${errors.length} errors encountered:');
      for (final error in errors.take(5)) {
        buffer.write('\n• $error');
      }
      if (errors.length > 5) {
        buffer.write('\n• ... and ${errors.length - 5} more errors');
      }
    }
    
    return buffer.toString();
  }
}

class VocabularyParser {
  /// Parse text thành danh sách VocabularyItem với error handling chi tiết
  static VocabularyParseResult parseText(String text) {
    List<VocabularyItem> items = [];
    List<String> errors = [];
    List<String> lines = text.split('\n');
    int totalNonEmptyLines = 0;
    
    for (int i = 0; i < lines.length; i++) {
      String trimmedLine = lines[i].trim();
      if (trimmedLine.isEmpty) continue; // Skip empty lines
      
      totalNonEmptyLines++;
      
      try {
        VocabularyItem item = VocabularyItem.fromTabSeparated(trimmedLine);
        items.add(item);
      } catch (e) {
        errors.add('Line ${i + 1}: ${e.toString()}');
      }
    }
    
    return VocabularyParseResult(
      items: items,
      errors: errors,
      totalLines: totalNonEmptyLines,
      successfulLines: items.length,
    );
  }

  /// Import vocabulary từ file với error handling
  static Future<VocabularyParseResult?> importFromFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'csv'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        String content = await file.readAsString();
        return parseText(content);
      } else {
        return VocabularyParseResult(
          items: [],
          errors: ['No file selected'],
          totalLines: 0,
          successfulLines: 0,
        );
      }
    } catch (e) {
      return VocabularyParseResult(
        items: [],
        errors: ['Error importing file: ${e.toString()}'],
        totalLines: 0,
        successfulLines: 0,
      );
    }
  }

  /// Validate format của một dòng text
  static bool isValidFormat(String line) {
    try {
      VocabularyItem.fromTabSeparated(line.trim());
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Đếm số dòng valid trong text
  static int countValidLines(String text) {
    List<String> lines = text.split('\n');
    int count = 0;
    
    for (String line in lines) {
      if (line.trim().isNotEmpty && isValidFormat(line)) {
        count++;
      }
    }
    
    return count;
  }

  /// Lấy danh sách errors khi parse
  static List<String> getParseErrors(String text) {
    List<String> errors = [];
    List<String> lines = text.split('\n');
    
    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();
      if (line.isEmpty) continue;
      
      if (!isValidFormat(line)) {
        errors.add('Line ${i + 1}: Invalid format - "$line"');
      }
    }
    
    return errors;
  }

  /// Tạo sample text để user test
  static String getSampleText() {
    return '''attend a meeting\ttham dự cuộc họp | All department heads must attend a meeting this Friday.
deadline\thạn chót | We must meet the deadline for the project.
implement\tthực hiện | We need to implement this feature next week.
schedule\tlịch trình | Please check your schedule for tomorrow.
budget\tngân sách | The budget for this project is limited.''';
  }
}