<?php

include_once('conexion.php');

$datos = json_decode(file_get_contents("php://input"), true);

echo setMateria($datos['nombre'], $datos['id_carrera']);

function setMateria($nombre, $idCarrera)
{
    $mysqli = conexion();

    $query = "INSERT INTO materias (nombre, id_carrera) VALUES (?, ?)";
    $stmt  = $mysqli->prepare($query);
    $stmt->bind_param("si", $nombre, $idCarrera);
    $stmt->execute();

    $mysqli->close();

    return json_encode(['ok' => true]);
}
