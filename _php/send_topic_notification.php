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

// ===== GỬI TIN NHẮN ĐẾN TOPIC (CHỦ ĐỀ) =====

// Topic name - tất cả thiết bị đã subscribe topic này sẽ nhận tin nhắn
$topicName = 'monitoring_alerts';

// Tạo nội dung thông báo
$notification = Notification::create(
    'Cảnh báo hệ thống',
    'Phát hiện sự cố tại thiết bị ABC123 - Cần kiểm tra ngay'
);

// Dữ liệu tùy chỉnh
$data = [
    'alert_type' => 'critical',
    'device_id' => 'ABC123',
    'location' => 'Server Room A',
    'timestamp' => date('Y-m-d H:i:s'),
    'action_url' => 'https://your-monitor-app.com/alerts/abc123'
];

// Tạo message gửi đến topic
$topicMessage = CloudMessage::new()
    ->withNotification($notification)
    ->withData($data)
    ->toTopic($topicName);

try {
    echo "📡 Đang gửi tin nhắn đến topic: '$topicName'\n";
    echo "📢 Tiêu đề: " . $notification->title() . "\n";
    echo "📝 Nội dung: " . $notification->body() . "\n\n";
    
    $result = $cloudMessaging->send($topicMessage);
    
    echo "✅ GỬI THÀNH CÔNG ĐẾN TOPIC!\n";
    echo "📩 Message ID: " . $result['name'] . "\n";
    echo "🕐 Thời gian: " . date('Y-m-d H:i:s') . "\n";
    echo "👥 Tất cả thiết bị đã subscribe '$topicName' sẽ nhận được tin nhắn này\n";
    
} catch (Exception $e) {
    echo "❌ LỖI KHI GỬI ĐẾN TOPIC: " . $e->getMessage() . "\n";
}

echo "\n" . str_repeat("=", 60) . "\n";

// ===== QUẢN LÝ TOPIC SUBSCRIPTION =====

echo "QUẢN LÝ TOPIC SUBSCRIPTION:\n";
echo str_repeat("=", 60) . "\n";

// Ví dụ device tokens muốn subscribe/unsubscribe
$deviceTokens = [
    'cU3wOL67hQTl_K1MZ9dYAx:APA91bGJdDQ-rzLplWpDqz39-JSVrvewlQ8WWU0T6zR9BxAHfgQt8zGjoQQO4thFePXJTguimxEQeDp028OILI01DV2Y48vrhHJKAMq-FrBFdwjToTn-OSg',
    // 'token2_example_456...',
    // Thêm các token thực tế ở đây
];

// Subscribe thiết bị vào topic
try {
    echo "📱 Đăng ký thiết bị vào topic '$topicName'...\n";
    
    $subscriptionResult = $cloudMessaging->subscribeToTopic($topicName, $deviceTokens);
    
    echo "✅ Kết quả đăng ký topic:\n";
    foreach ($subscriptionResult as $topic => $results) {
        echo "📂 Topic: $topic\n";
        foreach ($results as $token => $result) {
            if (isset($result['error'])) {
                echo "  ❌ Token: " . substr($token, 0, 20) . "... - Lỗi: " . $result['error'] . "\n";
            } else {
                echo "  ✅ Token: " . substr($token, 0, 20) . "... - Thành công\n";
            }
        }
    }
    
} catch (Exception $e) {
    echo "❌ Lỗi khi đăng ký topic: " . $e->getMessage() . "\n";
}

echo "\n" . str_repeat("-", 40) . "\n";

// Unsubscribe thiết bị khỏi topic
try {
    echo "🚫 Hủy đăng ký thiết bị khỏi topic '$topicName'...\n";
    
    $unsubscriptionResult = $cloudMessaging->unsubscribeFromTopic($topicName, $deviceTokens);
    
    echo "✅ Kết quả hủy đăng ký topic:\n";
    foreach ($unsubscriptionResult as $topic => $results) {
        echo "📂 Topic: $topic\n";
        foreach ($results as $token => $result) {
            if (isset($result['error'])) {
                echo "  ❌ Token: " . substr($token, 0, 20) . "... - Lỗi: " . $result['error'] . "\n";
            } else {
                echo "  ✅ Token: " . substr($token, 0, 20) . "... - Đã hủy\n";
            }
        }
    }
    
} catch (Exception $e) {
    echo "❌ Lỗi khi hủy đăng ký topic: " . $e->getMessage() . "\n";
}

echo "\n" . str_repeat("=", 60) . "\n";
echo "HƯỚNG DẪN SỬ DỤNG TOPIC:\n";
echo str_repeat("=", 60) . "\n";
echo "1. 📱 CLIENT APP SUBSCRIBE VÀO TOPIC:\n";
echo "\n📱 Android:\n";
echo "FirebaseMessaging.getInstance().subscribeToTopic(\"$topicName\")\n";
echo "    .addOnCompleteListener(task -> {\n";
echo "        if (task.isSuccessful()) {\n";
echo "            Log.d(\"FCM\", \"Subscribed to $topicName\");\n";
echo "        }\n";
echo "    });\n\n";

echo "🍎 iOS:\n";
echo "Messaging.messaging().subscribe(toTopic: \"$topicName\") { error in\n";
echo "    if let error = error {\n";
echo "        print(\"Error subscribing to topic: \\(error)\")\n";
echo "    } else {\n";
echo "        print(\"Subscribed to $topicName topic\")\n";
echo "    }\n";
echo "}\n\n";

echo "🌐 Web:\n";
echo "// Topics không được hỗ trợ trực tiếp trên web\n";
echo "// Sử dụng device token thay thế\n\n";

echo "2. 💡 LỢI ÍCH CỦA TOPIC:\n";
echo "- Gửi tin nhắn đến nhiều thiết bị cùng lúc\n";
echo "- Không cần lưu trữ device tokens\n";
echo "- Thiết bị tự động subscribe/unsubscribe\n";
echo "- Phù hợp cho thông báo chung (alerts, news, updates)\n\n";

echo "3. 🎯 CÁC TOPIC SUGGESTION:\n";
echo "- 'monitoring_alerts' - Cảnh báo hệ thống\n";
echo "- 'device_status' - Trạng thái thiết bị\n";
echo "- 'maintenance_updates' - Thông báo bảo trì\n";
echo "- 'critical_alerts' - Cảnh báo khẩn cấp\n";

?>