# Driver Monitoring System (DMS) - AI Detection (Phiên bản Windows)

Hệ thống giám sát trạng thái tài xế (phát hiện buồn ngủ, ngáp, mất tập trung) thời gian thực bằng trí tuệ nhân tạo, được thiết kế và tối ưu chạy trực tiếp trên hệ điều hành **Windows**. 

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
- **Cảnh báo âm thanh**: Tích hợp còi bíp cảnh báo mặc định trực tiếp qua loa của máy tính Windows (sử dụng thư viện `winsound`).
- **Tích hợp phần cứng ngoài (Arduino / ESP32)**: Truyền trạng thái cảnh báo thời gian thực xuống cổng COM (Serial) để kích hoạt còi chíp và mô tơ rung gắn ngoài.
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

## Yêu cầu môi trường

- **Hệ điều hành**: Windows 10 / 11.
- **Môi trường Python**: **Python 3.10** hoặc **Python 3.11** (Bắt buộc dùng phiên bản này để tương thích tốt nhất với thư viện nhận diện khuôn mặt MediaPipe trên Windows). *Lưu ý: Không dùng Python 3.12 hoặc 3.13 vì cấu trúc đóng gói MediaPipe mới thiếu các lớp nhận diện cũ.*
- **Thiết bị**: Camera USB Webcam tích hợp hoặc gắn ngoài.

---

## Hướng dẫn cài đặt và sử dụng

### Bước 1: Cài đặt các thư viện cần thiết
Mở Command Prompt (cmd) hoặc PowerShell tại thư mục dự án và chạy lệnh sau để cài đặt các thư viện phụ thuộc:
```cmd
pip install -r requirements.txt
```
Hoặc nếu muốn cài đặt thủ công từng thư viện:
```cmd
pip install opencv-python mediapipe torch pyserial numpy
```

### Bước 2: Chạy chương trình
Khởi chạy ứng dụng bằng cách chỉ định chạy qua Python 3.10 (phòng trường hợp máy tính của bạn cài nhiều phiên bản Python):
```cmd
py -3.10 drowsiness_detector.py
```
*(Nếu muốn tự huấn luyện lại mô hình LSTM từ đầu bằng dữ liệu giả lập, hãy chạy lệnh: `py -3.10 train_lstm.py` trước).*

---

## Kết nối cảnh báo ngoại vi (Arduino / ESP32)

Nếu bạn muốn kết nối hệ thống với còi chíp và động cơ rung vật lý thông qua cổng USB của máy tính Windows:

### 1. Cấu hình cổng COM trong Code
Mở file `drowsiness_detector.py` và sửa biến `ARDUINO_PORT` ở phần khai báo đầu file thành cổng kết nối thực tế trên máy của bạn (Ví dụ: `COM3`, `COM4`):
```python
# Cấu hình cổng COM kết nối Arduino/ESP32 trên Windows (Rung + Còi vật lý)
ARDUINO_PORT = 'COM3'  # Thay đổi thành cổng COM thực tế của bạn
```

### 2. Code mẫu nạp cho mạch Arduino / ESP32
Dưới đây là mã nguồn C++ mẫu để bạn nạp vào mạch xử lý ngoại vi nhằm tiếp nhận tín hiệu từ phần mềm chuyển thành hành động rung/kêu:

```cpp
int buzzerPin = 8; // Chân kết nối còi chíp (Active Buzzer)
int motorPin = 9;  // Chân kết nối mô tơ rung

void setup() {
  Serial.begin(9600); // Khởi tạo giao tiếp serial cùng baudrate với phần mềm
  pinMode(buzzerPin, OUTPUT);
  pinMode(motorPin, OUTPUT);
  digitalWrite(buzzerPin, LOW);
  digitalWrite(motorPin, LOW);
}

void loop() {
  if (Serial.available() > 0) {
    char alarm_level = Serial.read(); // Đọc trạng thái từ phần mềm gửi xuống (từ '0' đến '3')
    
    if (alarm_level == '0') { // Bình thường
      digitalWrite(buzzerPin, LOW);
      digitalWrite(motorPin, LOW);
    } 
    else if (alarm_level == '1') { // Mệt mỏi nhẹ
      digitalWrite(motorPin, LOW);
      // Còi kêu ngắt quãng chậm
      digitalWrite(buzzerPin, HIGH);
      delay(100);
      digitalWrite(buzzerPin, LOW);
      delay(900);
    } 
    else if (alarm_level == '2') { // Mệt mỏi vừa
      digitalWrite(motorPin, HIGH);
      // Còi kêu dồn dập
      digitalWrite(buzzerPin, HIGH);
      delay(200);
      digitalWrite(buzzerPin, LOW);
      delay(300);
    } 
    else if (alarm_level == '3') { // Nguy hiểm (Nhắm mắt/Lệch đầu lâu hoặc vi ngủ)
      digitalWrite(motorPin, HIGH);
      // Còi bíp liên tục cảnh báo khẩn cấp
      digitalWrite(buzzerPin, HIGH);
      delay(100);
      digitalWrite(buzzerPin, LOW);
      delay(100);
    }
  }
}
```

---

## Hướng dẫn kiểm thử (Testing & Calibration)

1. **Hiệu chuẩn ban đầu (Calibration)**: Khi ứng dụng bắt đầu mở camera thành công, tài xế cần ngồi thẳng lưng với tư thế thoải mái nhất, nhìn thẳng vào camera trong khoảng **3 giây đầu (100 frames)** để hệ thống ghi nhận baseline sinh học chuẩn (EAR, MAR, Head Pose gốc).
2. **Hiệu chuẩn lại (Re-calibration)**: Nhấn phím **`r`** trên bàn phím bất cứ lúc nào nếu bạn đổi tư thế ngồi, chỉnh ghế hoặc chỉnh góc đặt camera.
3. **Thoát chương trình**: Nhấn phím **`q`** tại màn hình hiển thị Dashboard của camera để giải phóng camera và đóng ứng dụng an toàn.
