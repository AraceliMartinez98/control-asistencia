<?php

include_once('conexion.php');

echo getDocentes();

function getDocentes()
{
    $mysqli = conexion();

    $query = "SELECT id_usuario, nombre, apellido FROM usuarios WHERE rol = 'docente' ORDER BY apellido";
    $result = $mysqli->query($query);

    $docentes = array();
    while ($row = $result->fetch_assoc()) {
        $docentes[] = $row;
    }

    $mysqli->close();

    return json_encode($docentes);
}
