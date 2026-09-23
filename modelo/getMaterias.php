<?php

include_once('conexion.php');

echo getMaterias();

function getMaterias()
{
    $mysqli = conexion();

    $query = "SELECT m.id_materia, m.nombre, c.nombre AS nombre_carrera
              FROM materias m
              INNER JOIN carrera c ON m.id_carrera = c.id_carrera
              ORDER BY c.nombre, m.nombre";
    $result = $mysqli->query($query);

    $materias = array();
    while ($row = $result->fetch_assoc()) {
        $materias[] = $row;
    }

    $mysqli->close();

    return json_encode($materias);
}
