<?php
declare(strict_types=1);

namespace Tests;

use App\Health;
use PDO;
use PDOException;
use PHPUnit\Framework\TestCase;

final class HealthTest extends TestCase
{
    public function testCheckReportsReadyWhenQuerySucceeds(): void
    {
        $pdo = new PDO('sqlite::memory:'); // in-memory database, no server needed

        $this->assertSame(['status' => 'ready', 'database' => 'ok'], Health::check($pdo));
    }

    public function testCheckPropagatesDatabaseFailure(): void
    {
        $pdo = $this->createStub(PDO::class);
        $pdo->method('query')->willThrowException(new PDOException('boom'));

        $this->expectException(PDOException::class);
        Health::check($pdo);
    }
}