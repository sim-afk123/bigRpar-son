defmodule Programa do
  @moduledoc """
  Punto de entrada principal de la aplicación.
  Coordina el flujo completo: lectura de datos, procesamiento del lote adicional por consola,
  validación, cálculo de liquidaciones, generación de los 8 reportes, pruebas de investigación
  y la interacción final para consulta del comprobante individual.

  - Autores: Simón Valencia Ochoa, Samuel Marín Varón, Isabel Cristina Guerra Guzmán.
  - Fecha: Octubre del 2026
  - Licencia: GNU GPL v3
  """

  @doc """
  Función principal que orquesta la ejecución completa del programa en el orden estipulado.

  ## Ejemplos

      ```elixir
      Programa.main()
      ```

  """
  def main do
    confeccionistas = Datos.confeccionistas()
    lineas = Datos.lineas()
    lotes_base = Datos.lotes()

    # 1. lote adicional
    lotes_totales = procesar_lote_adicional(lotes_base)

    # 2. validar
    {:ok, validos, invalidos} = Validacion.clasificar_el_lote(lotes_totales, confeccionistas, lineas)

    # 3. liquidar
    liquidaciones = Liquidacion.liquidar_todos(confeccionistas, validos)

    # 4. reporte R1 a R8
    Reportes.generar_todos(validos, invalidos, liquidaciones, lineas)

    # 5. investigacion Parte C
    Investigacion.ejecutar_todo(liquidaciones, validos)

    # 6. comprobante individual
    solicitar_comprobante_individual(liquidaciones)
  end

  @doc """
  Solicita por consola la entrada de un lote de prendas adicional en formato separado por punto y coma.
  Valida su estructura antes de incluirlo a la lista de lotes.

  ## Parámetros
   - `lotes_base`: Lista inicial de lotes proveniente de `Datos.lotes/0`.

  """
  defp procesar_lote_adicional(lotes_base) do
    entrada = Util.ingresar("ingrese un lote adicional (confeccionista;linea;dia;prendas;defectos) o tan solo de enter para omitir: ", :texto)

    if entrada == "" do
      Util.mostrar_mensaje("lote adicional omitido.")
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
            Util.mostrar_mensaje("lote agregado correctamente.")
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

  @doc """
  Solicita el código de un confeccionista para imprimir un comprobante desglosado
  día por día con sus valores, bonificaciones y deducciones aplicables.

  ## Parámetros
   - `liquidaciones`: Lista de liquidaciones calculadas.

  """
  defp solicitar_comprobante_individual(liquidaciones) do
    codigo = Util.ingresar("\ningrese el código de un confeccionista para ver su comprobante: ", :texto)
    c_codigo = String.trim(codigo)

    case Enum.find(liquidaciones, fn liq -> liq.codigo == c_codigo end) do
      nil ->
        Util.mostrar_error("el confeccionista '#{c_codigo}' no existe.")

      liq ->
        IO.puts("\n" <> String.duplicate("-", 20))
        IO.puts("comprobante individual")
        IO.puts("confeccionista: #{liq.nombre} (#{liq.codigo})")
        IO.puts(String.duplicate("-", 20))

        dias_trabajados = Enum.group_by(liq.lotes, & &1.dia)

        Enum.each(Enum.sort(Map.keys(dias_trabajados)), fn dia ->
          lotes_dia = Map.get(dias_trabajados, dia)
          prendas_dia = Enum.reduce(lotes_dia, 0, &(&1.prendas + &2))
          val_lotes_dia = Enum.reduce(lotes_dia, 0.0, &(&1.prendas * 3200 * Liquidacion.calcular_factor_ajuste(&1.defectos) + &2))
          bono_dia = if prendas_dia >= 120, do: 18000.0, else: 0.0

          IO.puts("dia #{dia}: #{prendas_dia} prendas | valor lotes: $#{Util.formatter(val_lotes_dia)} \vert{} bono: $#{Util.formatter(bono_dia)}")
        end)

        IO.puts(String.duplicate("-", 20))
        IO.puts("suma de lotes:       $#{Util.formatter(liq.bruto)}")
        IO.puts("suma bonificaciones: $#{Util.formatter(liq.bonificaciones)}")
        IO.puts("descuento alquiler: -$#{Util.formatter(liq.alquiler)}")
        IO.puts("PAGO NETO:           $#{Util.formatter(liq.neto)}")
        IO.puts(String.duplicate("-", 20))
    end
  end
end

Programa.main()
