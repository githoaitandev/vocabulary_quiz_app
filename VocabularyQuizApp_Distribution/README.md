# Vocabulary Quiz App

## 📚 Giới thiệu

Ứng dụng Vocabulary Quiz App giúp bạn học từ vựng tiếng Anh một cách hiệu quả thông qua các bài kiểm tra tương tác.

## 🚀 Cách sử dụng

### Khởi chạy ứng dụng

1. Chạy file `vocabulary_quiz_app.exe`
2. Ứng dụng sẽ mở ra giao diện chính

### Các tính năng chính

#### 📥 Import từ vựng

- Nhấn "Import Vocabulary" để tải danh sách từ vựng
- Hỗ trợ định dạng file text với cấu trúc:
  ```
  word1: meaning1
  word2: meaning2
  example: This is an example sentence
  ```

#### 🎯 Làm bài quiz

1. Nhấn "Start Quiz" sau khi đã import từ vựng
2. Chọn các tùy chọn quiz:
   - Số lượng câu hỏi
   - Loại câu hỏi (Từ → Nghĩa hoặc Nghĩa → Từ)
3. Bắt đầu làm bài và chọn đáp án
4. **Phản hồi ngay lập tức**:
   - ✅ **Màu xanh**: Đáp án đúng
   - ❌ **Màu đỏ**: Đáp án sai (hiển thị đáp án đúng)

#### ⌨️ Phím tắt

- **1-4**: Chọn đáp án
- **←→**: Điều hướng câu hỏi
- **Enter**: Tiếp tục/Hoàn thành

#### 📊 Xem kết quả

- Xem điểm số và thống kê sau khi hoàn thành quiz
- Ôn tập các câu trả lời sai

## 💻 Yêu cầu hệ thống

- Windows 10 trở lên
- Không cần cài đặt thêm phần mềm

## 📁 Cấu trúc file

```
VocabularyQuizApp_Distribution/
├── vocabulary_quiz_app.exe     # File thực thi chính
├── flutter_windows.dll        # Thư viện Flutter
├── data/                       # Dữ liệu ứng dụng
│   ├── app.so                 # Logic ứng dụng
│   ├── icudtl.dat            # Dữ liệu Unicode
│   └── flutter_assets/        # Tài nguyên giao diện
└── README.md                   # Hướng dẫn này
```

## 🔧 Khắc phục sự cố

### Ứng dụng không khởi chạy

1. Đảm bảo tất cả file trong thư mục không bị xóa
2. Chạy với quyền Administrator nếu cần
3. Kiểm tra Windows Defender không chặn file .exe

### Không import được file

1. Đảm bảo file text có định dạng UTF-8
2. Kiểm tra cấu trúc file đúng format

## 📞 Hỗ trợ

Nếu gặp vấn đề, vui lòng liên hệ hoặc tạo issue trên repository.

---

**Phiên bản**: 1.0.0  
**Ngày build**: $(Get-Date -Format "dd/MM/yyyy")  
**Nền tảng**: Windows Desktop (Flutter)
