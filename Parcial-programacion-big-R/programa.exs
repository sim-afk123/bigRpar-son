defmodule Programa do
  def main do
    confeccionistas = Datos.confeccionistas()
    lineas = Datos.lineas()
    lotes_base = Datos.lotes()

    # 1. Lote adicional
    lotes_totales = procesar_lote_adicional(lotes_base)

    # 2. Validar
    {:ok, validos, invalidos} = Validacion.clasificar_el_lote(lotes_totales, confeccionistas, lineas)

    # 3. Liquidar
    liquidaciones = Liquidacion.liquidar_todos(confeccionistas, validos)

    # 4. Reportes R1 a R8
    Reportes.generar_todos(validos, invalidos, liquidaciones, lineas)

    # 5. Investigación Parte C
    Investigacion.ejecutar_todo(liquidaciones, validos)

    # 6. Comprobante individual
    solicitar_comprobante_individual(liquidaciones)
  end

  defp procesar_lote_adicional(lotes_base) do
    entrada = Util.ingresar("Ingrese un lote adicional (confeccionista;linea;dia;prendas;defectos) o Enter para omitir: ", :texto)

    if entrada == "" do
      Util.mostrar_mensaje("Lote adicional omitido.")
      lotes_base
    else
      case String.split(entrada, ";") do
        [c, l, d_str, p_str, def_str] ->
          try do
            nuevo_lote = %{
              confeccionista: String.trim(c),
              linea: String.trim(l),
              dia: String.to_integer(String.trim(d_str)),
              prendas: String.to_integer(String.trim(p_str)),
              defectos: String.to_float(String.trim(def_str))
            }
            Util.mostrar_mensaje("Lote agregado correctamente.")
            [nuevo_lote | lotes_base]
          rescue
            ArgumentError ->
              Util.mostrar_error("Error: {:error, :formato_invalido}")
              lotes_base
          end

        _ ->
          Util.mostrar_error("Error: {:error, :formato_invalido}")
          lotes_base
      end
    end
  end

  defp solicitar_comprobante_individual(liquidaciones) do
    codigo = Util.ingresar("\nIngrese el código de un confeccionista para ver su comprobante: ", :texto)
    c_codigo = String.trim(codigo)

    case Enum.find(liquidaciones, fn liq -> liq.codigo == c_codigo end) do
      nil ->
        Util.mostrar_error("El confeccionista '#{c_codigo}' no existe.")

      liq ->
        IO.puts("\n" <> String.duplicate("=", 40))
        IO.puts("COMPROBANTE INDIVIDUAL")
        IO.puts("Confeccionista: #{liq.nombre} (#{liq.codigo})")
        IO.puts(String.duplicate("=", 40))

        dias_trabajados = Enum.group_by(liq.lotes, & &1.dia)

        Enum.each(Enum.sort(Map.keys(dias_trabajados)), fn dia ->
          lotes_dia = Map.get(dias_trabajados, dia)
          prendas_dia = Enum.reduce(lotes_dia, 0, &(&1.prendas + &2))
          val_lotes_dia = Enum.reduce(lotes_dia, 0.0, &(&1.prendas * 3200 * Liquidacion.calcular_factor_ajuste(&1.defectos) + &2))
          bono_dia = if prendas_dia >= 120, do: 18000.0, else: 0.0

          IO.puts("Día #{dia}: #{prendas_dia} prendas | Valor lotes: $#{Util.formatter(val_lotes_dia)} | Bono: $#{Util.formatter(bono_dia)}")
        end)

        IO.puts(String.duplicate("-", 40))
        IO.puts("Suma de lotes:       $#{Util.formatter(liq.bruto)}")
        IO.puts("Suma bonificaciones: $#{Util.formatter(liq.bonificaciones)}")
        IO.puts("Descuento alquiler: -$#{Util.formatter(liq.alquiler)}")
        IO.puts("PAGO NETO:           $#{Util.formatter(liq.neto)}")
        IO.puts(String.duplicate("=", 40))
    end
  end
end

Programa.main()
