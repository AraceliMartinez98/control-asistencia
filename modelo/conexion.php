<?php

/* funcion que conecta a la base de datos */
function conexion()
{
    $host = "localhost";
    $db   = "control_asistencia"; /* nombre de la BD */
    $usr  = "root";
    $pass = ""; /* en XAMPP no tiene contraseña */

    $mysqli = new mysqli($host, $usr, $pass, $db);

    if ($mysqli->connect_errno) {
        die("Fallo la conexion: " . $mysqli->connect_errno);
    }

    $mysqli->set_charset("utf8mb4");

    return $mysqli;
}
