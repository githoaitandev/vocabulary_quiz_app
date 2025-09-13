import 'package:flutter_test/flutter_test.dart';
import 'package:vocabulary_quiz_app/models/models.dart';
import 'package:vocabulary_quiz_app/services/quiz_generator.dart';

void main() {
  group('QuizGenerator Tests', () {
    late List<VocabularyItem> vocabularyItems;

    setUp(() {
      vocabularyItems = [
        VocabularyItem(word: 'attend a meeting', meaning: 'tham dự cuộc họp', example: 'All department heads must attend a meeting this Friday.'),
        VocabularyItem(word: 'deadline', meaning: 'hạn chót', example: 'We must meet the deadline for the project.'),
        VocabularyItem(word: 'implement', meaning: 'thực hiện', example: 'We need to implement this feature next week.'),
        VocabularyItem(word: 'schedule', meaning: 'lịch trình', example: 'Please check your schedule for tomorrow.'),
        VocabularyItem(word: 'budget', meaning: 'ngân sách', example: 'The budget for this project is limited.'),
      ];
    });

    test('should generate correct number of questions', () {
      final questions = QuizGenerator.generateQuiz(
        vocabularyItems: vocabularyItems,
        questionCount: 3,
      );

      expect(questions.length, equals(3));
    });

    test('should generate questions with 4 options each', () {
      final questions = QuizGenerator.generateQuiz(
        vocabularyItems: vocabularyItems,
        questionCount: 2,
      );

      for (final question in questions) {
        expect(question.options.length, equals(4));
        expect(question.options.contains(question.correctAnswer), isTrue);
      }
    });

    test('should respect word to meaning ratio', () {
      final questions = QuizGenerator.generateQuiz(
        vocabularyItems: vocabularyItems,
        questionCount: 4,
        wordToMeaningRatio: 1.0, // All Word → Meaning
      );

      for (final question in questions) {
        expect(question.type, equals(QuestionType.wordToMeaning));
      }
    });

    test('should throw exception with insufficient vocabulary', () {
      final smallVocab = vocabularyItems.take(2).toList();
      
      expect(
        () => QuizGenerator.generateQuiz(
          vocabularyItems: smallVocab,
          questionCount: 5,
        ),
        throwsException,
      );
    });

    test('should validate quiz generation capability', () {
      expect(QuizGenerator.canGenerateQuiz(vocabularyItems, 3), isTrue);
      expect(QuizGenerator.canGenerateQuiz(vocabularyItems.take(2).toList(), 3), isFalse);
      expect(QuizGenerator.canGenerateQuiz(vocabularyItems, 0), isFalse);
    });

    test('should return correct max question count', () {
      expect(QuizGenerator.getMaxQuestionCount(vocabularyItems), equals(5));
    });
  });
}