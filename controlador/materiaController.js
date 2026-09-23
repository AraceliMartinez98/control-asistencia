// Se ocupa de la pantalla de materias: cargar el listado, el select de carreras,
// crear una materia nueva y eliminar.

export async function cargarCarreras() {
  const response = await fetch("../../modelo/getCarreras.php");
  const carreras = await response.json();

  const select = document.getElementById("selectCarrera");
  select.innerHTML = '<option value="">-- Seleccionar --</option>';

  carreras.forEach((carrera) => {
    const option = document.createElement("option");
    option.value = carrera.id_carrera;
    option.textContent = carrera.nombre;
    select.appendChild(option);
  });
}

export async function cargarMaterias() {
  const response = await fetch("../../modelo/getMaterias.php");
  const materias = await response.json();

  const tbody = document.getElementById("tablaMaterias");
  tbody.innerHTML = "";

  if (materias.length === 0) {
    tbody.innerHTML = "<tr><td colspan='3'>Todavia no hay materias cargadas.</td></tr>";
    return;
  }

  materias.forEach((materia) => {
    const fila = document.createElement("tr");
    fila.innerHTML = `
      <td>${materia.nombre}</td>
      <td>${materia.nombre_carrera}</td>
      <td><button onclick="eliminarMateria(${materia.id_materia})">Eliminar</button></td>
    `;
    tbody.appendChild(fila);
  });
}

export async function handleCrearMateria(event) {
  event.preventDefault();

  const nombre = document.getElementById("nombreMateria").value;
  const idCarrera = document.getElementById("selectCarrera").value;

  if (!nombre || !idCarrera) {
    alert("Completa el nombre y la carrera.");
    return;
  }

  await fetch("../../modelo/setMateria.php", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ nombre, id_carrera: idCarrera }),
  });

  document.getElementById("formMateria").reset();
  cargarMaterias();
}

export async function eliminarMateria(id) {
  if (!confirm("¿Eliminar esta materia?")) return;

  await fetch(`../../modelo/deleteMateria.php?id=${id}`);
  cargarMaterias();
}

// hace falta colgarla del window para que el onclick del HTML la encuentre
window.eliminarMateria = eliminarMateria;
