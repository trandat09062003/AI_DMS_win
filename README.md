# Driver Monitoring System (DMS) - AI Detection (Cross-Platform: Windows & Raspberry Pi)

Hệ thống giám sát trạng thái tài xế (phát hiện buồn ngủ, ngáp, mất tập trung) thời gian thực bằng trí tuệ nhân tạo. 

Dự án kết hợp mô hình trích xuất đặc trưng khuôn mặt động (**MediaPipe Face Mesh**) và mô hình học sâu tuần hoàn **LSTM (PyTorch)** nhằm phân tích chuỗi hành vi thời gian thực trong 60 giây và đưa ra dự báo sớm trạng thái buồn ngủ/vi ngủ (Microsleep).

Mã nguồn được thiết kế chạy **đa nền tảng (Cross-platform)**: Hỗ trợ kiểm thử trực quan trên **Windows** (cảnh báo qua loa PC) và triển khai thực tế trên **Raspberry Pi** (điều khiển còi và mô-tơ rung kết nối trực tiếp qua chân GPIO).

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
- **Tương thích phần cứng thông minh**:
  - **Trên Windows**: Cảnh báo loa mặc định qua bộ phát âm thanh hệ thống (thư viện `winsound`).
  - **Trên Raspberry Pi**: Tự động nhận diện và điều khiển trực tiếp mô-tơ rung và còi chíp qua các chân GPIO.
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

## Hướng dẫn cài đặt và chạy trên Windows (Để kiểm thử)

### 1. Yêu cầu môi trường
- **Môi trường Python**: **Python 3.10** hoặc **Python 3.11** (Bắt buộc dùng phiên bản này để tương thích tốt nhất với MediaPipe Face Mesh trên Windows). *Lưu ý: Không dùng Python 3.12 hoặc 3.13.*
- **Thiết bị**: Webcam USB tích hợp hoặc gắn ngoài.

### 2. Cài đặt thư viện
Mở Command Prompt (cmd) hoặc PowerShell tại thư mục dự án và chạy:
```cmd
pip install -r requirements.txt
```

### 3. Chạy chương trình
Khởi chạy ứng dụng bằng cách chỉ định chạy qua Python 3.10:
```cmd
py -3.10 drowsiness_detector.py
```

---

## Hướng dẫn kết nối và chạy trên Raspberry Pi (Để triển khai)

### 1. Sơ đồ kết nối còi và mô tơ rung trực tiếp vào GPIO
Bạn kết nối trực tiếp các thiết bị ngoại vi vào các chân GPIO của Raspberry Pi (Khuyên dùng transistor điều khiển dòng hoặc module relay/opto cách ly để bảo vệ chân Pi):

* **Động cơ rung**: Kết nối cực điều khiển (nhận tín hiệu kích hoạt) vào chân **GPIO 17** (BCM 17 / Physical Pin 11).
* **Còi chíp (Active Buzzer)**: Kết nối cực điều khiển vào chân **GPIO 27** (BCM 27 / Physical Pin 13).
* **Chân GND**: Kết nối cực âm chung về chân **GND** của Raspberry Pi (ví dụ: Chân số 9 hoặc 14).

### 2. Cài đặt các gói phụ thuộc trên Ubuntu/Linux của Pi
Mở Terminal trên Pi và chạy lệnh:
```bash
sudo apt update
sudo apt install -y libcamera-tools
pip install -r requirements.txt
```
*Lưu ý: Gói `RPi.GPIO` sẽ tự động được sử dụng để điều khiển chân vật lý khi chương trình phát hiện đang chạy trên môi trường Linux có hỗ trợ GPIO.*

### 3. Cấu hình Camera CSI (Nếu dùng Raspberry Pi Camera Module 3)
1. Thêm driver cảm biến vào cuối file `/boot/firmware/config.txt` (hoặc `/boot/config.txt` tùy bản OS):
   ```text
   dtoverlay=imx708
   ```
2. Khởi động lại Raspberry Pi:
   ```bash
   sudo reboot
   ```
3. Chạy chương trình thông qua công cụ hỗ trợ tương thích libcamera:
   ```bash
   LD_PRELOAD=$(find /usr/lib -name "v4l2-compat.so" | head -n 1) python3 drowsiness_detector.py
   ```
   *(Hoặc `libcamerify python3 drowsiness_detector.py` nếu hệ điều hành của bạn có sẵn lệnh shortcut).*

---

## Hướng dẫn kiểm thử (Testing & Calibration)

1. **Hiệu chuẩn ban đầu (Calibration)**: Khi ứng dụng bắt đầu mở camera thành công, tài xế cần ngồi thẳng lưng với tư thế thoải mái nhất, nhìn thẳng vào camera trong khoảng **3 giây đầu (100 frames)** để hệ thống ghi nhận baseline sinh học chuẩn (EAR, MAR, Head Pose gốc).
2. **Hiệu chuẩn lại (Re-calibration)**: Nhấn phím **`r`** trên bàn phím bất cứ lúc nào nếu bạn đổi tư thế ngồi, chỉnh ghế hoặc chỉnh góc đặt camera.
3. **Thoát chương trình**: Nhấn phím **`q`** tại màn hình hiển thị Dashboard của camera để giải phóng camera và đóng ứng dụng an toàn.
