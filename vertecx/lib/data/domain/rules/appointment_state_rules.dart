List<String> getOpcionesEstado(String estado, {bool esTecnico = false}) {
  if (esTecnico) {
    if (estado == "En-proceso") {
      return ["Finalizado", "Cancelado"];
    }
    return [];
  }

  switch (estado) {
    case "Pendiente":
      return ["En-proceso", "Cancelado"];
    case "En-proceso":
      return ["Finalizado", "Cancelado", "Cerrado"];
    case "Cancelado":
    case "Finalizado":
      return [];
    default:
      return [];
  }
}
