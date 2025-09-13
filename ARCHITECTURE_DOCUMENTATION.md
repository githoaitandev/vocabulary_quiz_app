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

---

## 📱 Project Overview

**Vocabulary Quiz App** là một ứng dụng desktop Flutter được thiết kế để giúp người dùng học từ vựng tiếng Anh thông qua các bài kiểm tra tương tác. Ứng dụng sử dụng kiến trúc layered architecture với separation of concerns rõ ràng.

### 🎯 Core Features

- **Import từ vựng**: Hỗ trợ import từ file text với format tùy chỉnh
- **Quiz tương tác**: Tạo quiz với nhiều tùy chọn (Word→Meaning, Meaning→Word)
- **Phản hồi màu sắc**: Visual feedback ngay lập tức cho đáp án đúng/sai
- **Review system**: Xem lại các câu trả lời sai
- **Thống kê**: Theo dõi tiến độ và performance

### 💻 Technical Stack

- **Framework**: Flutter (Channel stable, 3.35.3)
- **Language**: Dart
- **Platform**: Windows Desktop
- **Architecture**: Layered Architecture + Singleton Pattern
- **State Management**: setState (Native Flutter)

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
│   └── quiz_session.dart       # Quiz session management
├── services/                    # Business logic layer
│   ├── services.dart           # Export file
│   ├── vocabulary_parser.dart  # File parsing & validation
│   └── quiz_generator.dart     # Quiz generation logic
├── screens/                     # UI screens (main app flows)
│   ├── home_screen.dart        # Main dashboard
│   ├── import_screen.dart      # Vocabulary import interface
│   ├── quiz_setup_screen.dart  # Quiz configuration
│   ├── quiz_screen.dart        # Quiz taking interface
│   ├── results_screen.dart     # Quiz results display
│   └── review_screen.dart      # Review incorrect answers
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

##### `ResultsScreen` - Performance Analysis

- **Purpose**: Display quiz results với detailed analytics
- **State**: Read-only access to completed `QuizSession`
- **Features**:
  - Overall performance metrics
  - Question type breakdown (Word→Meaning vs Meaning→Word)
  - Completion time tracking
  - Performance-based feedback messages
  - Navigation to review incorrect answers

##### `ReviewScreen` - Learning Enhancement

- **Purpose**: Review incorrect answers for learning
- **State**: Navigation state through incorrect questions
- **Features**:
  - Step-by-step review of wrong answers
  - Side-by-side comparison (user answer vs correct answer)
  - All options display with color coding
  - Progress tracking through incorrect items

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

### 3. 📊 Model Layer (Data & State)

#### `AppState` - Global State Management (Singleton)

- **Purpose**: Centralized state management cho entire app
- **Responsibilities**:

  - Vocabulary list management (CRUD operations)
  - Quiz session lifecycle management
  - Memory management (dispose patterns)
  - Data persistence coordination

- **Memory Management**: Explicit `dispose()` methods để prevent memory leaks

#### `VocabularyItem` - Core Data Model

- **Properties**:
  - `word`: English word/phrase
  - `meaning`: Vietnamese translation
  - `example`: Optional usage example
- **Features**:
  - Factory constructor cho tab-separated parsing
  - Built-in validation và error handling
  - Equality comparison support

#### `Question` - Quiz Question Model

- **Properties**:
  - `questionText`: The question being asked
  - `correctAnswer`: The right answer
  - `options`: List of all answer choices (4 options)
  - `type`: QuestionType enum (wordToMeaning/meaningToWord)
- **Methods**:
  - `isCorrect()`: Answer validation
  - `correctAnswerIndex`: Position in options array

#### `QuizSession` - Session Management

- **Purpose**: Track quiz progress và user interactions
- **State Tracking**:

  - Current question index
  - User answers array
  - Start/end timestamps
  - Navigation history

- **Analytics**: Real-time calculation of accuracy, completion rate, incorrect indices
- **Lifecycle**: Full session lifecycle từ creation đến disposal

### 4. 🔌 External Layer

#### Dependencies (`pubspec.yaml`)

```yaml
dependencies:
  flutter: sdk
  cupertino_icons: ^1.0.8 # iOS-style icons
  file_picker: ^6.0.0 # File selection dialog
  path_provider: ^2.0.0 # File system access

dev_dependencies:
  flutter_test: sdk
  flutter_lints: ^5.0.0 # Code quality linting
```

#### Platform Integration

- **Windows Desktop**: Native integration via Flutter Windows
- **File System**: Read text files thông qua `file_picker`
- **Clipboard**: Access system clipboard cho paste functionality

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

### 4. Review Flow

```
Results screen → User clicks review → Navigate to ReviewScreen
                                   ↓
Load incorrect questions → ReviewScreen state initialization
                                   ↓
Step through mistakes → Display correct vs user answers
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

## 🎯 Conclusion

Vocabulary Quiz App demonstrates a well-structured Flutter desktop application với clean architecture principles. The layered approach provides clear separation of concerns, making the codebase maintainable và extensible. The comprehensive error handling và user feedback systems ensure a robust user experience, while the visual feedback system enhances learning effectiveness.

The singleton pattern cho state management, combined với explicit memory management, provides a simple yet effective approach to data handling. The modular component design allows cho easy feature additions và modifications without affecting existing functionality.

---

**Document Version**: 1.0  
**Last Updated**: September 13, 2025  
**Flutter Version**: 3.35.3  
**Target Platform**: Windows Desktop
