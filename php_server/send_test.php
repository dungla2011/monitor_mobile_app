<?php
/**
 * Simple Firebase Messaging Test Script
 * Sử dụng cho việc test nhanh gửi notification
 */

// CONFIGURATION
$SERVER_KEY = 'YOUR_SERVER_KEY_HERE'; // Thay bằng Server Key từ Firebase Console
$FCM_TOKEN = 'YOUR_FCM_TOKEN_HERE';   // Thay bằng FCM Token từ Flutter app

/**
 * Gửi notification đơn giản
 */
function sendSimpleNotification($serverKey, $fcmToken, $title, $body) {
    $url = 'https://fcm.googleapis.com/fcm/send';
    
    $data = [
        'to' => $fcmToken,
        'notification' => [
            'title' => $title,
            'body' => $body,
            'sound' => 'default'
        ],
        'data' => [
            'sent_time' => date('Y-m-d H:i:s'),
            'source' => 'php_server'
        ]
    ];
    
    $headers = [
        'Authorization: key=' . $serverKey,
        'Content-Type: application/json'
    ];
    
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
    
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    return [
        'success' => $httpCode == 200,
        'http_code' => $httpCode,
        'response' => json_decode($response, true)
    ];
}

/**
 * Gửi đến topic
 */
function sendToTopic($serverKey, $topic, $title, $body) {
    $url = 'https://fcm.googleapis.com/fcm/send';
    
    $data = [
        'to' => '/topics/' . $topic,
        'notification' => [
            'title' => $title,
            'body' => $body,
            'sound' => 'default'
        ],
        'data' => [
            'sent_time' => date('Y-m-d H:i:s'),
            'topic' => $topic,
            'source' => 'php_server'
        ]
    ];
    
    $headers = [
        'Authorization: key=' . $serverKey,
        'Content-Type: application/json'
    ];
    
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
    
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    return [
        'success' => $httpCode == 200,
        'http_code' => $httpCode,
        'response' => json_decode($response, true)
    ];
}

// TEST CASES
echo "=== Firebase Messaging Test ===\n\n";

// Test 1: Gửi đến device cụ thể
if ($FCM_TOKEN !== 'YOUR_FCM_TOKEN_HERE' && $SERVER_KEY !== 'YOUR_SERVER_KEY_HERE') {
    echo "Test 1: Gửi đến device...\n";
    $result = sendSimpleNotification(
        $SERVER_KEY,
        $FCM_TOKEN,
        'Test từ PHP',
        'Đây là tin nhắn test từ PHP server - ' . date('H:i:s')
    );
    
    if ($result['success']) {
        echo "✅ Gửi thành công!\n";
        echo "Response: " . json_encode($result['response']) . "\n\n";
    } else {
        echo "❌ Gửi thất bại! HTTP Code: " . $result['http_code'] . "\n";
        echo "Response: " . json_encode($result['response']) . "\n\n";
    }
    
    // Test 2: Gửi đến topic
    echo "Test 2: Gửi đến topic 'general'...\n";
    $result = sendToTopic(
        $SERVER_KEY,
        'general',
        'Topic Notification',
        'Tin nhắn gửi đến topic general - ' . date('H:i:s')
    );
    
    if ($result['success']) {
        echo "✅ Gửi topic thành công!\n";
        echo "Response: " . json_encode($result['response']) . "\n\n";
    } else {
        echo "❌ Gửi topic thất bại! HTTP Code: " . $result['http_code'] . "\n";
        echo "Response: " . json_encode($result['response']) . "\n\n";
    }
} else {
    echo "⚠️  Vui lòng cấu hình SERVER_KEY và FCM_TOKEN trước khi test!\n";
    echo "1. Lấy Server Key từ: Firebase Console > Project Settings > Cloud Messaging\n";
    echo "2. Lấy FCM Token từ Flutter app (hiển thị trong màn hình Thông báo)\n";
    echo "3. Thay thế các giá trị YOUR_SERVER_KEY_HERE và YOUR_FCM_TOKEN_HERE\n\n";
}

echo "=== Hướng dẫn sử dụng ===\n";
echo "1. Chạy script này để test: php send_test.php\n";
echo "2. Hoặc gọi từ web browser\n";
echo "3. Hoặc sử dụng CURL:\n";
echo "   curl -X POST http://your-domain.com/send_test.php\n\n";

// Nếu được gọi từ web browser
if (isset($_SERVER['HTTP_HOST'])) {
    echo "<pre>";
    echo "Web interface: Mở file firebase_messaging.php để có giao diện đầy đủ\n";
    echo "</pre>";
}
?>