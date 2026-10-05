defmodule Datos do
  @moduledoc """
  Módulo encargado de proveer la información base de prueba para el sistema.
  Contiene los datos de confeccionistas, líneas de producción y lotes de prendas.

  - Autores: Simón Valencia Ochoa, Samuel Marín Varón, Isabel Cristina Guerra Guzmán.
  - Fecha: Octubre del 2026
  - Licencia: GNU GPL v3
  """

  @doc """
  Retorna la lista de confeccionistas registrados en el taller.

  Cada confeccionista se representa mediante un mapa con sus atributos clave:
  - `:codigo` - Identificador único (String)
  - `:nombre` - Nombre completo (String)
  - `:alquiler` - Booleano indicando si alquila máquina del taller (`true`) o usa propia (`false`)

  ## Ejemplos

      iex> length(Datos.confeccionistas())
      10

      iex> hd(Datos.confeccionistas())
      %{codigo: "C01", nombre: "María Elena Ríos", alquiler: true}

  """
  def confeccionistas do
    [
      %{codigo: "C01", nombre: "María Elena Ríos", alquiler: true},
      %{codigo: "C02", nombre: "Andrés Salazar", alquiler: false},
      %{codigo: "C03", nombre: "Carlos Alberto Gómez", alquiler: true},
      %{codigo: "C04", nombre: "Diana Marcela Torres", alquiler: false},
      %{codigo: "C05", nombre: "Eduardo López", alquiler: true},
      %{codigo: "C06", nombre: "Fernanda Ramírez", alquiler: false},
      %{codigo: "C07", nombre: "Gabriel Patiño", alquiler: true},
      %{codigo: "C08", nombre: "Helena Castro", alquiler: false},
      %{codigo: "C09", nombre: "Ignacio Morales", alquiler: false},
      %{codigo: "C10", nombre: "Juana Restrepo", alquiler: false}
    ]
  end

  @doc """
  Retorna la lista de líneas de producción disponibles en el taller.

  Cada línea se representa como un mapa con:
  - `:id` - Identificador de la línea (String)
  - `:nombre` - Nombre descriptivo (String)
  - `:puestos` - Cantidad de puestos de trabajo (Entero positivo)

  ## Ejemplos

      iex> length(Datos.lineas())
      4

      iex> hd(Datos.lineas())
      %{id: "L1", nombre: "Línea Norte", puestos: 6}

  """
  def lineas do
    [
      %{id: "L1", nombre: "Línea Norte", puestos: 6},
      %{id: "L2", nombre: "Línea Central", puestos: 4},
      %{id: "L3", nombre: "Línea Sur", puestos: 5},
      %{id: "L4", nombre: "Línea Oriente", puestos: 3}
    ]
  end

  @doc """
  Retorna la lista total de lotes registrados para la semana de trabajo.

  Incluye 80 lotes válidos y 10 lotes inválidos (2 por cada motivo de rechazo posible)
  para probar el subsistema de validación.

  Cada lote está estructurado como un mapa con:
  - `:confeccionista` - Código del confeccionista
  - `:linea` - ID de la línea de producción
  - `:dia` - Día de la semana (1 a 6)
  - `:prendas` - Cantidad de prendas confeccionadas
  - `:defectos` - Porcentaje de prendas defectuosas

  ## Ejemplos

      iex> length(Datos.lotes())
      90

      iex> List.first(Datos.lotes())
      %{confeccionista: "C99", linea: "L1", dia: 1, prendas: 50, defectos: 1.0}

  """
  def lotes do
    [
      # --- 10 LOTES INVÁLIDOS (2 por cada regla de rechazo) ---
      # 1. :confeccionista_desconocido
      %{confeccionista: "C99", linea: "L1", dia: 1, prendas: 50, defectos: 1.0},
      %{confeccionista: "C88", linea: "L2", dia: 2, prendas: 60, defectos: 2.0},

      # 2. :linea_desconocida
      %{confeccionista: "C01", linea: "L9", dia: 1, prendas: 70, defectos: 1.0},
      %{confeccionista: "C02", linea: "L8", dia: 3, prendas: 80, defectos: 3.0},

      # 3. :dia_invalido
      %{confeccionista: "C03", linea: "L1", dia: 0, prendas: 100, defectos: 1.5},
      %{confeccionista: "C04", linea: "L2", dia: 7, prendas: 90, defectos: 4.0},

      # 4. :prendas_fuera_de_rango
      %{confeccionista: "C05", linea: "L3", dia: 2, prendas: 0, defectos: 2.0},
      %{confeccionista: "C06", linea: "L4", dia: 4, prendas: 181, defectos: 5.0},

      # 5. :porcentaje_invalido
      %{confeccionista: "C07", linea: "L1", dia: 5, prendas: 110, defectos: -1.0},
      %{confeccionista: "C08", linea: "L2", dia: 6, prendas: 120, defectos: 101.0},

      # --- 80 LOTES VÁLIDOS (Distribuidos entre los 10 confeccionistas y 6 días) ---
      # C01 (Suma > 120 prendas en Día 1 para bonificación)
      %{confeccionista: "C01", linea: "L1", dia: 1, prendas: 70, defectos: 1.5},
      %{confeccionista: "C01", linea: "L2", dia: 1, prendas: 55, defectos: 7.0},
      %{confeccionista: "C01", linea: "L1", dia: 2, prendas: 90, defectos: 12.0},
      %{confeccionista: "C01", linea: "L3", dia: 3, prendas: 110, defectos: 1.0},
      %{confeccionista: "C01", linea: "L4", dia: 4, prendas: 80, defectos: 3.0},
      %{confeccionista: "C01", linea: "L1", dia: 5, prendas: 95, defectos: 0.5},
      %{confeccionista: "C01", linea: "L2", dia: 6, prendas: 100, defectos: 6.0},

      # C02
      %{confeccionista: "C02", linea: "L2", dia: 1, prendas: 130, defectos: 1.0},
      %{confeccionista: "C02", linea: "L1", dia: 2, prendas: 140, defectos: 2.5},
      %{confeccionista: "C02", linea: "L3", dia: 3, prendas: 60, defectos: 8.0},
      %{confeccionista: "C02", linea: "L4", dia: 4, prendas: 75, defectos: 15.0},
      %{confeccionista: "C02", linea: "L2", dia: 5, prendas: 110, defectos: 1.8},
      %{confeccionista: "C02", linea: "L1", dia: 6, prendas: 125, defectos: 4.5},

      # C03 (Trabaja en las 4 líneas -> clave para R8)
      %{confeccionista: "C03", linea: "L1", dia: 1, prendas: 85, defectos: 1.0},
      %{confeccionista: "C03", linea: "L2", dia: 2, prendas: 95, defectos: 2.0},
      %{confeccionista: "C03", linea: "L3", dia: 3, prendas: 105, defectos: 0.8},
      %{confeccionista: "C03", linea: "L4", dia: 4, prendas: 115, defectos: 3.5},
      %{confeccionista: "C03", linea: "L1", dia: 5, prendas: 125, defectos: 1.2},
      %{confeccionista: "C03", linea: "L2", dia: 6, prendas: 130, defectos: 5.5},

      # C04
      %{confeccionista: "C04", linea: "L3", dia: 1, prendas: 60, defectos: 0.0},
      %{confeccionista: "C04", linea: "L4", dia: 2, prendas: 70, defectos: 1.1},
      %{confeccionista: "C04", linea: "L1", dia: 3, prendas: 80, defectos: 9.0},
      %{confeccionista: "C04", linea: "L2", dia: 4, prendas: 90, defectos: 11.0},
      %{confeccionista: "C04", linea: "L3", dia: 5, prendas: 100, defectos: 2.2},
      %{confeccionista: "C04", linea: "L4", dia: 6, prendas: 110, defectos: 3.0},

      # C05
      %{confeccionista: "C05", linea: "L1", dia: 1, prendas: 150, defectos: 1.0},
      %{confeccionista: "C05", linea: "L2", dia: 2, prendas: 140, defectos: 0.5},
      %{confeccionista: "C05", linea: "L3", dia: 3, prendas: 130, defectos: 2.1},
      %{confeccionista: "C05", linea: "L4", dia: 4, prendas: 120, defectos: 6.0},
      %{confeccionista: "C05", linea: "L1", dia: 5, prendas: 110, defectos: 14.0},
      %{confeccionista: "C05", linea: "L2", dia: 6, prendas: 100, defectos: 1.5},

      # C06
      %{confeccionista: "C06", linea: "L2", dia: 1, prendas: 50, defectos: 3.0},
      %{confeccionista: "C06", linea: "L3", dia: 2, prendas: 65, defectos: 1.0},
      %{confeccionista: "C06", linea: "L4", dia: 3, prendas: 70, defectos: 2.0},
      %{confeccionista: "C06", linea: "L1", dia: 4, prendas: 85, defectos: 4.0},
      %{confeccionista: "C06", linea: "L2", dia: 5, prendas: 90, defectos: 8.5},
      %{confeccionista: "C06", linea: "L3", dia: 6, prendas: 95, defectos: 1.2},

      # C07
      %{confeccionista: "C07", linea: "L3", dia: 1, prendas: 100, defectos: 1.0},
      %{confeccionista: "C07", linea: "L4", dia: 2, prendas: 105, defectos: 2.0},
      %{confeccionista: "C07", linea: "L1", dia: 3, prendas: 110, defectos: 3.0},
      %{confeccionista: "C07", linea: "L2", dia: 4, prendas: 115, defectos: 4.0},
      %{confeccionista: "C07", linea: "L3", dia: 5, prendas: 120, defectos: 5.0},
      %{confeccionista: "C07", linea: "L4", dia: 6, prendas: 125, defectos: 6.0},

      # C08
      %{confeccionista: "C08", linea: "L4", dia: 1, prendas: 40, defectos: 0.5},
      %{confeccionista: "C08", linea: "L1", dia: 2, prendas: 50, defectos: 1.5},
      %{confeccionista: "C08", linea: "L2", dia: 3, prendas: 60, defectos: 2.5},
      %{confeccionista: "C08", linea: "L3", dia: 4, prendas: 70, defectos: 3.5},
      %{confeccionista: "C08", linea: "L4", dia: 5, prendas: 80, defectos: 4.5},
      %{confeccionista: "C08", linea: "L1", dia: 6, prendas: 90, defectos: 5.5},

      # C09
      %{confeccionista: "C09", linea: "L1", dia: 1, prendas: 110, defectos: 2.0},
      %{confeccionista: "C09", linea: "L2", dia: 2, prendas: 115, defectos: 1.0},
      %{confeccionista: "C09", linea: "L3", dia: 3, prendas: 120, defectos: 0.5},
      %{confeccionista: "C09", linea: "L4", dia: 4, prendas: 125, defectos: 3.0},
      %{confeccionista: "C09", linea: "L1", dia: 5, prendas: 130, defectos: 7.0},
      %{confeccionista: "C09", linea: "L2", dia: 6, prendas: 135, defectos: 12.0},

      # C10
      %{confeccionista: "C10", linea: "L2", dia: 1, prendas: 95, defectos: 1.0},
      %{confeccionista: "C10", linea: "L3", dia: 2, prendas: 100, defectos: 2.0},
      %{confeccionista: "C10", linea: "L4", dia: 3, prendas: 105, defectos: 1.5},
      %{confeccionista: "C10", linea: "L1", dia: 4, prendas: 110, defectos: 2.5},
      %{confeccionista: "C10", linea: "L2", dia: 5, prendas: 115, defectos: 3.0},
      %{confeccionista: "C10", linea: "L3", dia: 6, prendas: 120, defectos: 4.0},

      # Lotes adicionales para completar exactamente 80 lotes válidos
      %{confeccionista: "C01", linea: "L3", dia: 2, prendas: 40, defectos: 1.0},
      %{confeccionista: "C02", linea: "L3", dia: 1, prendas: 50, defectos: 2.0},
      %{confeccionista: "C03", linea: "L3", dia: 5, prendas: 60, defectos: 1.5},
      %{confeccionista: "C04", linea: "L1", dia: 6, prendas: 70, defectos: 0.5},
      %{confeccionista: "C05", linea: "L3", dia: 1, prendas: 80, defectos: 3.0},
      %{confeccionista: "C06", linea: "L4", dia: 2, prendas: 90, defectos: 2.0},
      %{confeccionista: "C07", linea: "L1", dia: 3, prendas: 100, defectos: 1.0},
      %{confeccionista: "C08", linea: "L2", dia: 4, prendas: 110, defectos: 4.0}
    ]
  end
end
