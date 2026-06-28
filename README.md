# Driver Monitoring System (DMS) - AI Detection (Windows Release)

Hệ thống giám sát trạng thái tài xế (phát hiện buồn ngủ, ngáp, mất tập trung) thời gian thực bằng trí tuệ nhân tạo, được thiết kế và tối ưu hóa hoạt động trực tiếp trên hệ điều hành **Windows**.

Dự án kết hợp mô hình trích xuất đặc trưng khuôn mặt động (**MediaPipe Face Mesh**) và mô hình học sâu tuần hoàn **LSTM (PyTorch)** nhằm phân tích chuỗi hành vi thời gian thực trong 60 giây và đưa ra dự báo sớm trạng thái buồn ngủ/vi ngủ (Microsleep).

---

## Các tính năng chính

- **Phân tích đặc trưng sinh học thời gian thực**:
  - **EAR (Eye Aspect Ratio)**: Đo lường độ mở mắt động theo trạng thái sinh lý của tài xế.
  - **MAR (Mouth Aspect Ratio)**: Đánh giá biên độ mở miệng để phát hiện hành vi ngáp.
  - **Head Pose Estimation (SolvePnP)**: Tính toán góc cúi/ngửa (Pitch), nghiêng (Roll) và quay đầu (Yaw) dưới dạng tọa độ 3D.
- **Tính toán chỉ số PERCLOS**: Đánh giá phần trăm thời gian nhắm mắt tích lũy để nhận diện trạng thái mệt mỏi khách quan.
- **Dự báo vi ngủ sớm bằng LSTM**: Sử dụng chuỗi trượt 60 giây để dự đoán sớm nguy cơ buồn ngủ trước khi xảy ra sự cố.
- **Cơ chế phản hồi cảnh báo khẩn cấp (Safety Overrides)**:
  - Báo động tức thì nếu nhắm mắt liên tục > 1.0 giây.
  - Báo động tức thì nếu lệch đầu, gục đầu quá góc quy định > 1.0 giây.
  - Cảnh báo mất dấu khuôn mặt (Face Lost) nếu tài xế lệch khỏi khung hình > 1.5 giây.
- **Cảnh báo âm thanh**: Tích hợp còi bíp cảnh báo mặc định trực tiếp qua loa của máy tính Windows (sử dụng thư viện hệ thống `winsound`).
- **Lưu lịch sử hoạt động**: Tự động lưu trữ thông số trạng thái mỗi giây vào cơ sở dữ liệu SQLite (`dms_history.db`) phục vụ giám sát và phân tích hành trình.

---

## Cấu trúc thư mục dự án

```text
├── drowsiness_detector.py # Chương trình nhận diện và chạy Dashboard chính
├── lstm_model.py          # Kiến trúc mạng LSTM (PyTorch)
├── train_lstm.py          # Kịch bản huấn luyện mô hình LSTM
├── lstm_drowsiness.pth    # Trọng số mô hình đã được huấn luyện sẵn
├── requirements.txt       # Danh sách các thư viện Python cần thiết
└── README.md              # Hướng dẫn sử dụng
```

---

## Hướng dẫn cài đặt và sử dụng

### 1. Yêu cầu hệ thống
- **Hệ điều hành**: Windows 10 / 11.
- **Môi trường Python**: **Python 3.10** hoặc **Python 3.11** (Bắt buộc dùng phiên bản này để tương thích tốt nhất với thư viện nhận diện khuôn mặt MediaPipe trên Windows). *Lưu ý: Không dùng Python 3.12 hoặc 3.13.*
- **Thiết bị**: Webcam USB tích hợp sẵn của laptop hoặc gắn ngoài.

### 2. Cài đặt thư viện phụ thuộc
Mở Command Prompt (cmd) hoặc PowerShell tại thư mục dự án và chạy lệnh sau để tự động cài đặt:
```cmd
pip install -r requirements.txt
```
Hoặc cài đặt thủ công các gói chính:
```cmd
pip install opencv-python mediapipe torch numpy
```

### 3. Chạy chương trình
Khởi chạy ứng dụng bằng cách chỉ định chạy qua Python 3.10:
```cmd
py -3.10 drowsiness_detector.py
```
*(Nếu muốn tự huấn luyện lại mô hình LSTM từ đầu, hãy chạy: `py -3.10 train_lstm.py` trước).*

---

## Hướng dẫn kiểm thử (Testing & Calibration)

1. **Hiệu chuẩn ban đầu (Calibration)**: Khi ứng dụng bắt đầu mở camera thành công, tài xế cần ngồi thẳng lưng với tư thế thoải mái nhất, nhìn thẳng vào camera trong khoảng **3 giây đầu (100 frames)** để hệ thống ghi nhận baseline sinh học chuẩn (EAR, MAR, Head Pose gốc).
2. **Hiệu chuẩn lại (Re-calibration)**: Nhấn phím **`r`** trên bàn phím bất cứ lúc nào nếu bạn đổi tư thế ngồi, chỉnh ghế hoặc chỉnh góc đặt camera.
3. **Thoát chương trình**: Nhấn phím **`q`** tại màn hình hiển thị Dashboard của camera để giải phóng camera và đóng ứng dụng an toàn.
