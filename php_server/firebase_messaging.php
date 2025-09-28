<?php
/**
 * Firebase Cloud Messaging (FCM) PHP Script
 * Gửi push notification từ web server về Flutter app
 */

class FirebaseMessaging {
    private $serverKey;
    private $fcmUrl = 'https://fcm.googleapis.com/fcm/send';
    
    public function __construct($serverKey) {
        $this->serverKey = $serverKey;
    }
    
    /**
     * Gửi notification đến một device cụ thể bằng FCM token
     */
    public function sendToDevice($fcmToken, $title, $body, $data = []) {
        $notification = [
            'title' => $title,
            'body' => $body,
            'sound' => 'default',
            'badge' => 1,
        ];
        
        $payload = [
            'to' => $fcmToken,
            'notification' => $notification,
            'data' => $data,
            'priority' => 'high',
            'content_available' => true,
        ];
        
        return $this->sendRequest($payload);
    }
    
    /**
     * Gửi notification đến tất cả devices đăng ký một topic
     */
    public function sendToTopic($topic, $title, $body, $data = []) {
        $notification = [
            'title' => $title,
            'body' => $body,
            'sound' => 'default',
            'badge' => 1,
        ];
        
        $payload = [
            'to' => '/topics/' . $topic,
            'notification' => $notification,
            'data' => $data,
            'priority' => 'high',
            'content_available' => true,
        ];
        
        return $this->sendRequest($payload);
    }
    
    /**
     * Gửi notification đến nhiều devices
     */
    public function sendToMultipleDevices($fcmTokens, $title, $body, $data = []) {
        $notification = [
            'title' => $title,
            'body' => $body,
            'sound' => 'default',
            'badge' => 1,
        ];
        
        $payload = [
            'registration_ids' => $fcmTokens,
            'notification' => $notification,
            'data' => $data,
            'priority' => 'high',
            'content_available' => true,
        ];
        
        return $this->sendRequest($payload);
    }
    
    /**
     * Gửi data-only message (không hiển thị notification)
     */
    public function sendDataOnly($fcmToken, $data) {
        $payload = [
            'to' => $fcmToken,
            'data' => $data,
            'priority' => 'high',
            'content_available' => true,
        ];
        
        return $this->sendRequest($payload);
    }
    
    /**
     * Gửi request đến FCM server
     */
    private function sendRequest($payload) {
        $headers = [
            'Authorization: key=' . $this->serverKey,
            'Content-Type: application/json',
        ];
        
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $this->fcmUrl);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
        
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        
        return [
            'success' => $httpCode == 200,
            'http_code' => $httpCode,
            'response' => json_decode($response, true),
            'raw_response' => $response
        ];
    }
}

// =============================================================================
// CONFIGURATION - THAY ĐỔI CÁC GIÁ TRỊ DƯỚI ĐÂY
// =============================================================================

// Lấy Server Key từ Firebase Console > Project Settings > Cloud Messaging
$SERVER_KEY = 'YOUR_SERVER_KEY_HERE';

// FCM Token của device (lấy từ app Flutter)
$FCM_TOKEN = 'YOUR_FCM_TOKEN_HERE';

// =============================================================================
// EXAMPLES - CÁC VÍ DỤ SỬ DỤNG
// =============================================================================

// Khởi tạo Firebase Messaging
$fcm = new FirebaseMessaging($SERVER_KEY);

// Ví dụ 1: Gửi notification đến một device cụ thể
function sendToDevice($fcm, $fcmToken) {
    $result = $fcm->sendToDevice(
        $fcmToken,
        'Tiêu đề thông báo',
        'Nội dung thông báo từ PHP server',
        [
            'action' => 'open_screen',
            'screen' => 'home',
            'extra_data' => 'custom_value'
        ]
    );
    
    return $result;
}

// Ví dụ 2: Gửi notification đến topic
function sendToTopic($fcm, $topic) {
    $result = $fcm->sendToTopic(
        $topic,
        'Thông báo từ Topic',
        'Tin nhắn gửi đến tất cả users đăng ký topic: ' . $topic,
        [
            'topic' => $topic,
            'timestamp' => time()
        ]
    );
    
    return $result;
}

// Ví dụ 3: Gửi data-only message
function sendDataOnly($fcm, $fcmToken) {
    $result = $fcm->sendDataOnly(
        $fcmToken,
        [
            'message_type' => 'sync_data',
            'user_id' => '123',
            'action' => 'refresh',
            'timestamp' => time()
        ]
    );
    
    return $result;
}

// =============================================================================
// API ENDPOINTS - SỬ DỤNG VIA HTTP REQUESTS
// =============================================================================

