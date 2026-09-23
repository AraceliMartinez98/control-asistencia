<?php
// modelo/login.php
header('Content-Type: application/json');
require_once 'conexion.php';

$input = json_decode(file_get_contents('php://input'), true);

$email = $input['email'] ?? '';
$password = $input['password'] ?? '';

if (empty($email) || empty($password)) {
    echo json_encode(["status" => "error", "message" => "Por favor complete todos los campos"]);
    exit();
}

// Consulta de usuario (ejemplo adaptado a la tabla de usuarios)
$stmt = $conexion->prepare("SELECT id, nombre, apellido, rol, password FROM usuarios WHERE email = ? OR dni = ?");
$stmt->bind_param("ss", $email, $email);
$stmt->execute();
$result = $stmt->get_result();

if ($user = $result->fetch_assoc()) {
    // Si la contraseña coincide (verificación simple o hash)
    if ($password === $user['password'] || password_verify($password, $user['password'])) {
        echo json_encode([
            "status" => "success",
            "usuario" => [
                "id" => $user['id'],
                "nombre" => $user['nombre'] . ' ' . $user['apellido'],
                "rol" => $user['rol']
            ]
        ]);
        exit();
    }
}

echo json_encode(["status" => "error", "message" => "Credenciales inválidas"]);
?>