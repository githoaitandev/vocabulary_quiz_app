# 📚 Vocabulary Quiz App

Ứng dụng học từ vựng tiếng Anh thông qua các bài kiểm tra tương tác với phản hồi màu sắc và âm thanh ngay lập tức.

![Flutter](https://img.shields.io/badge/Flutter-3.35.3-blue.svg)
![Platform](https://img.shields.io/badge/Platform-Windows%20Desktop-green.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

## 🌟 Tính năng nổi bật

- ✅ **Import từ vựng** từ file text với format linh hoạt
- 🎯 **Quiz tương tác** với 2 loại câu hỏi (Word→Meaning, Meaning→Word)
- ⌨️ **Typing Test** - Test khả năng đánh máy với gợi ý và scoring system
- 🎨 **Phản hồi màu sắc ngay lập tức**: Xanh cho đúng, đỏ cho sai
- 🔊 **Âm thanh phản hồi**: Âm thanh khác nhau cho đúng/sai/hoàn thành
- 📊 **Thống kê chi tiết** theo từng loại câu hỏi và typing test
- 🔍 **Review system** để ôn tập các câu trả lời sai (cả quiz và typing test)
- ⌨️ **Keyboard shortcuts** để sử dụng nhanh
- ⏱️ **Timer tùy chọn** để theo dõi thời gian
- 📱 **Responsive design** tối ưu cho nhiều kích thước màn hình

## 🚀 Hướng dẫn sử dụng

### 1. 📥 Import từ vựng

#### Cách 1: Import từ file

1. Ở màn hình chính, nhấn **"Import Vocabulary"**
2. Chọn **"Import from File"**
3. Chọn file `.txt` hoặc `.csv` từ máy tính
4. Kiểm tra preview và nhấn **"Save"**

#### Cách 2: Paste trực tiếp

1. Mở **Import Screen**
2. Paste nội dung vào text area
3. Ứng dụng sẽ tự động parse và hiển thị preview
4. Nhấn **"Save"** để lưu

#### 📝 Format yêu cầu

```
word<TAB>meaning | example
```

**Ví dụ:**

```
attend a meeting	tham dự cuộc họp | All department heads must attend the meeting.
deadline	hạn chót | We must meet the deadline for the project.
implement	thực hiện | We need to implement this feature next week.
```

**Lưu ý:**

- Sử dụng phím `TAB` để tách word và meaning
- Sử dụng `|` (dấu gạch dọc với khoảng trắng) để tách meaning và example
- Example là tùy chọn, có thể bỏ trống

### 2. 🎯 Tạo và làm Quiz

#### Bước 1: Cấu hình Quiz

1. Từ màn hình chính, nhấn **"Start Quiz"**
2. Chọn **số lượng câu hỏi** (1 đến tổng số từ vựng)
3. Điều chỉnh **tỷ lệ loại câu hỏi**:
   - **Word→Meaning**: Hiện từ tiếng Anh, chọn nghĩa tiếng Việt
   - **Meaning→Word**: Hiện nghĩa tiếng Việt, chọn từ tiếng Anh

#### Bước 2: Preset nhanh

- **Small (10)**: 10 câu hỏi cân bằng
- **Medium (20)**: 20 câu hỏi cân bằng
- **Large (30)**: 30 câu hỏi cân bằng
- **Word Focus**: Tập trung Word→Meaning (80%)
- **Meaning Focus**: Tập trung Meaning→Word (80%)

#### Bước 3: Làm bài

1. Đọc câu hỏi và chọn đáp án
2. **Phản hồi ngay lập tức**:
   - 🟢 **Màu xanh + âm thanh thành công**: Đáp án đúng
   - 🔴 **Màu đỏ + âm thanh lỗi**: Đáp án sai (hiển thị đáp án đúng)
   - 🔊 **Âm thanh hoàn thành**: Khi kết thúc quiz
3. **Tùy chọn âm thanh**: Nhấn nút 🔊/🔇 ở góc trên phải để bật/tắt âm thanh
4. **Cài đặt âm thanh**: Nhấn nút ⚙️ để chọn giữa system sounds và custom sounds
5. Nhấn **"Next"** để tiếp tục
6. Nhấn **"Finish Quiz"** ở câu cuối

### 3. ⌨️ Typing Test

#### Bước 1: Cấu hình Typing Test

1. Từ màn hình chính, nhấn **"Typing Test"**
2. Chọn **số lượng từ** để test (1 đến tổng số từ vựng)
3. Điều chỉnh **cài đặt**:
   - **Timer**: Bật/tắt đếm thời gian
   - **Hints**: Bật/tắt gợi ý khi typing

#### Bước 2: Làm Typing Test

1. Đọc nghĩa tiếng Việt và ví dụ (nếu có)
2. **Gõ từ tiếng Anh** vào text field
3. **Hệ thống gợi ý**:
   - ✅ **Màu xanh**: Ký tự đúng
   - ❌ **Màu đỏ**: Ký tự sai
   - 💡 **Gợi ý**: Hiển thị vị trí ký tự đúng
4. **Scoring system**:
   - 100 điểm: Hoàn hảo (không cần hint, không sai)
   - 80 điểm: Tốt (có dùng hint nhưng không sai)
   - 60 điểm: Khá (có lỗi typing nhưng cuối cùng đúng)
   - 0 điểm: Skip hoặc không hoàn thành
5. Nhấn **"Next Word"** để tiếp tục
6. Nhấn **"Skip"** nếu không biết

#### Bước 3: Xem kết quả Typing Test

- **Điểm trung bình**: Tổng điểm / số từ test
- **Thời gian hoàn thành**: Tổng thời gian typing
- **Chi tiết từng từ**: Từ, điểm số, thời gian gõ
- **Phân loại kết quả**:
  - Excellent (≥90): Xuất sắc
  - Good (≥70): Tốt
  - Fair (≥50): Khá
  - Poor (<50): Cần cải thiện

### 4. ⌨️ Phím tắt

#### Trong Quiz

- **1, 2, 3, 4**: Chọn đáp án tương ứng
- **←** (Left Arrow): Câu hỏi trước
- **→** (Right Arrow): Câu hỏi tiếp theo
- **Enter**: Tiếp tục/Hoàn thành quiz

#### Trong Typing Test

- **Enter**: Submit từ hiện tại
- **Ctrl+Enter**: Skip từ hiện tại
- **Tab**: Show/Hide hints
- **F1**: Hiển thị hướng dẫn phím tắt

#### Khác

- **Ctrl+V**: Paste trong Import Screen
- **F1**: Hiển thị hướng dẫn phím tắt

### 5. 📊 Xem kết quả

#### Quiz Results

Sau khi hoàn thành quiz, bạn sẽ thấy:

##### Thông tin tổng quan

- **Điểm số**: X/Y câu đúng
- **Phần trăm chính xác**: Tỷ lệ đúng
- **Thời gian hoàn thành**: Tổng thời gian làm bài
- **Đánh giá**: Excellent (≥80%), Good (≥60%), Keep studying (<60%)

##### Thống kê chi tiết

- **Tổng số câu hỏi**
- **Số câu đúng/sai**
- **Phân tích theo loại câu hỏi**:
  - Word→Meaning: X/Y (Z%)
  - Meaning→Word: X/Y (Z%)

#### Typing Test Results

- **Điểm trung bình**: Average score của tất cả các từ
- **Thời gian hoàn thành**: Tổng thời gian typing
- **Chi tiết performance**: Breakdown theo từng từ với điểm số và thời gian
- **Phân loại**: Excellent/Good/Fair/Poor dựa trên điểm trung bình

### 6. 🔍 Review câu sai

#### Review Quiz Mistakes

1. Từ màn hình kết quả quiz, nhấn **"Review X Incorrect Answers"**
2. Xem từng câu trả lời sai:
   - ❌ **Đáp án của bạn**: Màu đỏ
   - ✅ **Đáp án đúng**: Màu xanh
   - 📝 **Tất cả lựa chọn**: Để so sánh
3. Sử dụng **"Previous"/"Next"** để điều hướng
4. Nhấn **"Back to Results"** khi hoàn thành

#### Review Typing Test Mistakes

1. Từ màn hình kết quả typing test, nhấn **"Review Incorrect Typing"**
2. Xem các từ gõ sai hoặc cần cải thiện:
   - 📝 **Từ gốc**: Từ tiếng Anh đúng
   - 💭 **Nghĩa**: Meaning để hiểu context
   - 📖 **Ví dụ**: Example sentence (nếu có)
   - 📊 **Chi tiết**: Điểm số và lý do (dùng hint, typing errors, etc.)
3. Có thể retry typing ngay tại review screen
4. Navigation qua các từ cần cải thiện

### 6. 🔧 Tính năng khác

#### Quản lý dữ liệu

- **Clear All Data**: Xóa tất cả từ vựng (có xác nhận)
- **Import New**: Thêm từ vựng mới (ghi đè dữ liệu cũ)
- **Reset Test Status**: Reset trạng thái test của từ vựng
  - Reset Quiz Status: Đặt lại quiz test status
  - Reset Typing Status: Đặt lại typing test status
  - Reset Both: Đặt lại cả hai loại test status

#### Timer

- **Show/Hide Timer**: Toggle hiển thị đồng hồ trong quiz và typing test
- **Time tracking**: Tự động tính thời gian hoàn thành cho cả quiz và typing test

#### Responsive Design

- **Wide Screen**: Layout 2-3 cột cho màn hình lớn (>600px)
- **Narrow Screen**: Layout 1 cột cho màn hình nhỏ
- **Adaptive UI**: Tự động điều chỉnh font size, spacing, và layout

#### 🎧 Custom Audio

- **System Sounds**: Sử dụng âm thanh hệ thống Windows (mặc định)
- **Custom Sounds**: Sử dụng file âm thanh tùy chỉnh
- **Cài đặt**: Trong quiz, nhấn nút ⚙️ → "Use Custom Sounds"
- **File hỗ trợ**: MP3, WAV, M4A
- **Vị trí file**: `assets/sounds/correct.mp3`, `incorrect.mp3`, `completion.mp3`
- **Fallback**: Tự động fallback về system sounds nếu custom files không hoạt động

## 🎯 Tips sử dụng hiệu quả

### 📚 Chuẩn bị từ vựng

1. **Format đúng**: Đảm bảo sử dụng TAB và format chính xác
2. **Example sentences**: Thêm ví dụ để học hiệu quả hơn
3. **Batch import**: Import nhiều từ cùng lúc để tiết kiệm thời gian

### 🎓 Học tập hiệu quả

1. **Bắt đầu với Small quiz**: Làm quen với interface
2. **Cân bằng loại câu hỏi**: 50/50 để luyện cả 2 chiều
3. **Kết hợp Quiz và Typing Test**: Quiz để nhận biết, Typing để ghi nhớ
4. **Review ngay**: Xem lại câu sai ngay sau khi làm xong
5. **Lặp lại**: Làm nhiều lần để ghi nhớ tốt hơn
6. **Sử dụng Reset Status**: Reset test status để luyện lại từ đầu
7. **Typing Test Tips**:
   - Bật hints lúc đầu để làm quen
   - Tắt hints để challenge bản thân
   - Chú ý spelling accuracy hơn là speed

### ⚡ Sử dụng nhanh

1. **Keyboard shortcuts**: Sử dụng phím 1-4 thay vì click chuột
2. **Sample data**: Dùng "Load Sample" để test nhanh
3. **Preset configs**: Sử dụng preset thay vì config manual

## � Development Setup

### Yêu cầu để phát triển

- **Flutter**: 3.35.3 hoặc mới hơn
- **Dart**: SDK 3.9.2+
- **OS**: Windows 10+ (để build Windows desktop app)
- **IDE**: VS Code, Android Studio, hoặc IntelliJ IDEA
- **Git**: Để clone repository

### 🔧 Cài đặt môi trường phát triển

#### Bước 1: Cài đặt Flutter

1. **Tải Flutter SDK**:

   ```bash
   # Tải từ https://flutter.dev/docs/get-started/install/windows
   # Hoặc sử dụng Git
   git clone https://github.com/flutter/flutter.git -b stable
   ```

2. **Thêm Flutter vào PATH**:

   ```bash
   # Thêm vào system PATH:
   C:\path\to\flutter\bin
   ```

3. **Kiểm tra cài đặt**:
   ```bash
   flutter doctor
   ```

#### Bước 2: Enable Windows Desktop

```bash
# Enable Windows desktop support
flutter config --enable-windows-desktop

# Kiểm tra desktop support
flutter devices
```

#### Bước 3: Cài đặt Visual Studio Build Tools

1. Tải **Visual Studio Build Tools 2019** hoặc **Visual Studio 2022**
2. Trong installer, chọn:
   - **C++ build tools**
   - **Windows 10/11 SDK**
   - **CMake tools**

### 🚀 Chạy project từ source code

#### Clone repository

```bash
# Clone project
git clone [repository-url]
cd vocabulary_quiz_app

# Hoặc tải ZIP và giải nén
```

#### Install dependencies

```bash
# Get Flutter packages
flutter pub get

# Kiểm tra dependencies
flutter pub deps
```

#### Run in development mode

```bash
# Chạy trên Windows desktop
flutter run -d windows

# Hoặc chỉ định device cụ thể
flutter run -d "Windows (desktop)"
```

#### Hot reload during development

- **r**: Hot reload
- **R**: Hot restart
- **q**: Quit
- **h**: Help

### 🏗️ Build for production

#### Debug build

```bash
flutter build windows
```

#### Release build

```bash
flutter build windows --release
```

#### Build output

```
build/
└── windows/
    └── x64/
        └── runner/
            └── Release/
                ├── vocabulary_quiz_app.exe
                ├── flutter_windows.dll
                └── data/
```

### 🧪 Testing

#### Run unit tests

```bash
# Chạy tất cả tests
flutter test

# Chạy test cụ thể
flutter test test/quiz_generator_test.dart

# Test với coverage
flutter test --coverage
```

#### Run widget tests

```bash
# Widget tests
flutter test test/widget_test.dart
```

### 📦 Project structure cho developers

```
lib/
├── main.dart                    # Entry point
├── models/                      # Data models
│   ├── app_state.dart          # Global state (Singleton)
│   ├── vocabulary_item.dart    # Vocabulary data model
│   ├── question.dart           # Quiz question model
│   └── quiz_session.dart       # Quiz session management
├── services/                    # Business logic
│   ├── vocabulary_parser.dart  # File parsing & validation
│   └── quiz_generator.dart     # Quiz generation algorithms
├── screens/                     # UI screens
│   ├── home_screen.dart        # Main dashboard
│   ├── import_screen.dart      # Import interface
│   ├── quiz_setup_screen.dart  # Quiz configuration
│   ├── quiz_screen.dart        # Quiz interface
│   ├── typing_test_setup_screen.dart # Typing test configuration
│   ├── typing_test_screen.dart # Typing test interface
│   ├── results_screen.dart     # Results display (unified for quiz/typing)
│   └── review_screen.dart      # Review wrong answers (both types)
└── widgets/                     # Reusable components
    ├── common_widgets.dart     # Generic widgets
    └── quiz_widgets.dart       # Quiz-specific widgets
```

### 🔍 Debug và troubleshooting

#### Common issues

1. **Flutter doctor issues**:

   ```bash
   flutter doctor -v  # Detailed diagnostics
   flutter clean      # Clean build cache
   flutter pub get    # Reinstall dependencies
   ```

2. **Windows build fails**:

   ```bash
   # Ensure Visual Studio Build Tools installed
   # Check Windows SDK version
   flutter config --list
   ```

3. **Dependency conflicts**:

   ```bash
   flutter pub deps    # Check dependency tree
   flutter pub upgrade # Update packages
   ```

4. **Audio playback issues**:
   ```bash
   # Check custom sound file formats (MP3, WAV, M4A supported)
   # Verify file path accessibility
   # Audio will fallback to system sounds if custom files fail
   ```

#### Development tips

- **Hot reload**: Sử dụng `r` để reload nhanh UI changes
- **Debug console**: Sử dụng `print()` hoặc `debugPrint()`
- **Flutter Inspector**: Enable trong IDE để debug widget tree
- **Performance**: Sử dụng `flutter run --profile` để test performance

#### Error resolution history

Xem file [`ERROR_RESOLUTION_HISTORY.md`](ERROR_RESOLUTION_HISTORY.md) để tìm hiểu về các lỗi đã được giải quyết và kinh nghiệm rút ra.

### 📝 Code style và linting

Project sử dụng **flutter_lints** cho code quality:

```bash
# Chạy analyzer
flutter analyze

# Format code
dart format lib/

# Fix auto-fixable issues
dart fix --apply
```

### 🔄 Git workflow

```bash
# Tạo feature branch
git checkout -b feature/new-feature

# Commit changes
git add .
git commit -m "feat: add new feature"

# Push branch
git push origin feature/new-feature

# Tạo Pull Request trên GitHub
```

### 📚 Useful commands

```bash
# Xem Flutter version
flutter --version

# Xem available devices
flutter devices

# Clean build
flutter clean

# Get dependencies
flutter pub get

# Update dependencies
flutter pub upgrade

# Run analyzer
flutter analyze

# Format code
dart format .

# Build release
flutter build windows --release

# Run tests
flutter test

# Generate icons
flutter pub run flutter_launcher_icons:main
```

## �🛠️ Cài đặt và chạy

### Yêu cầu hệ thống

- **OS**: Windows 10 trở lên
- **RAM**: 4GB+ recommended
- **Storage**: 100MB+ free space

### Chạy ứng dụng

1. Tải thư mục `VocabularyQuizApp_Distribution`
2. Chạy file `vocabulary_quiz_app.exe`
3. Ứng dụng sẽ mở trong vài giây

### Khắc phục sự cố

#### Ứng dụng không khởi chạy

- Kiểm tra Windows Defender không block file
- Chạy với quyền Administrator
- Đảm bảo tất cả file trong thư mục đều có

#### Không import được file

- Kiểm tra file encoding là UTF-8
- Đảm bảo format đúng (word<TAB>meaning)
- Thử paste trực tiếp thay vì import file

#### Performance chậm

- Giảm số lượng từ vựng nếu quá lớn (>1000 items)
- Restart ứng dụng nếu dùng lâu
- Đóng các ứng dụng khác đang chạy

## 📋 Changelog

### Version 1.1.0 (Latest)

#### 🆕 New Features:

- ⌨️ **Typing Test System**: Complete typing test implementation với scoring và hints
- 🔍 **Typing Test Review**: Review wrong typing answers với detailed feedback
- 📊 **Unified Results Screen**: Single results screen cho cả quiz và typing test
- 🎯 **Test Status Management**: Reset quiz/typing status independently
- 📱 **Enhanced Responsive Design**: Improved layout cho multiple screen sizes

#### 🐛 Bug Fixes:

- ✅ Fixed overflow issues trên multiple screens
- ✅ Improved layout stability và prevented RenderBox errors
- ✅ Enhanced memory management cho typing test sessions
- ✅ Fixed keyboard navigation trong typing test interface

#### 🔧 Improvements:

- 📊 Better performance tracking cho typing tests
- 🎨 Improved visual feedback với consistent color coding
- ⌨️ Enhanced keyboard shortcuts support
- 🔊 Stable audio service với better error handling

### Version 1.0.0

- ✅ Import từ vựng từ file/text
- ✅ Quiz với 2 loại câu hỏi
- ✅ Visual feedback màu sắc
- 🔊 **Audio feedback system** - Âm thanh phản hồi cho quiz interactions
- ✅ Review system
- ✅ Keyboard shortcuts
- ✅ Timer và statistics
- ✅ Responsive design

#### Audio Features:

- 🎵 **Correct answer sound**: SystemSoundType.click cho câu trả lời đúng
- 🚨 **Incorrect answer sound**: SystemSoundType.alert cho câu trả lời sai
- 🎉 **Completion sound**: Sequence of clicks khi hoàn thành quiz
- 🔊 **Audio toggle**: Nút bật/tắt âm thanh trong quiz interface
- ⚙️ **Global audio settings**: AudioEnabled state được lưu trong AppState
- 🎧 **Custom sound support**: Có thể thay thế system sounds bằng custom MP3/WAV files
- 📁 **Sound assets**: Đặt file âm thanh trong `assets/sounds/` để sử dụng custom sounds

## 🤝 Đóng góp

Nếu bạn muốn đóng góp hoặc báo lỗi:

1. Tạo issue mô tả chi tiết
2. Fork repository và tạo pull request
3. Liên hệ qua email hoặc social media

## 📞 Hỗ trợ

- **Email**: [your-email@example.com]
- **GitHub Issues**: [Repository Link]
- **Documentation**: `ARCHITECTURE_DOCUMENTATION.md`

---

**Phiên bản**: 1.1.0  
**Ngày cập nhật**: 21/09/2025  
**Nền tảng**: Windows Desktop  
**Framework**: Flutter 3.35.3

**Major Updates v1.1.0:**

- ⌨️ Complete Typing Test System
- 🔍 Enhanced Review for both Quiz và Typing Test
- 📊 Unified Results Display
- 🎯 Independent Test Status Management
- 📱 Improved Responsive Design và Layout Stability

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
