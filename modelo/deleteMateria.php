<?php

include_once('conexion.php');

$id = $_GET['id'] ?? null;

echo deleteMateria($id);

function deleteMateria($id)
{
    $mysqli = conexion();

    $query = "DELETE FROM materias WHERE id_materia = ?";
    $stmt  = $mysqli->prepare($query);
    $stmt->bind_param("i", $id);
    $stmt->execute();

    $mysqli->close();

    return json_encode(['ok' => true]);
}
