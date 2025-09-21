# Vocabulary Quiz App - Architecture Documentation

## 📋 Table of Contents

1. [Project Overview](#project-overview)
2. [Architecture Overview](#architecture-overview)
3. [Project Structure](#project-structure)
4. [Layer-by-Layer Analysis](#layer-by-layer-analysis)
5. [Data Flow](#data-flow)
6. [Key Components](#key-components)
7. [Dependencies](#dependencies)
8. [Development Notes](#development-notes)
9. [Release Notes](#release-notes)

---

## 📱 Project Overview

**Vocabulary Quiz App** là một ứng dụng desktop Flutter được thiết kế để giúp người dùng học từ vựng tiếng Anh thông qua các bài kiểm tra tương tác. Ứng dụng sử dụng kiến trúc layered architecture với separation of concerns rõ ràng.

### 🎯 Core Features

- **Import từ vựng**: Hỗ trợ import từ file text với format tùy chỉnh
- **Quiz tương tác**: Tạo quiz với nhiều tùy chọn (Word→Meaning, Meaning→Word)
- **Typing Test System**: Interactive typing test với real-time feedback và scoring
- **Phản hồi màu sắc**: Visual feedback ngay lập tức cho đáp án đúng/sai
- **🎧 Audio feedback**: System sounds và custom audio files cho quiz interactions
- **Review system**: Xem lại các câu trả lời sai (cả quiz và typing test)
- **Thống kê**: Theo dõi tiến độ và performance cho cả quiz và typing test
- **Keyboard shortcuts**: Hỗ trợ điều khiển bằng phím tắt
- **Test Status Management**: Quản lý trạng thái test độc lập cho quiz và typing

### 💻 Technical Stack

- **Framework**: Flutter (Channel stable, 3.35.3)
- **Language**: Dart
- **Platform**: Windows Desktop
- **Architecture**: Layered Architecture + Singleton Pattern
- **State Management**: setState (Native Flutter)
- **Audio**: audioplayers package + SystemSound API
- **File Handling**: file_picker + path_provider packages

---

## 🏗️ Architecture Overview

Ứng dụng sử dụng **Layered Architecture** với 4 layers chính:

```
┌─────────────────────────────────────┐
│           PRESENTATION LAYER        │
│     (Screens, Widgets, UI)          │
├─────────────────────────────────────┤
│           BUSINESS LAYER            │
│         (Services, Logic)           │
├─────────────────────────────────────┤
│            MODEL LAYER              │
│      (Data Models, State)           │
├─────────────────────────────────────┤
│           EXTERNAL LAYER            │
│    (File System, Dependencies)      │
└─────────────────────────────────────┘
```

### 🔄 Design Patterns Used

1. **Singleton Pattern**: `AppState` - Quản lý global state
2. **Factory Pattern**: `VocabularyItem.fromTabSeparated()` - Parse data
3. **Strategy Pattern**: `QuizGenerator` - Different quiz generation strategies
4. **Observer Pattern**: `setState()` - UI updates based on state changes

---

## 📁 Project Structure

```
lib/
├── main.dart                    # Entry point + App configuration
├── models/                      # Data models và business entities
│   ├── models.dart             # Export file
│   ├── app_state.dart          # Global app state management
│   ├── vocabulary_item.dart    # Vocabulary data model
│   ├── question.dart           # Quiz question model
│   ├── quiz_session.dart       # Quiz session management
│   └── typing_test_session.dart # Typing test session management
├── services/                    # Business logic layer
│   ├── services.dart           # Export file
│   ├── vocabulary_parser.dart  # File parsing & validation
│   ├── quiz_generator.dart     # Quiz generation logic
│   └── audio_service.dart      # Audio feedback management
├── screens/                     # UI screens (main app flows)
│   ├── home_screen.dart        # Main dashboard
│   ├── import_screen.dart      # Vocabulary import interface
│   ├── quiz_setup_screen.dart  # Quiz configuration
│   ├── quiz_screen.dart        # Quiz taking interface
│   ├── typing_test_setup_screen.dart # Typing test configuration
│   ├── typing_test_screen.dart # Typing test interface
│   ├── results_screen.dart     # Unified results display (quiz/typing)
│   └── review_screen.dart      # Review incorrect answers (both types)
└── widgets/                     # Reusable UI components
    ├── common_widgets.dart     # Generic widgets
    └── quiz_widgets.dart       # Quiz-specific widgets
```

### 📋 File Dependencies

```
main.dart
├── screens/home_screen.dart
├── screens/results_screen.dart
└── screens/review_screen.dart

screens/ → models/ + services/ + widgets/
models/ → No external dependencies (pure data)
services/ → models/ + external packages
widgets/ → models/ (for data display)
```

---

## 🎯 Layer-by-Layer Analysis

### 1. 📱 Presentation Layer (UI)

#### **Screens (Main App Flows)**

##### `HomeScreen` - Main Dashboard

- **Purpose**: Entry point, navigation hub, vocabulary overview
- **State**: Uses `AppState` singleton for vocabulary management
- **Features**:
  - Responsive design (wide/narrow screen support)
  - Vocabulary preview with pagination
  - Clear all data functionality
  - Navigation to import/quiz screens

##### `ImportScreen` - Vocabulary Import

- **Purpose**: Import và validate vocabulary từ multiple sources
- **State**: Local state for parsing results và UI feedback
- **Features**:
  - File picker integration (`file_picker` package)
  - Real-time text parsing và validation
  - Error display với detailed feedback
  - Sample data loading
  - Clipboard integration

##### `QuizSetupScreen` - Quiz Configuration

- **Purpose**: Configure quiz parameters trước khi start
- **State**: Local state for quiz settings
- **Features**:
  - Question count slider (1 to max vocabulary)
  - Question type ratio (Word↔Meaning balance)
  - Preset configurations (Small/Medium/Large/Focused)
  - Real-time validation

##### `QuizScreen` - Interactive Quiz

- **Purpose**: Main quiz interface với visual feedback
- **State**: Complex local state + `QuizSession` management
- **Features**:
  - **Color-coded feedback system**:
    - ✅ Green: Correct answer
    - ❌ Red: Incorrect answer + show correct answer
  - Keyboard shortcuts (1-4 for answers, ←→ for navigation)
  - Timer functionality (toggleable)
  - Progress tracking
  - Answer locking after selection

##### `TypingTestSetupScreen` - Typing Test Configuration

- **Purpose**: Configure typing test parameters trước khi start
- **State**: Local state for typing test settings
- **Features**:
  - Word count selection (1 to max vocabulary)
  - Timer enable/disable toggle
  - Hints enable/disable toggle
  - Preset configurations cho different skill levels
  - Real-time validation và feedback

##### `TypingTestScreen` - Interactive Typing Test

- **Purpose**: Main typing test interface với real-time feedback
- **State**: Complex local state + `TypingTestSession` management
- **Features**:
  - **Real-time typing feedback**:
    - ✅ Green: Correct characters
    - ❌ Red: Incorrect characters
    - 💡 Hints: Show correct character positions
  - **Scoring system**:
    - 100 points: Perfect (no hints, no errors)
    - 80 points: Good (used hints but no errors)
    - 60 points: Fair (some typing errors but completed)
    - 0 points: Skipped or incomplete
  - Keyboard shortcuts (Enter to submit, Ctrl+Enter to skip)
  - Progress tracking và timer
  - Audio feedback cho completion

##### `ResultsScreen` - Unified Performance Analysis

- **Purpose**: Display results cho cả quiz và typing test với detailed analytics
- **State**: Read-only access to completed sessions (QuizSession hoặc TypingTestSession)
- **Features**:
  - **Quiz Results**:
    - Overall performance metrics
    - Question type breakdown
    - Accuracy percentages
  - **Typing Test Results**:
    - Average score calculation
    - Individual word performance
    - Typing speed và accuracy metrics
    - Detailed breakdown với scoring explanations
  - Unified navigation to review incorrect answers
  - Performance-based feedback messages

##### `ReviewScreen` - Enhanced Learning Tool

- **Purpose**: Review incorrect answers cho cả quiz và typing test
- **State**: Navigation state through incorrect items
- **Features**:
  - **Quiz Review**: Side-by-side comparison của user vs correct answers
  - **Typing Test Review**:
    - Display incorrect words với correct spelling
    - Show context (meaning và example)
    - Display performance details (score, time, errors)
    - Option to retry typing specific words
  - Unified navigation experience cho both review types
  - Progress tracking qua review items

#### **Widgets (Reusable Components)**

##### Common Widgets (`common_widgets.dart`)

- `LoadingWidget`: Consistent loading states
- `ErrorWidget`: Error display với retry functionality
- `EmptyStateWidget`: Empty state với call-to-action
- `ConfirmDialog`: Reusable confirmation dialogs
- `SuccessSnackBar`/`ErrorSnackBar`: Consistent feedback

##### Quiz Widgets (`quiz_widgets.dart`)

- `QuestionWidget`: Quiz question display (currently unused, integrated into QuizScreen)
- `ProgressIndicatorWidget`: Quiz progress và timer display

### 2. 🔧 Business Layer (Services)

#### `VocabularyParser` - Data Processing Service

- **Purpose**: Handle file import, text parsing, và validation
- **Key Methods**:

  - `parseText()`: Parse text với comprehensive error handling
  - `importFromFile()`: File picker integration với error management
  - `isValidFormat()`: Line-by-line validation
  - `getSampleText()`: Provide example data format

- **Error Handling**: Detailed error reporting với line numbers và descriptions
- **Supported Format**: `word<TAB>meaning | example`

#### `QuizGenerator` - Quiz Logic Service

- **Purpose**: Generate quiz questions từ vocabulary items
- **Algorithms**:

  - Random selection of vocabulary items
  - Intelligent wrong answer generation (avoid duplicates)
  - Question type balancing (Word→Meaning vs Meaning→Word)
  - Option shuffling for randomization

- **Configuration**: `QuizConfig` class với preset options
- **Validation**: Ensure minimum vocabulary requirement (4+ items)

#### `AudioService` - Audio Feedback Management (Singleton)

- **Purpose**: Handle audio feedback cho quiz interactions
- **Key Features**:

  - **System sounds**: Windows SystemSoundType integration
  - **Custom sounds**: MP3/WAV/M4A file support từ assets
  - **Fallback mechanism**: Automatic fallback to system sounds if custom files fail
  - **Global controls**: Enable/disable audio feedback

- **Sound Types**:

  - `correct`: Success sound cho correct answers
  - `incorrect`: Error/buzzer sound cho wrong answers
  - `completion`: Celebration sound khi hoàn thành quiz
  - `click`: Navigation click sounds

- **Configuration**:

  - `audioEnabled`: Global audio toggle
  - `useCustomSounds`: Switch between system và custom sounds
  - Volume control và stop functionality

- **Error Handling**: Silent failures với fallback để prevent crashes

### 3. 📊 Model Layer (Data & State)

#### `AppState` - Global State Management (Singleton)

- **Purpose**: Centralized state management cho entire app
- **Responsibilities**:

  - Vocabulary list management (CRUD operations)
  - Quiz session lifecycle management
  - **Typing test session lifecycle management**
  - **Test status tracking**: Independent quiz và typing test statuses
  - Memory management (dispose patterns)
  - Data persistence coordination
  - Audio preferences storage (audio enabled/disabled state)

- **New Properties**:

  - `isTypingTested`: Track which vocabulary items have been typing tested
  - `typingTestedCount`: Count of typing tested items
  - `bothTestedCount`: Count of items tested in both quiz và typing
  - `resetTypingTestStatuses()`: Reset typing test status independently
  - `resetQuizTestStatuses()`: Reset quiz test status independently
  - `resetAllTestStatuses()`: Reset both types of test statuses

- **Memory Management**: Explicit `dispose()` methods để prevent memory leaks

#### `VocabularyItem` - Enhanced Core Data Model

- **Properties**:
  - `word`: English word/phrase
  - `meaning`: Vietnamese translation
  - `example`: Optional usage example
  - **`isQuizTested`**: Track if item has been tested in quiz
  - **`isTypingTested`**: Track if item has been tested in typing test
- **Features**:
  - Factory constructor cho tab-separated parsing
  - Built-in validation và error handling
  - Equality comparison support
  - **Test status management**: Independent tracking của quiz và typing test completion

#### `Question` - Quiz Question Model

- **Properties**:
  - `questionText`: The question being asked
  - `correctAnswer`: The right answer
  - `options`: List of all answer choices (4 options)
  - `type`: QuestionType enum (wordToMeaning/meaningToWord)
- **Methods**:
  - `isCorrect()`: Answer validation
  - `correctAnswerIndex`: Position in options array

#### `TypingTestSession` - Typing Test Management (New)

- **Purpose**: Track typing test progress và user performance
- **State Tracking**:

  - Current word index và progress
  - User input với real-time validation
  - Scoring system với detailed feedback
  - Start/end timestamps cho each word
  - Hint usage tracking
  - Error count và accuracy metrics

- **Scoring Algorithm**:

  - Perfect (100): No hints used, no typing errors
  - Good (80): Hints used but no errors
  - Fair (60): Some typing errors but completed correctly
  - Poor (0): Skipped hoặc incomplete

- **Analytics**: Real-time calculation của average score, completion rate, incorrect words
- **Lifecycle**: Full session lifecycle từ creation đến disposal với memory management

### 4. 🔌 External Layer

#### Dependencies (`pubspec.yaml`)

```yaml
dependencies:
  flutter: sdk
  cupertino_icons: ^1.0.8 # iOS-style icons
  file_picker: ^6.0.0 # File selection dialog
  path_provider: ^2.0.0 # File system access
  audioplayers: ^5.0.0 # Custom audio file playback

dev_dependencies:
  flutter_test: sdk
  flutter_lints: ^5.0.0 # Code quality linting
```

#### Platform Integration

- **Windows Desktop**: Native integration via Flutter Windows
- **File System**: Read text files thông qua `file_picker`
- **Clipboard**: Access system clipboard cho paste functionality
- **Audio System**: System sounds và custom audio file playback

---

## 🔄 Data Flow

### 1. Vocabulary Import Flow

```
User selects file → VocabularyParser.importFromFile()
                  ↓
File content read → VocabularyParser.parseText()
                  ↓
Parse each line → VocabularyItem.fromTabSeparated()
                  ↓
Validation & error collection → VocabularyParseResult
                  ↓
User confirms → AppState.importVocabulary()
                  ↓
State updated → UI refreshes via setState()
```

### 2. Quiz Generation Flow

```
User configures quiz → QuizSetupScreen state
                     ↓
User starts quiz → QuizGenerator.generateQuiz()
                     ↓
Questions created → AppState.startNewQuizSession()
                     ↓
Navigate to QuizScreen → Quiz session begins
```

### 3. Quiz Taking Flow

```
Display question → User selects answer → Visual feedback shown
                                      ↓
Answer recorded → QuizSession.answerCurrentQuestion()
                                      ↓
Navigation → QuizSession.nextQuestion() → Update UI
                                      ↓
Quiz completion → QuizSession.finishQuiz() → Navigate to results
```

### 4. Typing Test Flow (New)

```
User configures typing test → TypingTestSetupScreen state
                           ↓
User starts typing test → Navigate to TypingTestScreen
                           ↓
Real-time typing feedback → Character-by-character validation
                           ↓
Word completion → Score calculation (100/80/60/0)
                           ↓
Session tracking → TypingTestSession.completeWord()
                           ↓
Test completion → TypingTestSession.finishTest() → Navigate to results
```

### 5. Unified Review Flow (Enhanced)

```
Results screen → User clicks review → Navigate to ReviewScreen
                                   ↓
Determine review type → Quiz mistakes hoặc Typing mistakes
                                   ↓
Load incorrect items → ReviewScreen state initialization
                                   ↓
Unified navigation → Display appropriate review content
                                   ↓
Quiz: Correct vs user answers | Typing: Word details và retry option
```

---

## 🔑 Key Components

### State Management Strategy

- **Centralized State**: `AppState` singleton cho shared data
- **Local State**: `setState()` cho UI-specific state
- **Memory Management**: Explicit disposal patterns
- **Data Flow**: Unidirectional data flow với clear separation

### Error Handling Strategy

- **Parsing Errors**: Line-by-line error collection với detailed messages
- **User Feedback**: Consistent error display qua SnackBars và dialogs
- **Graceful Degradation**: App continues functioning khi có partial errors
- **Validation**: Multi-layer validation (input → parsing → business logic)

### Performance Considerations

- **Lazy Loading**: Quiz questions generated on-demand
- **Memory Efficiency**: Explicit disposal của large objects
- **UI Optimization**: Responsive design patterns cho different screen sizes
- **Background Processing**: File operations với loading indicators

### Accessibility Features

- **Keyboard Navigation**: Full keyboard support trong quiz interface
- **Screen Reader Support**: Semantic labels và tooltips
- **Visual Feedback**: Color-coded feedback với icons
- **Responsive Design**: Adaptive layout cho different screen sizes

---

## 🔧 Dependencies Analysis

### Core Dependencies

- **Flutter SDK**: Framework foundation
- **Material Design**: UI component library với consistent theming

### External Packages

- **file_picker (^6.0.0)**:

  - Purpose: File selection dialogs
  - Usage: Import vocabulary từ .txt/.csv files
  - Platform Support: Windows desktop

- **path_provider (^2.0.0)**:

  - Purpose: Access system directories
  - Usage: Future file management capabilities
  - Platform Support: Cross-platform

- **cupertino_icons (^1.0.8)**:
  - Purpose: iOS-style icons
  - Usage: Consistent iconography across app

### Development Dependencies

- **flutter_lints (^5.0.0)**: Code quality và style enforcement
- **flutter_test**: Unit testing framework

---

## 📝 Development Notes

### Architecture Decisions

1. **Singleton Pattern cho AppState**: Chosen để avoid complex state management libraries
2. **Layered Architecture**: Clear separation of concerns cho maintainability
3. **Factory Constructors**: Type-safe data parsing với error handling
4. **Explicit Memory Management**: Prevent memory leaks trong long-running sessions

### Code Quality Features

- **Comprehensive Error Handling**: Every operation has error scenarios covered
- **Type Safety**: Strong typing throughout application
- **Documentation**: Extensive inline comments trong Vietnamese cho clarity
- **Testability**: Services designed với clear interfaces cho testing

### Future Enhancement Opportunities

1. **Data Persistence**: Add SQLite cho vocabulary storage
2. **Advanced Analytics**: Detailed learning progress tracking
3. **Spaced Repetition**: Intelligent review scheduling
4. **Multiple Languages**: Support cho other language pairs
5. **Cloud Sync**: User account và cross-device synchronization

### Performance Monitoring

- **Memory Usage**: Monitor AppState size với large vocabulary lists
- **UI Responsiveness**: Ensure smooth animations và transitions
- **File Operations**: Async file handling để prevent UI blocking
- **Quiz Generation**: Optimize algorithm cho large vocabulary sets

---

## 📋 Release Notes

### 🌟 New Features (Version 1.2.0)

1. **Quiz Results Screen Refactor**

   - Separated quiz and typing test results into distinct screens.
   - Added detailed performance analytics for both quiz and typing tests.

2. **Enhanced Typing Test**

   - Added real-time feedback for typing accuracy.
   - Improved scoring system with detailed breakdowns.

3. **Custom Audio Feedback**

   - Support for custom audio files for correct, incorrect, and completion sounds.
   - Added fallback to system sounds if custom files are unavailable.

4. **Improved Import Functionality**

   - Enhanced file parsing with better error handling.
   - Support for flexible formats including examples.

5. **Responsive Design**

   - Optimized layout for wide and narrow screens.
   - Adaptive font sizes and spacing for better usability.

6. **Keyboard Shortcuts**
   - Added shortcuts for faster navigation in quizzes and typing tests.

---

## 🎯 Conclusion

Vocabulary Quiz App demonstrates a well-structured Flutter desktop application với clean architecture principles. The layered approach provides clear separation of concerns, making the codebase maintainable và extensible. The comprehensive error handling và user feedback systems ensure a robust user experience, while the visual feedback system enhances learning effectiveness.

The singleton pattern cho state management, combined với explicit memory management, provides a simple yet effective approach to data handling. The modular component design allows cho easy feature additions và modifications without affecting existing functionality.

---

**Document Version**: 1.1  
**Last Updated**: September 21, 2025  
**Flutter Version**: 3.35.3  
**Target Platform**: Windows Desktop

### 📋 Recent Updates (v1.1)

- ⌨️ **Typing Test System**: Complete implementation với real-time feedback
- 🔍 **Enhanced Review System**: Support cho both quiz và typing test review
- 📊 **Unified Results**: Single results screen cho multiple test types
- 🎯 **Test Status Management**: Independent tracking của quiz và typing test completion
- 📱 **Improved Responsive Design**: Enhanced layout stability và overflow fixes
- 🔧 **Better Memory Management**: Optimized session handling và disposal patterns
