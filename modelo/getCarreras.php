<?php

include_once('conexion.php');

echo getCarreras();

function getCarreras()
{
    $mysqli = conexion();

    $query  = "SELECT id_carrera, nombre FROM carrera ORDER BY nombre";
    $result = $mysqli->query($query);

    $carreras = array();
    while ($row = $result->fetch_assoc()) {
        $carreras[] = $row;
    }

    $mysqli->close();

    return json_encode($carreras);
}
