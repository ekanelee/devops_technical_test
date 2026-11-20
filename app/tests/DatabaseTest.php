<?php
declare(strict_types=1);

namespace Tests;

use App\Database;
use PHPUnit\Framework\TestCase;

final class DatabaseTest extends TestCase
{
    public function testDsnUsesUnixSocketWhenProvided(): void
    {
        $dsn = Database::dsn(['DB_SOCKET' => '/cloudsql/p:r:i', 'DB_NAME' => 'app']);

        $this->assertSame('mysql:unix_socket=/cloudsql/p:r:i;dbname=app;charset=utf8mb4', $dsn);
    }

    public function testDsnUsesHostWhenNoSocket(): void
    {
        $dsn = Database::dsn(['DB_HOST' => 'db', 'DB_NAME' => 'app']);

        $this->assertSame('mysql:host=db;dbname=app;charset=utf8mb4', $dsn);
    }

    public function testDsnDefaultsToLocalhost(): void
    {
        $this->assertStringContainsString('host=127.0.0.1', Database::dsn(['DB_NAME' => 'app']));
    }
}