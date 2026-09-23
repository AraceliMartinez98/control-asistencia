// Pantalla de comisiones: cargar selects (materias y docentes), listar, crear y eliminar.

export async function cargarMateriasSelect() {
  const response = await fetch("../../modelo/getMaterias.php");
  const materias = await response.json();

  const select = document.getElementById("selectMateria");
  select.innerHTML = '<option value="">-- Seleccionar --</option>';

  materias.forEach((materia) => {
    const option = document.createElement("option");
    option.value = materia.id_materia;
    option.textContent = `${materia.nombre} (${materia.nombre_carrera})`;
    select.appendChild(option);
  });
}

export async function cargarDocentesSelect() {
  const response = await fetch("../../modelo/getDocentes.php");
  const docentes = await response.json();

  const select = document.getElementById("selectDocente");
  select.innerHTML = '<option value="">-- Sin asignar --</option>';

  docentes.forEach((docente) => {
    const option = document.createElement("option");
    option.value = docente.id_usuario;
    option.textContent = `${docente.nombre} ${docente.apellido}`;
    select.appendChild(option);
  });
}

export async function cargarComisiones() {
  const response = await fetch("../../modelo/getComisiones.php");
  const comisiones = await response.json();

  const tbody = document.getElementById("tablaComisiones");
  tbody.innerHTML = "";

  if (comisiones.length === 0) {
    tbody.innerHTML = "<tr><td colspan='4'>Todavia no hay comisiones cargadas.</td></tr>";
    return;
  }

  comisiones.forEach((comision) => {
    const docente = comision.nombre_docente ?? "Sin asignar";
    const fila = document.createElement("tr");
    fila.innerHTML = `
      <td>${comision.nombre_materia}</td>
      <td>${comision.nombre}</td>
      <td>${docente}</td>
      <td><button onclick="eliminarComision(${comision.id_comision})">Eliminar</button></td>
    `;
    tbody.appendChild(fila);
  });
}

export async function handleCrearComision(event) {
  event.preventDefault();

  const nombre = document.getElementById("nombreComision").value;
  const idMateria = document.getElementById("selectMateria").value;
  const idDocente = document.getElementById("selectDocente").value;

  if (!nombre || !idMateria) {
    alert("Completa el nombre de la comision y la materia.");
    return;
  }

  await fetch("../../modelo/setComision.php", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ nombre, id_materia: idMateria, id_docente: idDocente }),
  });

  document.getElementById("formComision").reset();
  cargarComisiones();
}

export async function eliminarComision(id) {
  if (!confirm("¿Eliminar esta comision?")) return;

  await fetch(`../../modelo/deleteComision.php?id=${id}`);
  cargarComisiones();
}

window.eliminarComision = eliminarComision;
