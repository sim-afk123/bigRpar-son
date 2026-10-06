defmodule Liquidacion do
  @moduledoc """
  Módulo que reúne la lógica de negocio para liquidar el pago a confeccionistas.
  Calcula valores de lotes según calidad, bonificaciones por productividad y alquiler de máquinas.

  - Autores: Simón Valencia Ochoa, Samuel Marín Varón, Isabel Cristina Guerra Guzmán.
  - Fecha: Octubre del 2026
  - Licencia: GNU GPL v3
  """

  @tarifa 3200
  @bonificacion 18000
  @alquiler_maquina 15000
  @prendas_para_bonificacion 120

  @doc """
  Calcula el valor económico monetario de un único lote de prendas válido.

  Aplica la tarifa base ($3.200) multiplicada por la cantidad de prendas
  y ajustada por el factor de calidad derivado del porcentaje de defectos.

  ## Parámetros
   - `lote`: Mapa que contiene los datos del lote (`:prendas` y `:defectos`).

  ## Ejemplos

      iex> Liquidacion.calcular_valor_lote(%{prendas: 70, defectos: 1.5})
      239680.0

      iex> Liquidacion.calcular_valor_lote(%{prendas: 90, defectos: 12.0})
      216000.0

  """
  def calcular_valor_lote(%{prendas: prendas, defectos: defectos}) do
    valor_base = prendas * @tarifa
    factor = calcular_factor_ajuste(defectos)
    valor_base * factor
  end

  @doc """
  Calcula el factor multiplicador según el rango del porcentaje de prendas defectuosas.

  Reglas de ajuste:
  - Hasta 2.0%: Bonificación del +7% (factor 1.07)
  - Más de 2.0% y hasta 5.0%: Sin ajuste (factor 1.00)
  - Más de 5.0% y hasta 10.0%: Descuento del -12% (factor 0.88)
  - Más de 10.0%: Descuento del -25% (factor 0.75)

  ## Parámetros
   - `defectos`: Número flotante o entero con el porcentaje de defectos.

  ## Ejemplos

      iex> Liquidacion.calcular_factor_ajuste(1.5)
      1.07

      iex> Liquidacion.calcular_factor_ajuste(7.0)
      0.88

      iex> Liquidacion.calcular_factor_ajuste(15.0)
      0.75

  """
  def calcular_factor_ajuste(defectos) do
    cond do
      defectos <= 2.0 -> 1.07
      defectos <= 5.0 -> 1.00
      defectos <= 10.0 -> 0.88
      true -> 0.75
    end
  end

  @doc """
  Suma las bonificaciones por productividad acumuladas por un confeccionista a lo largo de la semana.

  Se otorgan $18.000 por cada día en el que la suma total de prendas producidas
  en todos sus lotes válidos alcance o supere las 120 prendas.

  ## Parámetros
   - `lotes_confeccionista`: Lista de mapas con los lotes válidos del confeccionista.

  ## Ejemplos

      iex> lotes = [%{dia: 1, prendas: 70}, %{dia: 1, prendas: 55}, %{dia: 2, prendas: 90}]
      iex> Liquidacion.calcular_bonificaciones_diarias(lotes)
      18000

  """
  def calcular_bonificaciones_diarias(lotes_confeccionista) do
    lotes_confeccionista
    |> Enum.group_by(fn lote -> lote.dia end)
    |> Enum.reduce(0, fn {_dia, lotes_del_dia}, contador_bono ->
      total_prendas_dia = Enum.reduce(lotes_del_dia, 0, fn lote, contador -> contador + lote.prendas end)

      if total_prendas_dia >= @prendas_para_bonificacion do
        contador_bono + @bonificacion
      else
        contador_bono
      end
    end)
  end

  @doc """
  Calcula el costo total del alquiler de maquinaria del taller para la semana.

  Aplica un costo de $15.000 por cada día único en el que el confeccionista haya
  registrado al menos un lote válido, siempre y cuando su condición de alquiler sea `true`.

  ## Parámetros
   - `lotes_confeccionista`: Lista de lotes válidos pertenecientes al confeccionista.
   - `tiene_alquiler`: Booleano que define si el confeccionista alquila máquina.

  ## Ejemplos

      iex> lotes = [%{dia: 1, prendas: 70}, %{dia: 1, prendas: 55}, %{dia: 2, prendas: 90}]
      iex> Liquidacion.calcular_alquiler_maquina(lotes, true)
      30000

      iex> Liquidacion.calcular_alquiler_maquina(lotes, false)
      0

  """
  def calcular_alquiler_maquina(lotes_confeccionista, tiene_alquiler) do
    if tiene_alquiler do
      dias_trabajados =
        lotes_confeccionista
        |> Enum.map(fn lote -> lote.dia end)
        |> Enum.uniq()
        |> Enum.count()

      dias_trabajados * @alquiler_maquina
    else
      0
    end
  end

  @doc """
  Genera la liquidación consolidada para un único confeccionista.

  Calcula el total de prendas, la suma bruta de los valores de sus lotes, las bonificaciones
  ganadas y el descuento por alquiler de máquina para obtener el valor neto a pagar.

  ## Parámetros
   - `confeccionista`: Mapa con la información del confeccionista.
   - `lotes_validos`: Lista completa de lotes válidos del taller.

  ## Ejemplos

      iex> c = %{codigo: "C01", nombre: "María Elena Ríos", alquiler: true}
      iex> lotes = [
      ...>   %{confeccionista: "C01", linea: "L1", dia: 1, prendas: 70, defectos: 1.5},
      ...>   %{confeccionista: "C01", linea: "L2", dia: 1, prendas: 55, defectos: 7.0},
      ...>   %{confeccionista: "C01", linea: "L1", dia: 2, prendas: 90, defectos: 12.0}
      ...> ]
      iex> liq = Liquidacion.liquidar_confeccionista(c, lotes)
      iex> liq.neto
      598560.0

  """
  def liquidar_confeccionista(confeccionista, lotes_validos) do
    lotes_propios =
      Enum.filter(lotes_validos, fn lote -> lote.confeccionista == confeccionista.codigo end)

    total_prendas = Enum.reduce(lotes_propios, 0, fn lote, contador -> contador + lote.prendas end)
    suma_valor_lotes = Enum.reduce(lotes_propios, 0.0, fn lote, contador -> contador + calcular_valor_lote(lote) end)
    bonificaciones = calcular_bonificaciones_diarias(lotes_propios) * 1.0
    descuento_alquiler = calcular_alquiler_maquina(lotes_propios, confeccionista.alquiler) * 1.0

    neto = suma_valor_lotes + bonificaciones - descuento_alquiler

    %{
      codigo: confeccionista.codigo,
      nombre: confeccionista.nombre,
      prendas: total_prendas,
      bruto: suma_valor_lotes * 1.0,
      bonificaciones: bonificaciones,
      alquiler: descuento_alquiler,
      neto: neto * 1.0,
      lotes: lotes_propios
    }
  end

  @doc """
  Liquida a todos los confeccionistas registrados en el taller.

  Retorna una lista de mapas con las liquidaciones individuales. Si un confeccionista
  no tiene lotes válidos, aparecerá en la liquidación con valores en cero.

  ## Parámetros
   - `confeccionistas`: Lista de todos los confeccionistas.
   - `lotes_validos`: Lista de lotes válidos aceptados por el taller.

  ## Ejemplos

      iex> c_list = Datos.confeccionistas()
      iex> l_list = []
      iex> liqs = Liquidacion.liquidar_todos(c_list, l_list)
      iex> Enum.count(liqs)
      10

  """
  def liquidar_todos(confeccionistas, lotes_validos) do
    Enum.map(confeccionistas, fn confeccionista ->
      liquidar_confeccionista(confeccionista, lotes_validos)
    end)
  end
end
