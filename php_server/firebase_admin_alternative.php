<?php
/**
 * Firebase Admin SDK Alternative
 * Sử dụng khi không lấy được Server Key (Legacy API)
 * Yêu cầu: composer install google/firebase
 */

// Uncomment dòng dưới nếu sử dụng Composer
// require_once 'vendor/autoload.php';

/**
 * Alternative method using HTTP API với Access Token
 * Không cần Server Key legacy
 */
class FirebaseAdminMessaging {
    private $projectId;
    private $serviceAccountPath;
    private $accessToken;
    
    public function __construct($projectId, $serviceAccountPath = null) {
        $this->projectId = $projectId;
        $this->serviceAccountPath = $serviceAccountPath;
    }
    
    /**
     * Lấy access token từ service account
     */
    private function getAccessToken() {
        if (!$this->serviceAccountPath || !file_exists($this->serviceAccountPath)) {
            throw new Exception('Service account file not found');
        }
        
        $serviceAccount = json_decode(file_get_contents($this->serviceAccountPath), true);
        
        // Tạo JWT
        $header = json_encode(['typ' => 'JWT', 'alg' => 'RS256']);
        $now = time();
        $payload = json_encode([
            'iss' => $serviceAccount['client_email'],
            'scope' => 'https://www.googleapis.com/auth/firebase.messaging',
            'aud' => 'https://oauth2.googleapis.com/token',
            'exp' => $now + 3600,
            'iat' => $now
        ]);
        
        $base64Header = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($header));
        $base64Payload = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($payload));
        
        $signature = '';
        openssl_sign($base64Header . "." . $base64Payload, $signature, $serviceAccount['private_key'], 'SHA256');
        $base64Signature = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($signature));
        
        $jwt = $base64Header . "." . $base64Payload . "." . $base64Signature;
        
        // Lấy access token
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, 'https://oauth2.googleapis.com/token');
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query([
            'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
            'assertion' => $jwt
        ]));
        
        $response = curl_exec($ch);
        curl_close($ch);
        
        $tokenData = json_decode($response, true);
        return $tokenData['access_token'] ?? null;
    }
    
    /**
     * Gửi notification sử dụng Firebase Admin API
     */
    public function sendMessage($message) {
        if (!$this->accessToken) {
            $this->accessToken = $this->getAccessToken();
        }
        
        $url = "https://fcm.googleapis.com/v1/projects/{$this->projectId}/messages:send";
        
        $headers = [
            'Authorization: Bearer ' . $this->accessToken,
            'Content-Type: application/json'
        ];
        
        $data = ['message' => $message];
        
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
     * Helper: Gửi đến device
     */
    public function sendToDevice($fcmToken, $title, $body, $data = []) {
        $message = [
            'token' => $fcmToken,
            'notification' => [
                'title' => $title,
                'body' => $body
            ],
            'data' => $data
        ];
        
        return $this->sendMessage($message);
    }
    
    /**
     * Helper: Gửi đến topic
     */
    public function sendToTopic($topic, $title, $body, $data = []) {
        $message = [
            'topic' => $topic,
            'notification' => [
                'title' => $title,
                'body' => $body
            ],
            'data' => $data
        ];
        
        return $this->sendMessage($message);
    }
}

/**
 * SIMPLE HTTP API Alternative (Không cần service account)
 * Sử dụng Firebase REST API trực tiếp
 */
class SimpleFirebaseMessaging {
    
    /**
     * Gửi notification sử dụng công khai API
     * LưU ý: Cách này có giới hạn và không khuyên dùng cho production
     */
    public static function sendSimple($fcmToken, $title, $body) {
        // Sử dụng Firebase Cloud Functions hoặc public API endpoint
        // Bạn cần tạo một Cloud Function để handle việc này
        
        echo "Để sử dụng không có Server Key, bạn cần:\n";
        echo "1. Tạo Firebase Cloud Function\n";
        echo "2. Hoặc sử dụng Firebase Admin SDK với Service Account\n";
        echo "3. Hoặc tìm cách enable Legacy Server Key\n\n";
        
        return false;
    }
}

// =============================================================================
// CONFIGURATION
// =============================================================================

$PROJECT_ID = 'your-firebase-project-id';
$SERVICE_ACCOUNT_PATH = 'path/to/service-account.json'; // Download từ Firebase Console
$FCM_TOKEN = 'your-fcm-token';

// =============================================================================
// USAGE EXAMPLES
// =============================================================================

echo "=== Firebase Admin SDK Alternative ===\n\n";

try {
    // Sử dụng Admin SDK
    $admin = new FirebaseAdminMessaging($PROJECT_ID, $SERVICE_ACCOUNT_PATH);
    
    $result = $admin->sendToDevice(
        $FCM_TOKEN,
        'Test từ Admin SDK',
        'Tin nhắn gửi bằng Firebase Admin SDK'
    );
    
    if ($result['success']) {
        echo "✅ Gửi thành công bằng Admin SDK!\n";
    } else {
        echo "❌ Lỗi: " . json_encode($result) . "\n";
    }
    
} catch (Exception $e) {
    echo "⚠️  Lỗi: " . $e->getMessage() . "\n\n";
    
    echo "Hướng dẫn setup:\n";
    echo "1. Vào Firebase Console → Project Settings → Service Accounts\n";
    echo "2. Click 'Generate new private key'\n";
    echo "3. Download file JSON và đặt đường dẫn vào SERVICE_ACCOUNT_PATH\n";
    echo "4. Cài đặt: composer require google/firebase\n\n";
}

echo "=== Alternative Solutions ===\n";
echo "Nếu không lấy được Server Key, bạn có thể:\n\n";
echo "1. **Enable Legacy API:**\n";
echo "   - Vào Firebase Console\n";
echo "   - Project Settings → Cloud Messaging\n";
echo "   - Tìm 'Cloud Messaging API (Legacy)'\n";
echo "   - Click Enable nếu có\n\n";

echo "2. **Sử dụng Admin SDK:**\n";
echo "   - Download Service Account key\n";
echo "   - Sử dụng script này\n";
echo "   - Hoặc install: composer require google/firebase\n\n";

echo "3. **Tạo Cloud Function:**\n";
echo "   - Tạo HTTP Cloud Function\n";
echo "   - Gọi từ PHP thông qua HTTP request\n";
echo "   - Function sẽ gửi notification\n\n";

echo "4. **Sử dụng Firebase Console trực tiếp:**\n";
echo "   - Vào Messaging trong Firebase Console\n";
echo "   - Tạo campaign và test\n";
echo "   - Copy format message để dùng trong code\n\n";
?>