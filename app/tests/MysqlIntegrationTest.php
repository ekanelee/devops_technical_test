<?php
declare(strict_types=1);

namespace Tests;

use App\Database;
use App\Health;
use PHPUnit\Framework\TestCase;

final class MysqlIntegrationTest extends TestCase
{
    protected function setUp(): void
    {
        if (getenv('DB_HOST') === false) {
            $this->markTestSkipped('DB_HOST not set: no MySQL available.');
        }
    }

    public function testRealMysqlAnswersTheHealthQuery(): void
    {
        $result = Health::check(Database::connect(getenv()));

        $this->assertSame('ready', $result['status']);
    }
}