# Firebase Service Account Setup

## ❌ LỖI: invalid_grant

Lỗi này xảy ra vì thiếu hoặc sai Firebase Service Account key.

## ✅ CÁC BƯỚC KHẮC PHỤC:

### 1. Download Service Account Key từ Firebase Console

1. Vào Firebase Console: https://console.firebase.google.com/
2. Chọn project: **MonitorV2**
3. Click **⚙️ (Settings)** → **Project settings**
4. Chọn tab **Service accounts**
5. Click nút **Generate new private key**
6. Confirm và download file JSON
7. Đổi tên file thành `fb.json`
8. Copy vào thư mục `_php/`

### 2. Cấu trúc file fb.json

File `fb.json` sẽ có dạng:

```json
{
  "type": "service_account",
  "project_id": "monitorv2-dcf5b",
  "private_key_id": "...",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-xxxxx@monitorv2-dcf5b.iam.gserviceaccount.com",
  "client_id": "...",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "...",
  "universe_domain": "googleapis.com"
}
```

### 3. Đảm bảo file có đúng permissions

```bash
# Windows
icacls fb.json /grant:r "%USERNAME%:(R)"

# Linux/Mac
chmod 600 fb.json
```

### 4. Test lại

```bash
cd _php
php send_notification.php
```

## 🔐 BẢO MẬT

⚠️ **QUAN TRỌNG:**
- File `fb.json` chứa credentials nhạy cảm
- **KHÔNG commit** file này lên Git
- File đã được thêm vào `.gitignore`
- Chỉ lưu trên server production

## 📝 Kiểm tra file

```bash
# Kiểm tra file có tồn tại
ls -la _php/fb.json

# Xem nội dung (cẩn thận!)
cat _php/fb.json | head -5
```

## 🚀 Alternative: Sử dụng FCM Server Key (Legacy)

Nếu không muốn dùng Service Account, có thể dùng Server Key:

1. Vào **Project Settings** → **Cloud Messaging** tab
2. Trong phần **Cloud Messaging API (Legacy)**
3. Copy **Server key**
4. Sử dụng trong file `firebase_messaging.php` thay vì `send_notification.php`

**Lưu ý:** Legacy API sẽ bị deprecated vào 2024, nên dùng Service Account.

## 📞 Support

Nếu vẫn gặp lỗi sau khi làm theo hướng dẫn, kiểm tra:
- Firebase project có enable Cloud Messaging API
- Service Account có role **Firebase Cloud Messaging Admin**
- Composer packages đã được cài đặt: `composer install`
