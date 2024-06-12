<?php
// Database connection parameters
$host = 'mariadb:3306';
$db   = 'personas';
$user = 'root';
$pass = 'root';
$charset = 'utf8mb4';

$dsn = "mysql:host=$host;dbname=$db;charset=$charset";

$pdo = new PDO($dsn, $user, $pass);

$sql = "SELECT * FROM personas";

$stmt = $pdo->query($sql);

$answer = $stmt->fetchAll();

foreach ($answer as $row) {
    echo $row['name'] . "\n" . $row['email'] . "\n";
}