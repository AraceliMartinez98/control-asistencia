// Se importa en cada pantalla protegida (admin, docente, alumno).
// Si no hay usuario logueado, o el rol no coincide, patea al login.

export function protegerPagina(rolEsperado) {
  const usuarioGuardado = sessionStorage.getItem("usuario");

  if (!usuarioGuardado) {
    window.location.href = "../login.html";
    return null;
  }

  const usuario = JSON.parse(usuarioGuardado);

  if (usuario.rol !== rolEsperado) {
    window.location.href = "../login.html";
    return null;
  }

  return usuario;
}
