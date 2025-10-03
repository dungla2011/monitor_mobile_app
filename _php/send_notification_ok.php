<?php

require 'vendor/autoload.php';

use Kreait\Firebase\Factory;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;

// Khởi tạo Firebase
$factory = (new Factory)
    ->withServiceAccount('fb.json')
    ->withDatabaseUri('https://monitorv2-dcf5b-default-rtdb.firebaseio.com');

$cloudMessaging = $factory->createMessaging();

// ===== CẤU HÌNH TIN NHẮN =====

// 1. Thay thế bằng Device Registration Token thực tế của bạn
$deviceToken = 'cc15S_s4T2SDIX5eRjZMg1:APA91bF7drTZouofeRzA-aFXIKEmJlLrtbU5VnwQh9359gdKvYk3-r3Q3SmzY0lLEJsOAjKsOz-0M2ISGEHCdHiGUmKP9jMwsmdj55F8Z9aeAIHdy4TtVwY';
// Ví dụ token: 'fA1B2c3D4e5F6g7H8i9J0k1L2m3N4o5P6q7R8s9T0u1V2w3X4y5Z6a7B8c9D0e1F2'

// 2. Cấu hình nội dung thông báo
$title = 'Cảnh báo từ Monitor App';
$body = 'Hệ thống phát hiện bất thường tại thiết bị ABC123';

// 3. Dữ liệu tùy chỉnh (sẽ được gửi đến app)
$customData = [
    'device_id' => 'ABC123',
    'alert_type' => 'system_warning',
    'severity' => 'high',
    'timestamp' => date('Y-m-d H:i:s'),
    'action_required' => 'check_system_status'
];

// ===== TẠO VÀ GỬI TIN NHẮN =====

// Tạo notification
$notification = Notification::create($title, $body);

// Tạo message
$message = CloudMessage::new()
    ->withNotification($notification)
    ->withData($customData)
    ->toToken($deviceToken);

// Gửi tin nhắn
try {
    echo "🚀 Đang gửi tin nhắn...\n";
    echo "📱 Device Token: " . substr($deviceToken, 0, 20) . "...\n";
    echo "📢 Tiêu đề: $title\n";
    echo "📝 Nội dung: $body\n\n";
    
    $result = $cloudMessaging->send($message);
    
    echo "✅ GỬI THÀNH CÔNG!\n";
    echo "📩 Message ID: " . $result['name'] . "\n";
    echo "🕐 Thời gian: " . date('Y-m-d H:i:s') . "\n";
    
} catch (Exception $e) {
    echo "❌ LỖI: " . $e->getMessage() . "\n\n";
    
    // Hướng dẫn khắc phục lỗi phổ biến
    echo "💡 HƯỚNG DẪN KHẮC PHỤC:\n";
    
    if (strpos($e->getMessage(), 'registration-token-not-registered') !== false) {
        echo "- Device token không hợp lệ hoặc app đã bị gỡ\n";
        echo "- Cần lấy token mới từ client app\n";
    } 
    elseif (strpos($e->getMessage(), 'invalid-registration-token') !== false) {
        echo "- Device token có định dạng sai\n";
        echo "- Kiểm tra lại token từ client app\n";
    }
    elseif (strpos($e->getMessage(), 'authentication') !== false) {
        echo "- Lỗi xác thực với Firebase\n";
        echo "- Kiểm tra file fb.json và quyền của Service Account\n";
    }
    else {
        echo "- Kiểm tra kết nối internet\n";
        echo "- Đảm bảo Firebase project đã enable Cloud Messaging\n";
    }
}

echo "\n" . str_repeat("=", 60) . "\n";
echo "HƯỚNG DẪN LẤY DEVICE TOKEN:\n";
echo str_repeat("=", 60) . "\n";
echo "📱 ANDROID:\n";
echo "FirebaseMessaging.getInstance().getToken().addOnCompleteListener(task -> {\n";
echo "    if (!task.isSuccessful()) return;\n";
echo "    String token = task.getResult();\n";
echo "    Log.d(\"FCM Token\", token);\n";
echo "});\n\n";

echo "🍎 iOS (Swift):\n";
echo "Messaging.messaging().token { token, error in\n";
echo "    if let error = error {\n";
echo "        print(\"Error fetching FCM registration token: \\(error)\")\n";
echo "    } else if let token = token {\n";
echo "        print(\"FCM registration token: \\(token)\")\n";
echo "    }\n";
echo "}\n\n";

echo "🌐 WEB (JavaScript):\n";
echo "import { getMessaging, getToken } from 'firebase/messaging';\n";
echo "const messaging = getMessaging();\n";
echo "getToken(messaging, { vapidKey: 'YOUR_VAPID_KEY' }).then((token) => {\n";
echo "    console.log('Registration token:', token);\n";
echo "});\n";

?>