<?php
// modelo/login.php
error_reporting(0);
ini_set('display_errors', 0);
header('Content-Type: application/json; charset=utf-8');

require_once 'conexion.php';

$input = json_decode(file_get_contents('php://input'), true);

$email = $input['email'] ?? '';
$password = $input['password'] ?? '';

if (empty($email) || empty($password)) {
    echo json_encode(["status" => "error", "message" => "Por favor complete todos los campos"]);
    exit();
}

try {
    if (!$conexion || $conexion->connect_error) {
        echo json_encode(["status" => "error", "message" => "Error de conexión a la base de datos"]);
        exit();
    }

    // Se cambió 'id' por 'id_usuario' para coincidir con la estructura SQL
    $stmt = $conexion->prepare("SELECT id_usuario, nombre, apellido, rol, password FROM usuarios WHERE email = ?");
    
    if (!$stmt) {
        echo json_encode(["status" => "error", "message" => "Error en la consulta SQL"]);
        exit();
    }

    $stmt->bind_param("s", $email);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($user = $result->fetch_assoc()) {
        // Verifica la contraseña ingresada
        if ($password === $user['password'] || password_verify($password, $user['password'])) {
            echo json_encode([
                "status" => "success",
                "usuario" => [
                    "id" => $user['id_usuario'],
                    "nombre" => $user['nombre'] . ' ' . $user['apellido'],
                    "rol" => $user['rol']
                ]
            ]);
            exit();
        }
    }

    echo json_encode(["status" => "error", "message" => "Usuario o contraseña incorrectos"]);

} catch (Exception $e) {
    echo json_encode(["status" => "error", "message" => "Excepción del servidor: " . $e->getMessage()]);
}
?>