// Xử lý request từ browser hoặc AJAX
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $input = file_get_contents('php://input');
    $data = json_decode($input, true);
    
    header('Content-Type: application/json');
    
    if (!$data) {
        echo json_encode(['error' => 'Invalid JSON']);
        exit;
    }
    
    $action = $data['action'] ?? '';
    $response = ['success' => false];
    
    switch ($action) {
        case 'send_to_device':
            $token = $data['token'] ?? '';
            $title = $data['title'] ?? 'Test Notification';
            $body = $data['body'] ?? 'Test message from PHP';
            $customData = $data['data'] ?? [];
            
            if ($token) {
                $result = $fcm->sendToDevice($token, $title, $body, $customData);
                $response = $result;
            } else {
                $response['error'] = 'Token is required';
            }
            break;
            
        case 'send_to_topic':
            $topic = $data['topic'] ?? 'general';
            $title = $data['title'] ?? 'Topic Notification';
            $body = $data['body'] ?? 'Message to topic: ' . $topic;
            $customData = $data['data'] ?? [];
            
            $result = $fcm->sendToTopic($topic, $title, $body, $customData);
            $response = $result;
            break;
            
        case 'send_data_only':
            $token = $data['token'] ?? '';
            $customData = $data['data'] ?? [];
            
            if ($token) {
                $result = $fcm->sendDataOnly($token, $customData);
                $response = $result;
            } else {
                $response['error'] = 'Token is required';
            }
            break;
            
        default:
            $response['error'] = 'Invalid action';
    }
    
    echo json_encode($response);
    exit;
}

// =============================================================================
// TEST INTERFACE - GIAO DIỆN TEST ĐƠN GIẢN
// =============================================================================

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    ?>
    <!DOCTYPE html>
    <html>
    <head>
        <title>Firebase Messaging Test</title>
        <meta charset="utf-8">
        <style>
            body { font-family: Arial, sans-serif; margin: 20px; }
            .container { max-width: 800px; margin: 0 auto; }
            .form-group { margin-bottom: 15px; }
            label { display: block; margin-bottom: 5px; font-weight: bold; }
            input, textarea, select { width: 100%; padding: 8px; margin-bottom: 10px; }
            button { background: #007cba; color: white; padding: 10px 20px; border: none; cursor: pointer; margin-right: 10px; }
            button:hover { background: #005a87; }
            .result { margin-top: 20px; padding: 10px; background: #f5f5f5; border-left: 4px solid #007cba; }
            .error { border-left-color: #d32f2f; background: #ffebee; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>Firebase Cloud Messaging Test</h1>
            
            <div class="form-group">
                <label>Server Key:</label>
                <input type="text" id="serverKey" placeholder="Nhập Server Key từ Firebase Console" value="<?php echo $SERVER_KEY; ?>">
            </div>
            
            <div class="form-group">
                <label>FCM Token:</label>
                <textarea id="fcmToken" placeholder="Nhập FCM Token từ Flutter app" rows="3"><?php echo $FCM_TOKEN; ?></textarea>
            </div>
            
            <div class="form-group">
                <label>Action:</label>
                <select id="action">
                    <option value="send_to_device">Send to Device</option>
                    <option value="send_to_topic">Send to Topic</option>
                    <option value="send_data_only">Send Data Only</option>
                </select>
            </div>
            
            <div class="form-group">
                <label>Title:</label>
                <input type="text" id="title" value="Test từ PHP Server">
            </div>
            
            <div class="form-group">
                <label>Body:</label>
                <textarea id="body" rows="2">Đây là tin nhắn test từ PHP web server</textarea>
            </div>
            
            <div class="form-group">
                <label>Topic (for topic messages):</label>
                <input type="text" id="topic" value="general">
            </div>
            
            <div class="form-group">
                <label>Custom Data (JSON):</label>
                <textarea id="customData" rows="3">{"action": "test", "timestamp": "<?php echo time(); ?>"}</textarea>
            </div>
            
            <button onclick="sendNotification()">Gửi Notification</button>
            <button onclick="clearResult()">Clear Result</button>
            
            <div id="result"></div>
        </div>
        
        <script>
            function sendNotification() {
                const data = {
                    action: document.getElementById('action').value,
                    token: document.getElementById('fcmToken').value,
                    title: document.getElementById('title').value,
                    body: document.getElementById('body').value,
                    topic: document.getElementById('topic').value,
                    data: {}
                };
                
                try {
                    data.data = JSON.parse(document.getElementById('customData').value);
                } catch (e) {
                    alert('Custom Data phải là JSON hợp lệ');
                    return;
                }
                
                fetch('', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify(data)
                })
                .then(response => response.json())
                .then(result => {
                    displayResult(result);
                })
                .catch(error => {
                    displayResult({error: error.message}, true);
                });
            }
            
            function displayResult(result, isError = false) {
                const resultDiv = document.getElementById('result');
                const className = isError || result.error ? 'result error' : 'result';
                resultDiv.className = className;
                resultDiv.innerHTML = '<h3>Kết quả:</h3><pre>' + JSON.stringify(result, null, 2) + '</pre>';
            }
            
            function clearResult() {
                document.getElementById('result').innerHTML = '';
            }
        </script>
    </body>
    </html>
    <?php
}
?>