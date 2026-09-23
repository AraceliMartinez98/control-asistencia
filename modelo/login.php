<?php

include_once('conexion.php');

/* lee lo que manda el JS por POST */
$datos = json_decode(file_get_contents("php://input"), true);
$email    = $datos['email'] ?? '';
$password = $datos['password'] ?? '';

echo login($email, $password);

function login($email, $password)
{
    $mysqli = conexion();

    $query = "SELECT * FROM usuarios WHERE email = ?";
    $stmt  = $mysqli->prepare($query);
    $stmt->bind_param("s", $email);
    $stmt->execute();

    $result  = $stmt->get_result();
    $usuario = $result->fetch_assoc();

    $mysqli->close();

    if (!$usuario) {
        return json_encode(['ok' => false, 'mensaje' => 'Email o password incorrectos']);
    }

    if (!password_verify($password, $usuario['password'])) {
        return json_encode(['ok' => false, 'mensaje' => 'Email o password incorrectos']);
    }

    /* no mandamos el password de vuelta al navegador */
    unset($usuario['password']);

    return json_encode(['ok' => true, 'usuario' => $usuario]);
}
