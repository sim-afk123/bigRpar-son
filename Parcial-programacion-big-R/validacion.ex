defmodule Validacion do
  def clasificar_el_lote(lotes, confeccionistas, lineas) do
    lotes_que_son_validamos = Enum.map(lotes, fn lote -> {lote, validar_el_lote(lote, confeccionistas, lineas)} end)
    validos = lotes_que_son_validamos
    |> Enum.filter(fn {_lote, resultado} ->
         case resultado do
           {:ok, _lote} -> true
           _ -> false
         end
       end)
    |> Enum.map(fn {lote, _resultado} -> lote end)

    invalidos = lotes_que_son_validamos
    |> Enum.filter(fn {_lote, resultado} ->
         case resultado do
           {:error, _motivo} -> true
           _ -> false
         end
       end)
    |> Enum.map(fn {lote, {:error, motivo}} -> {lote, motivo} end)

    {:ok, validos, invalidos}
      end

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

  def validar_confeccionista(confeccionista, confeccionistas) do
    existe = Enum.find(confeccionistas, fn c -> c.codigo == confeccionista end)
    if existe do
      {:ok, confeccionista}
    else
      {:error, :confeccionista_desconocido}
    end
  end


  def validar_linea(linea, lineas) do
    existe = Enum.find(lineas, fn l -> l.id == linea end)
    if existe do
      {:ok, linea}
    else
      {:error, :linea_desconocida}
    end
  end

  def validar_dia(dia) do
    if is_integer(dia) and dia >= 1 and dia <= 6 do
      {:ok, dia}
    else
      {:error, :dia_invalido}
    end
  end

  def validar_prendas(prendas) do
    if is_integer(prendas) and prendas >= 1 and prendas <= 180 do
      {:ok, prendas}
    else
      {:error, :prendas_fuera_de_rango}
    end
  end

  def validar_defectos(defectos) do
    if is_number(defectos) and defectos >= 0 and defectos <= 100 do
      {:ok, defectos}
    else
      {:error, :porcentaje_invalido}
    end
  end

end
