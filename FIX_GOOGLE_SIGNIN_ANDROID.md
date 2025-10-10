# Fix Google Sign-In Error 10 (DEVELOPER_ERROR) trên Android

## ❌ Lỗi hiện tại:
```
PlatformException(sign_in_failed, 
com.google.android.gms.common.api.ApiException: 10: , null, null)
```

**Error Code 10** = `DEVELOPER_ERROR` - Cấu hình Google Sign-In chưa đúng cho Android.

## ✅ Giải pháp:

### **Bước 1: Thông tin cần có**

📱 **Package Name:** `com.example.monitor_app`

🔑 **SHA-1 Fingerprint (Debug):** 
```
D6:09:D9:82:D4:3C:CF:05:1E:F4:EA:72:CF:7B:A0:AE:29:AD:69:B2
```

### **Bước 2: Thêm OAuth Client ID cho Android**

1. Truy cập: https://console.cloud.google.com/apis/credentials
2. Chọn project của bạn
3. Click **"+ CREATE CREDENTIALS"** → **"OAuth client ID"**
4. Chọn **Application type**: `Android`
5. Điền thông tin:
   - **Name**: `Ping365 (Android)`
   - **Package name**: `com.example.monitor_app`
   - **SHA-1 certificate fingerprint**: 
     ```
     D6:09:D9:82:D4:3C:CF:05:1E:F4:EA:72:CF:7B:A0:AE:29:AD:69:B2
     ```
6. Click **"CREATE"**

### **Bước 3: Kiểm tra OAuth Client IDs**

Sau khi tạo, bạn sẽ có 2 OAuth Client IDs:

1. ✅ **Web client** (đã có - đang dùng cho Flutter Web):
   ```
   211733424826-d7dns77hrghn70tugmlbo7p15ugfed4m.apps.googleusercontent.com
   ```

2. ✅ **Android client** (vừa tạo):
   ```
   211733424826-XXXXXXXXXX.apps.googleusercontent.com
   ```
   ⚠️ **KHÔNG cần thay đổi code Flutter!** 
   - Flutter sẽ tự động dùng Web Client ID
   - Google Play Services sẽ tự động map với Android Client ID

### **Bước 4: Cập nhật google-services.json (Nếu cần)**

Nếu bạn đang dùng Firebase, đảm bảo `google-services.json` đã có:

```json
{
  "project_info": {
    "project_id": "YOUR_PROJECT_ID"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "...",
        "android_client_info": {
          "package_name": "com.example.monitor_app"
        }
      },
      "oauth_client": [
        {
          "client_id": "211733424826-d7dns77hrghn70tugmlbo7p15ugfed4m.apps.googleusercontent.com",
          "client_type": 3
        },
        {
          "client_id": "211733424826-XXXXXXXXXX.apps.googleusercontent.com",
          "client_type": 1
        }
      ]
    }
  ]
}
```

### **Bước 5: Test lại**

1. **Rebuild app:**
   ```bash
   flutter clean
   flutter pub get
   flutter build apk
   ```

2. **Install và test:**
   ```bash
   flutter install
   ```

3. Click **"Đăng nhập với Google"**

## 🔍 Debug nếu vẫn lỗi:

### **Kiểm tra SHA-1:**
```bash
cd android
./gradlew signingReport
```

Đảm bảo SHA-1 trong Google Console khớp với output.

### **Kiểm tra Package Name:**
File `android/app/build.gradle.kts`:
```kotlin
applicationId = "com.example.monitor_app"
```

### **Kiểm tra OAuth Client IDs:**
```bash
# List all OAuth clients
gcloud auth application-default login
gcloud projects list
```

## 📝 Notes:

- **Debug build** dùng SHA-1 từ `debug.keystore`
- **Release build** cần SHA-1 từ release keystore
- SHA-1 thay đổi → Phải cập nhật lại Google Console
- Sau khi thêm SHA-1, đợi **5-10 phút** để Google propagate changes

## ✅ Expected Result:

Sau khi fix:
```
[GOOGLE] Starting Google Sign-In...
[GOOGLE] Sign-In successful: user@gmail.com
[GOOGLE] ID Token: Found (hoặc NULL)
[GOOGLE] Access Token: Found
[GOOGLE] Backend response: 200
✅ Đăng nhập thành công
```

---

**Tóm tắt:** Cần thêm OAuth Client ID cho Android với SHA-1 fingerprint vào Google Cloud Console.
