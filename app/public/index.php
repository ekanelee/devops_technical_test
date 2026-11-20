<?php
declare(strict_types=1);

require __DIR__ . '/../vendor/autoload.php';

use App\Database;
use App\Health;

header('Content-Type: application/json');

$path = parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH);

if ($path === '/readyz') {
    // Readiness: can the app reach its database?
    try {
        $result = Health::check(Database::connect(getenv()));
        http_response_code(200);
    } catch (Throwable $e) {
        error_log('readyz failed: ' . $e->getMessage()); // goes to Cloud Logging
        $result = ['status' => 'not ready', 'database' => 'unreachable'];
        http_response_code(503);
    }
    echo json_encode($result);
    exit;
}

echo json_encode([
    'app'         => 'php-fpm-demo',
    'environment' => getenv('APP_ENV') ?: 'local',
    'php_version' => PHP_VERSION,
    'time'        => gmdate('c'),
]);