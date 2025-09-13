# Vocabulary Quiz App – Requirements & Planning

## 1. Overview

Ứng dụng desktop (Windows) bằng **Flutter** cho phép người dùng:

1. Import danh sách từ vựng từ file hoặc copy-paste.
2. Sinh bài quiz trắc nghiệm từ dữ liệu import.
3. Làm quiz và xem kết quả ngay trong session.
4. Không có database, không lưu trữ dài hạn.

---

## 2. Input Format

Người dùng cung cấp dữ liệu dạng:

```
<word><tab><meaning & example>
```

Ví dụ:

```
attend a meeting   tham dự cuộc họp | All department heads must attend a meeting this Friday. (Tất cả trưởng phòng phải tham dự cuộc họp thứ Sáu này.)
deadline           hạn chót | We must meet the deadline for the project. (Chúng ta phải hoàn thành đúng hạn dự án.)
```

- Import bằng:
  - File `.txt` hoặc `.csv`
  - Hoặc copy-paste trực tiếp vào TextArea trong app

---

## 3. Core Features

### 3.1 Import Vocabulary

- Người dùng chọn file hoặc dán dữ liệu.
- App parse thành danh sách (word, meaning, example).
- Dữ liệu lưu tạm trong bộ nhớ (RAM) → chỉ tồn tại trong session.

### 3.2 Quiz Generator

- App sinh quiz từ danh sách từ vựng đã import.
- Loại câu hỏi:
  - Question = Word → Answer = Meaning
  - Question = Meaning → Answer = Word
- Mỗi câu hỏi có:
  - 1 đáp án đúng.
  - 3–4 đáp án nhiễu (random từ danh sách khác).
- Thứ tự câu hỏi + đáp án được shuffle.

### 3.3 Quiz Session

- Người dùng chọn số câu hỏi (ví dụ: 10, 20, 30).
- Làm quiz bằng giao diện chọn đáp án (radio button hoặc button group).
- Sau khi hoàn tất:
  - Hiển thị số câu đúng/sai.
  - Hiển thị danh sách từ sai để ôn lại (trong session).

---

## 4. Out of Scope

- Không có database.
- Không lưu lịch sử quiz.
- Không có thống kê hoặc export.

---

## 5. Technology Stack

- **Framework:** Flutter (desktop for Windows).
- **IDE:** VSCode.
- **Language:** Dart.
- **State Management:** State tạm thời trong bộ nhớ (StatefulWidget, setState, hoặc Riverpod nhẹ).

---

## 6. Development Planning

### Phase 1: Project Setup & Foundation

**Step 1: Flutter Desktop Project Setup**

- Khởi tạo Flutter project với desktop support
- Cấu hình `windows/` build target
- Setup basic app structure và routing
- Test chạy app trên Windows desktop

**Step 2: Data Models & Architecture**

- Tạo model `VocabularyItem` (word, meaning, example)
- Tạo model `Question` (question, correctAnswer, options, type)
- Tạo model `QuizSession` (questions, currentIndex, score, answers)
- Setup state management cơ bản (StatefulWidget hoặc Riverpod)

### Phase 2: Core Features Implementation

**Step 3: Import Vocabulary Feature**

- UI cho import từ file (.txt, .csv) sử dụng `file_picker`
- UI cho paste text vào TextArea
- Parser function để parse format `<word><tab><meaning & example>`
- Validation và error handling cho dữ liệu input
- Hiển thị preview danh sách từ vựng đã import

**Step 4: Quiz Generator Engine**

- Logic tạo câu hỏi từ vocabulary list
- Implement 2 loại câu hỏi:
  - Word → Meaning
  - Meaning → Word
- Algorithm tạo đáp án nhiễu (random từ các từ khác)
- Shuffle thứ tự câu hỏi và đáp án
- Cấu hình số lượng câu hỏi (10, 20, 30)

**Step 5: Quiz Session Interface**

- UI hiển thị câu hỏi và 4 đáp án (radio buttons)
- Navigation: Previous/Next/Submit
- Progress indicator (câu hỏi x/y)
- Timer cho mỗi câu hoặc toàn bộ quiz (optional)
- Confirm dialog trước khi submit

### Phase 3: Results & User Experience

**Step 6: Quiz Results & Review**

- Trang kết quả hiển thị:
  - Điểm số (x/y correct)
  - Phần trăm chính xác
  - Thời gian hoàn thành
- Danh sách từ vựng trả lời sai để review
- Hiển thị đáp án đúng vs đáp án đã chọn
- Button "Làm lại quiz" hoặc "Import từ vựng mới"

**Step 7: UI/UX Enhancement & Testing**

- Responsive design cho different screen sizes
- Theme và styling consistent
- Loading states và progress indicators
- Error handling và user feedback
- Testing trên Windows desktop
- Performance optimization cho large vocabulary lists

### Phase 4: Final Polish

**Step 8: Quality Assurance**

- Unit tests cho core logic (parser, quiz generator)
- Integration tests cho user flows
- Manual testing với real data
- Bug fixes và edge cases handling
- Documentation và comments

---

## 7. Technical Implementation Details

### Key Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  file_picker: ^6.0.0 # File selection
  path_provider: ^2.0.0 # File operations
  # Riverpod (optional for state management)
  flutter_riverpod: ^2.4.0
```

### Project Structure

```
lib/
├── main.dart
├── models/
│   ├── vocabulary_item.dart
│   ├── question.dart
│   └── quiz_session.dart
├── services/
│   ├── vocabulary_parser.dart
│   └── quiz_generator.dart
├── screens/
│   ├── home_screen.dart
│   ├── import_screen.dart
│   ├── quiz_screen.dart
│   └── results_screen.dart
└── widgets/
    ├── vocabulary_list_widget.dart
    ├── question_widget.dart
    └── progress_indicator_widget.dart
```
