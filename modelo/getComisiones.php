<?php

include_once('conexion.php');

echo getComisiones();

function getComisiones()
{
    $mysqli = conexion();

    $query = "SELECT co.id_comision, co.nombre,
                     m.nombre AS nombre_materia,
                     CONCAT(d.nombre, ' ', d.apellido) AS nombre_docente
              FROM comisiones co
              INNER JOIN materias m ON co.id_materia = m.id_materia
              LEFT JOIN usuarios d ON co.id_docente = d.id_usuario
              ORDER BY m.nombre, co.nombre";
    $result = $mysqli->query($query);

    $comisiones = array();
    while ($row = $result->fetch_assoc()) {
        $comisiones[] = $row;
    }

    $mysqli->close();

    return json_encode($comisiones);
}
