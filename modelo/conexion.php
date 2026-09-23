<?php
// modelo/conexion.php
$host = "localhost";
$user = "root";
$password = "";
$database = "control_asistencia";
$port = 3306; // Puerto estándar de MySQL en XAMPP

$conexion = new mysqli($host, $user, $password, $database, $port);

if ($conexion->connect_error) {
    header('Content-Type: application/json');
    echo json_encode(["status" => "error", "message" => "Error de conexión a la BD: " . $conexion->connect_error]);
    exit();
}

$conexion->set_charset("utf8mb4");
?>