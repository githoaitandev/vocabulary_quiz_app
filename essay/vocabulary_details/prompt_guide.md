# Hướng Dẫn Tạo Thông Tin Từ Vựng Chi Tiết

## Yêu Cầu Cơ Bản

Dưới đây là prompt request tổng hợp để tạo thông tin từ vựng chi tiết từ một danh sách từ có sẵn:

```
Với bối cảnh hỗ trợ học từ vựng, tôi có danh sách từ vựng (đính kèm hoặc cung cấp trong file), nhiệm vụ của bạn là tạo output cho các từ vựng, bao gồm các thông tin:
- từ loại
- nghĩa, càng chi tiết càng tốt
- ngữ cảnh sử dụng
- ví dụ (hỗ trợ anh-việt cho câu ví dụ)

Quan trọng: Để tránh lỗi giới hạn độ dài phản hồi, hãy chia nhỏ output thành nhiều file riêng biệt, mỗi file chứa khoảng 25-30 từ vựng. Tạo một file index để liên kết đến tất cả các file từ vựng.
```

## Cấu Trúc Thư Mục Đề Xuất

```
vocabulary_details/
├── index.md                  # Tệp chỉ mục chính để điều hướng
├── vocabulary_1-25.md        # Nhóm từ vựng 1-25
├── vocabulary_26-50.md       # Nhóm từ vựng 26-50
└── ...                       # Các nhóm từ vựng tiếp theo
```

## Mẫu Format Cho Mỗi Từ

Dưới đây là mẫu định dạng cho mỗi từ vựng:

```markdown
## [Số thứ tự]. [Từ vựng]

- **Từ loại**: [Danh từ/Động từ/Tính từ/...] ([noun/verb/adjective/...])
- **Nghĩa**: [Định nghĩa chi tiết, bao gồm các nghĩa khác nhau nếu có]
- **Ngữ cảnh sử dụng**: [Mô tả các tình huống/ngữ cảnh phù hợp để sử dụng từ]
- **Ví dụ**:
  - [Câu ví dụ tiếng Anh]
  - ([Bản dịch tiếng Việt])
  - [Câu ví dụ tiếng Anh thứ hai (nếu có)]
  - ([Bản dịch tiếng Việt])
```

## Mẫu Cho File Index

```markdown
# Vocabulary Builder Index

Đây là chỉ mục giúp bạn điều hướng qua tất cả các phần từ vựng. Mỗi file chứa thông tin chi tiết cho các từ bao gồm:

- Từ loại
- Nghĩa chi tiết
- Ngữ cảnh sử dụng
- Câu ví dụ kèm bản dịch Anh-Việt

## Các Phần

1. [Từ 1-25](./vocabulary_1-25.md)
2. [Từ 26-50](./vocabulary_26-50.md)
3. [Từ 51-75](./vocabulary_51-75.md)
4. [...]

## Cách Sử Dụng Tài Liệu Này

1. Sử dụng các liên kết trên để điều hướng đến các nhóm từ cụ thể
2. Mỗi mục từ vựng chứa thông tin toàn diện để hỗ trợ việc học từ
3. Xem xét các câu ví dụ để hiểu cách sử dụng từ trong ngữ cảnh
4. Thực hành sử dụng các từ này trong câu của riêng bạn
```

## Lưu Ý Quan Trọng

1. **Phân chia hợp lý**: Luôn chia nhỏ danh sách từ vựng thành nhiều file để tránh lỗi giới hạn độ dài phản hồi.

2. **Tính nhất quán**: Giữ định dạng nhất quán cho tất cả các từ để dễ dàng đọc và so sánh.

3. **Ví dụ thực tế**: Cung cấp các ví dụ thực tế và có ngữ cảnh rõ ràng để hiểu cách sử dụng từ.

4. **Bản dịch chính xác**: Đảm bảo bản dịch tiếng Việt truyền tải đúng ý nghĩa của câu tiếng Anh.

5. **Mỗi từ vựng nên có ít nhất 2-3 ví dụ** để minh họa các cách sử dụng khác nhau.
