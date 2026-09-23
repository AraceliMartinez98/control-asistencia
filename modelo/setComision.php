<?php

include_once('conexion.php');

$datos = json_decode(file_get_contents("php://input"), true);

echo setComision($datos['nombre'], $datos['id_materia'], $datos['id_docente']);

function setComision($nombre, $idMateria, $idDocente)
{
    $mysqli = conexion();

    // si no eligieron docente, guardamos NULL (todavia no asignado)
    $idDocente = $idDocente === '' ? null : $idDocente;

    $query = "INSERT INTO comisiones (nombre, id_materia, id_docente) VALUES (?, ?, ?)";
    $stmt  = $mysqli->prepare($query);
    $stmt->bind_param("sii", $nombre, $idMateria, $idDocente);
    $stmt->execute();

    $mysqli->close();

    return json_encode(['ok' => true]);
}
