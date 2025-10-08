<?php
/**
 * API to get language translations
 * Endpoint: /api/get-language
 * Method: POST
 * Body: { "language_code": "vi", "format": "arb" }
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Handle preflight
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Get request data
$input = json_decode(file_get_contents('php://input'), true);
$languageCode = $input['language_code'] ?? 'en';
$format = $input['format'] ?? 'arb';

// Database connection
function getDBConnection() {
    $host = 'localhost';
    $dbname = 'monitor_db';
    $username = 'root';
    $password = '';
    
    try {
        $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        return $pdo;
    } catch (PDOException $e) {
        error_log("DB Connection Error: " . $e->getMessage());
        return null;
    }
}

try {
    $pdo = getDBConnection();
    if (!$pdo) {
        throw new Exception("Database connection failed");
    }

    // Query translations for the language
    $stmt = $pdo->prepare("
        SELECT 
            translation_key,
            translation_value
        FROM translations
        WHERE language_code = :language_code
        AND is_active = 1
    ");
    
    $stmt->execute(['language_code' => $languageCode]);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Convert to key-value map
    $translations = [];
    foreach ($rows as $row) {
        $translations[$row['translation_key']] = $row['translation_value'];
    }

    // If no translations found in DB, try to load from ARB file as fallback
    if (empty($translations)) {
        $arbFile = __DIR__ . "/../lib/l10n/app_{$languageCode}.arb";
        if (file_exists($arbFile)) {
            $arbContent = file_get_contents($arbFile);
            $arbData = json_decode($arbContent, true);
            
            // Filter out metadata keys (starting with @)
            foreach ($arbData as $key => $value) {
                if (substr($key, 0, 1) !== '@' && is_string($value)) {
                    $translations[$key] = $value;
                }
            }
        }
    }

    echo json_encode([
        'code' => 1,
        'payload' => $translations,
        'message' => 'Translations retrieved successfully',
        'count' => count($translations),
    ]);

} catch (Exception $e) {
    error_log("Error: " . $e->getMessage());
    echo json_encode([
        'code' => 0,
        'payload' => null,
        'message' => 'Error retrieving translations: ' . $e->getMessage(),
    ]);
}
