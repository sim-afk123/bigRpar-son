defmodule Liquidacion do
  @tarifa 3200
  @bonificacion 18000
  @alquiler_maquina 15000
  @prendas_para_bonificacion 120


  def calcular_valor_lote(%{prendas: prendas, defectos: defectos}) do
    valor_base = prendas * @tarifa
    factor = calcular_factor_ajuste(defectos)
    valor_base * factor
  end


  def calcular_factor_ajuste(defectos) do
    cond do
      defectos <= 2.0 -> 1.07
      defectos <= 5.0 -> 1.00
      defectos <= 10.0 -> 0.88
      true -> 0.75
    end
  end


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

  #ayudado con ia
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

  def liquidar_todos(confeccionistas, lotes_validos) do
    Enum.map(confeccionistas, fn confeccionista ->
      liquidar_confeccionista(confeccionista, lotes_validos)
    end)
  end
end