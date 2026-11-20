<?php
declare(strict_types=1);

header('Content-Type: application/json');

// Connect via the Cloud SQL unix socket on Cloud Run (DB_SOCKET),
// or over TCP when running locally (DB_HOST).
function pdo(): PDO
{
    $socket = getenv('DB_SOCKET');
    $target = $socket ? 'unix_socket=' . $socket : 'host=' . (getenv('DB_HOST') ?: '127.0.0.1');
    $dsn    = sprintf('mysql:%s;dbname=%s;charset=utf8mb4', $target, getenv('DB_NAME'));

    return new PDO($dsn, (string) getenv('DB_USER'), (string) getenv('DB_PASS'), [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_TIMEOUT => 3,
    ]);
}

$path = parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH);

if ($path === '/readyz') {
    // Readiness: can the app reach its database?
    try {
        pdo()->query('SELECT 1');
        echo json_encode(['status' => 'ready', 'database' => 'ok']);
    } catch (Throwable $e) {
        http_response_code(503);
        error_log('readyz failed: ' . $e->getMessage()); // goes to Cloud Logging
        echo json_encode(['status' => 'not ready', 'database' => 'unreachable']);
    }
    exit;
}

echo json_encode([
    'app'         => 'php-fpm-demo',
    'environment' => getenv('APP_ENV') ?: 'local',
    'php_version' => PHP_VERSION,
    'time'        => gmdate('c'),
]);