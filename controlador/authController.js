// Se ocupa de mandar el login al modelo y redirigir segun el rol

export async function handleLogin() {
  const email = document.getElementById("loginEmail").value;
  const password = document.getElementById("loginPassword").value;
  const mensajeError = document.getElementById("mensajeError");

  try {
    const response = await fetch("../modelo/login.php", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email, password }),
    });

    const data = await response.json();

    if (!data.ok) {
      if (mensajeError) {
        mensajeError.textContent = data.mensaje;
        mensajeError.style.display = "block";
      } else {
        alert(data.mensaje);
      }
      return;
    }

    // guardamos el usuario en sessionStorage para usarlo en las otras paginas
    sessionStorage.setItem("usuario", JSON.stringify(data.usuario));

    redirigirSegunRol(data.usuario.rol);
  } catch (error) {
    alert("Error al iniciar sesion: " + error.message);
  }
}

function redirigirSegunRol(rol) {
  switch (rol) {
    case "admin":
      window.location.href = "../vista/admin/dashboard.html";
      break;
    case "docente":
      window.location.href = "../vista/docente/dashboard.html";
      break;
    case "alumno":
      window.location.href = "../vista/alumno/dashboard.html";
      break;
    default:
      window.location.href = "../vista/login.html";
  }
}

export function handleLogout() {
  sessionStorage.removeItem("usuario");
  window.location.href = "../vista/login.html";
}
