<?php
declare(strict_types=1);

namespace App;

use PDO;

final class Database
{
    /** Builds the MySQL DSN: unix socket on Cloud Run, TCP host locally. */
    public static function dsn(array $env): string
    {
        $target = !empty($env['DB_SOCKET'])
            ? 'unix_socket=' . $env['DB_SOCKET']
            : 'host=' . ($env['DB_HOST'] ?? '127.0.0.1');

        return sprintf('mysql:%s;dbname=%s;charset=utf8mb4', $target, $env['DB_NAME'] ?? '');
    }

    public static function connect(array $env): PDO
    {
        return new PDO(self::dsn($env), $env['DB_USER'] ?? '', $env['DB_PASS'] ?? '', [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_TIMEOUT => 3,
        ]);
    }
}