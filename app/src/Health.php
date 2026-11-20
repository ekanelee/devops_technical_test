<?php
declare(strict_types=1);

namespace App;

use PDO;

final class Health
{
    /**
     * Runs a trivial query. Throws if the database is unreachable,
     * so the caller decides how to log and which HTTP status to return.
     *
     * @return array{status: string, database: string}
     */
    public static function check(PDO $pdo): array
    {
        $pdo->query('SELECT 1');

        return ['status' => 'ready', 'database' => 'ok'];
    }
}