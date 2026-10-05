defmodule Validacion do
  @moduledoc """
  Módulo encargado de la validación y filtrado de lotes de confección.
  Aplica el conjunto de reglas de negocio en orden estricto para clasificar
  los lotes registrados entre válidos e inválidos.

  - Autores: Simón Valencia Ochoa, Samuel Marín Varón, Isabel Cristina Guerra Guzmán.
  - Fecha: Octubre del 2026
  - Licencia: GNU GPL v3
  """

  @doc """
  Clasifica una lista de lotes recibidos en dos grupos: válidos e inválidos.

  Procesa cada lote evaluando sus reglas y retorna una tupla `{:ok, validos, invalidos}`
  donde `validos` contiene la lista de mapas de lotes aceptados e `invalidos` contiene
  tuplas de la forma `{lote, motivo_rechazo}`.

  ## Parámetros
   - `lotes`: Lista de mapas con los lotes a evaluar.
   - `confeccionistas`: Lista de confeccionistas válidos registrados en la base de datos.
   - `lineas`: Lista de líneas de producción válidas del taller.

  ## Ejemplos

      iex> c = Datos.confeccionistas()
      iex> l = Datos.lineas()
      iex> lotes = [%{confeccionista: "C01", linea: "L1", dia: 1, prendas: 70, defectos: 1.5}]
      iex> {:ok, validos, invalidos} = Validacion.clasificar_el_lote(lotes, c, l)
      iex> Enum.count(validos)
      1
      iex> Enum.count(invalidos)
      0

  """
  def clasificar_el_lote(lotes, confeccionistas, lineas) do
    lotes_que_son_validamos = Enum.map(lotes, fn lote -> {lote, validar_el_lote(lote, confeccionistas, lineas)} end)

    validos =
      lotes_que_son_validamos
      |> Enum.filter(fn {_lote, resultado} ->
           case resultado do
             {:ok, _lote} -> true
             _ -> false
           end
         end)
      |> Enum.map(fn {lote, _resultado} -> lote end)

    invalidos =
      lotes_que_son_validamos
      |> Enum.filter(fn {_lote, resultado} ->
           case resultado do
             {:error, _motivo} -> true
             _ -> false
           end
         end)
      |> Enum.map(fn {lote, {:error, motivo}} -> {lote, motivo} end)

    {:ok, validos, invalidos}
  end

  @doc """
  Valida un lote individual encadenando la verificación de las 5 reglas en el orden exacto exigido.

  Si falla en alguna regla, detiene la evaluación mediante `with` y retorna inmediatamente
  el primer motivo de rechazo encontrado.

  ## Parámetros
   - `lote`: Mapa con los datos individuales del lote.
   - `confeccionistas`: Lista de confeccionistas registrados.
   - `lineas`: Lista de líneas de producción registradas.

  ## Ejemplos

      iex> c = Datos.confeccionistas()
      iex> l = Datos.lineas()
      iex> lote_val = %{confeccionista: "C01", linea: "L1", dia: 1, prendas: 70, defectos: 1.5}
      iex> Validacion.validar_el_lote(lote_val, c, l)
      {:ok, %{confeccionista: "C01", linea: "L1", dia: 1, prendas: 70, defectos: 1.5}}

      iex> lote_inv = %{confeccionista: "C99", linea: "L1", dia: 1, prendas: 70, defectos: 1.5}
      iex> Validacion.validar_el_lote(lote_inv, c, l)
      {:error, :confeccionista_desconocido}

  """
  def validar_el_lote(lote, confeccionistas, lineas) do
    with {:ok, _confeccionista} <- validar_confeccionista(lote.confeccionista, confeccionistas),
         {:ok, _linea} <- validar_linea(lote.linea, lineas),
         {:ok, _dia} <- validar_dia(lote.dia),
         {:ok, _prendas} <- validar_prendas(lote.prendas),
         {:ok, _defectos} <- validar_defectos(lote.defectos) do
      {:ok, lote}
    else
      {:error, motivo} -> {:error, motivo}
    end
  end

  @doc """
  Regla 1: Verifica si el código de confeccionista del lote existe en el catálogo.

  ## Parámetros
   - `confeccionista`: Código del confeccionista (String).
   - `confeccionistas`: Lista de mapas de confeccionistas registrados.

  ## Ejemplos

      iex> c = Datos.confeccionistas()
      iex> Validacion.validar_confeccionista("C01", c)
      {:ok, "C01"}

      iex> Validacion.validar_confeccionista("C99", c)
      {:error, :confeccionista_desconocido}

  """
  def validar_confeccionista(confeccionista, confeccionistas) do
    existe = Enum.find(confeccionistas, fn c -> c.codigo == confeccionista end)
    if existe do
      {:ok, confeccionista}
    else
      {:error, :confeccionista_desconocido}
    end
  end

  @doc """
  Regla 2: Verifica si la línea de producción indicada existe en el sistema.

  ## Parámetros
   - `linea`: ID de la línea de producción (String).
   - `lineas`: Lista de mapas de líneas registradas.

  ## Ejemplos

      iex> l = Datos.lineas()
      iex> Validacion.validar_linea("L1", l)
      {:ok, "L1"}

      iex> Validacion.validar_linea("L9", l)
      {:error, :linea_desconocida}

  """
  def validar_linea(linea, lineas) do
    existe = Enum.find(lineas, fn l -> l.id == linea end)
    if existe do
      {:ok, linea}
    else
      {:error, :linea_desconocida}
    end
  end

  @doc """
  Regla 3: Comprueba que el día sea un número entero entre 1 y 6.

  ## Parámetros
   - `dia`: Valor a evaluar (Entero).

  ## Ejemplos

      iex> Validacion.validar_dia(3)
      {:ok, 3}

      iex> Validacion.validar_dia(7)
      {:error, :dia_invalido}

  """
  def validar_dia(dia) do
    if is_integer(dia) and dia >= 1 and dia <= 6 do
      {:ok, dia}
    else
      {:error, :dia_invalido}
    end
  end

  @doc """
  Regla 4: Comprueba que la cantidad de prendas sea un entero dentro del rango [1, 180].

  ## Parámetros
   - `prendas`: Valor entero que representa la cantidad de prendas del lote.

  ## Ejemplos

      iex> Validacion.validar_prendas(100)
      {:ok, 100}

      iex> Validacion.validar_prendas(200)
      {:error, :prendas_fuera_de_rango}

  """
  def validar_prendas(prendas) do
    if is_integer(prendas) and prendas >= 1 and prendas <= 180 do
      {:ok, prendas}
    else
      {:error, :prendas_fuera_de_rango}
    end
  end

  @doc """
  Regla 5: Comprueba que el porcentaje de defectos sea un valor numérico entre 0 y 100.

  ## Parámetros
   - `defectos`: Número (entero o flotante) con el porcentaje registrado.

  ## Ejemplos

      iex> Validacion.validar_defectos(2.5)
      {:ok, 2.5}

      iex> Validacion.validar_defectos(-1.0)
      {:error, :porcentaje_invalido}

  """
  def validar_defectos(defectos) do
    if is_number(defectos) and defectos >= 0 and defectos <= 100 do
      {:ok, defectos}
    else
      {:error, :porcentaje_invalido}
    end
  end
end
