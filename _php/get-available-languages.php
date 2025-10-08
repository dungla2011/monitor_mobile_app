<?php
/**
 * API to get available languages
 * Endpoint: /api/get-available-languages
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

// Database connection (adjust credentials)
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

    // Query available languages
    $stmt = $pdo->query("
        SELECT 
            code,
            name,
            native_name,
            is_active,
            flag_code,
            last_updated
        FROM languages
        WHERE is_active = 1
        ORDER BY display_order ASC, code ASC
    ");

    $languages = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        'code' => 1,
        'payload' => $languages,
        'message' => 'Languages retrieved successfully',
    ]);

} catch (Exception $e) {
    error_log("Error: " . $e->getMessage());
    echo json_encode([
        'code' => 0,
        'payload' => null,
        'message' => 'Error retrieving languages: ' . $e->getMessage(),
    ]);
}
