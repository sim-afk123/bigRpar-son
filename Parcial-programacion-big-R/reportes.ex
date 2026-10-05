defmodule Reportes do
  @moduledoc """
  Módulo encargando de consolidar y formatear la salida en pantalla de los ocho (8)
  reportes analíticos de producción, calidad y liquidación exigidos por el taller.

  - Autores: Simón Valencia Ochoa, Samuel Marín Varón, Isabel Cristina Guerra Guzmán.
  - Fecha: Octubre del 2026
  - Licencia: GNU GPL v3
  """

  @doc """
  Ejecuta secuencialmente la generación de los 8 reportes exigidos por el sistema.

  ## Parámetros
   - `validos`: Lista de lotes aprobados por validación.
   - `invalidos`: Lista de tuplas `{lote, motivo}` rechazadas.
   - `liquidaciones`: Lista de liquidaciones calculadas.
   - `lineas`: Lista de líneas de producción de la empresa.

  ## Ejemplos

      ```elixir
      Reportes.generar_todos(validos, invalidos, liquidaciones, lineas)
      ```

  """
  def generar_todos(validos, invalidos, liquidaciones, lineas) do
    IO.puts("\n================================================================================")
    IO.puts("                     REPORTES DE PRODUCCIÓN Y LIQUIDACIÓN")
    IO.puts("================================================================================")

    r1(invalidos)
    r2(validos, lineas)
    r3(validos)
    r4(liquidaciones)
    r5(validos)
    r6(validos)
    r7(validos, liquidaciones)
    r8(validos, lineas)
  end

  @doc """
  R1: Imprime el detalle de lotes rechazados e indica la frecuencia por motivo de rechazo.

  ## Parámetros
   - `invalidos`: Lista de tuplas `{lote, motivo_rechazo}`.

  """
  def r1(invalidos) do
    IO.puts("R1: REPORTE DE LOTES RECHAZADOS Y RESUMEN POR MOTIVO")

    IO.puts("Detalle de lotes no válidos:")
    IO.puts(String.pad_trailing("Confecc.", 10) <> String.pad_trailing("Línea", 8) <> String.pad_trailing("Día", 6) <> String.pad_trailing("Prendas", 10) <> String.pad_trailing("Defectos (%)", 14) <> "Motivo de Rechazo")
    IO.puts(String.duplicate("-", 20))

    Enum.each(invalidos, fn {l, m} ->
      c = String.pad_trailing(to_string(l.confeccionista), 10)
      lin = String.pad_trailing(to_string(l.linea), 8)
      d = String.pad_trailing(to_string(l.dia), 6)
      p = String.pad_trailing(to_string(l.prendas), 10)
      defec = String.pad_trailing("#{l.defectos}%", 14)
      IO.puts("#{c}#{lin}#{d}#{p}#{defec}:#{m}")
    end)

    IO.puts("\nResumen de rechazos por motivo:")
    invalidos
    |> Enum.frequencies_by(fn {_l, m} -> m end)
    |> Enum.each(fn {m, c} ->
      IO.puts("  • Motivo ':#{m}': #{c} lote(s) rechazado(s)")
    end)
  end

  @doc """
  R2: Muestra las prendas elaboradas por línea y su productividad relativa (prendas/puesto).
  Muestra los resultados ordenados descendentemente.

  ## Parámetros
   - `validos`: Lista de lotes válidos.
   - `lineas`: Lista de líneas de producción.

  """
  def r2(validos, lineas) do
    IO.puts("\n")
    IO.puts("R2: PRODUCTIVIDAD SEMANAL POR LÍNEA DE PRODUCCIÓN (mayor a menor)")

    IO.puts(String.pad_trailing("Línea", 10) <> String.pad_trailing("Puestos", 10) <> String.pad_trailing("Prendas Totales", 18) <> "Productividad (Prendas/Puesto)")
    IO.puts(String.duplicate("-", 20))

    map = Enum.group_by(validos, & &1.linea)

    lineas
    |> Enum.map(fn lin ->
      prendas = Enum.reduce(Map.get(map, lin.id, []), 0, &(&1.prendas + &2))
      %{id: lin.id, puestos: lin.puestos, prendas: prendas, prod: prendas / lin.puestos}
    end)
    |> Enum.sort_by(& &1.prod, :desc)
    |> Enum.each(fn l ->
      id = String.pad_trailing(l.id, 10)
      puestos = String.pad_trailing(to_string(l.puestos), 10)
      prendas = String.pad_trailing(to_string(l.prendas), 18)
      prod = Util.formatter(l.prod)
      IO.puts("#{id}#{puestos}#{prendas}#{prod}")
    end)
  end

  @doc """
  R3: Muestra el total diario de prendas y evalúa el cumplimiento de la meta (600 prendas).

  ## Parámetros
   - `validos`: Lista de lotes válidos.

  """
  def r3(validos) do
    IO.puts("\n")
    IO.puts("R3: PRODUCCIÓN DIARIA DEL TALLER Y EVALUACIÓN DE META (Meta: 600 prendas por día)")

    IO.puts(String.pad_trailing("Día", 8) <> String.pad_trailing("Prendas Producidas", 22) <> "Estado Meta (>= 600)")
    IO.puts(String.duplicate("-", 20))

    map = Enum.group_by(validos, & &1.dia)

    res = Enum.map(1..6, fn d ->
      p = Enum.reduce(Map.get(map, d, []), 0, &(&1.prendas + &2))
      meta = p >= 600
      estado = if meta, do: "CUMPLIDA", else: "NO CUMPLIDA"
      dia_str = String.pad_trailing("Día #{d}", 8)
      prendas_str = String.pad_trailing("#{p} prendas", 22)
      IO.puts("#{dia_str}#{prendas_str}#{estado}")
      meta
    end)

    IO.puts(String.duplicate("-", 50))
    IO.puts("¿se alcanzó la meta todos los dia?:     #{if Enum.all?(res), do: "SÍ", else: "NO"}")
    IO.puts("¿se alcanzó la meta aunque sea un dia?:   #{if Enum.any?(res), do: "SÍ", else: "NO"}")
  end

  @doc """
  R4: Muestra la tabla de liquidación semanal ordenada descendentemente por pago neto.

  ## Parámetros
   - `liquidaciones`: Lista de mapas con la información de liquidación.

  """
  def r4(liquidaciones) do
    IO.puts("\n")
    IO.puts("R4: LIQUIDACIÓN SEMANAL DE CONFECCIONISTAS (Ordenado por pago neto descendente)")

    IO.puts(String.pad_trailing("Pos", 5) <> String.pad_trailing("Cód.", 6) <> String.pad_trailing("Nombre", 22) <> String.pad_trailing("Prendas", 9) <> String.pad_trailing("Bruto ($)", 13) <> String.pad_trailing("Bonos ($)", 12) <> String.pad_trailing("Alquiler ($)", 13) <> "Neto a Pagar ($)")
    IO.puts(String.duplicate("-", 92))

    liquidaciones
    |> Enum.sort_by(& &1.neto, :desc)
    |> Enum.with_index(1)
    |> Enum.each(fn {l, i} ->
      pos = String.pad_trailing("#{i}.", 5)
      cod = String.pad_trailing(l.codigo, 6)
      nom = String.pad_trailing(l.nombre, 22)
      p = String.pad_trailing(to_string(l.prendas), 9)
      bruto = String.pad_trailing("$" <> Util.formatter(l.bruto), 13)
      bono = String.pad_trailing("$" <> Util.formatter(l.bonificaciones), 12)
      alq = String.pad_trailing("-$" <> Util.formatter(l.alquiler), 13)
      neto = "$" <> Util.formatter(l.neto)

      IO.puts("#{pos}#{cod}#{nom}#{p}#{bruto}#{bono}#{alq}#{neto}")
    end)
  end

  @doc """
  R5: Identifica los confeccionistas más productivos de cada día y el líder global.

  ## Parámetros
   - `validos`: Lista de lotes válidos.

  """
  def r5(validos) do
    IO.puts("\n")
    IO.puts("R5: CONFECCIONISTA(S) MÁS PRODUCTIVO(S) POR DÍA Y LÍDER GENERAL")

    ganadores = Enum.map(1..6, fn d ->
      lotes = Enum.filter(validos, &(&1.dia == d))
      if lotes == [] do
        IO.puts("  dia #{d}: sin lotes válidos registrados")
        []
      else
        totales = lotes |> Enum.group_by(& &1.confeccionista) |> Enum.map(fn {c, l} -> {c, Enum.reduce(l, 0, &(&1.prendas + &2))} end)
        max = totales |> Enum.map(&elem(&1, 1)) |> Enum.max()
        top = Enum.filter(totales, &(elem(&1, 1) == max)) |> Enum.map(&elem(&1, 0))
        IO.puts("  • Día #{d}: #{Enum.join(top, ", ")} con #{max} prendas")
        top
      end
    end)

    frec = ganadores |> List.flatten() |> Enum.frequencies()
    if frec != %{} do
      max = frec |> Map.values() |> Enum.max()
      top = frec |> Enum.filter(&(elem(&1, 1) == max)) |> Enum.map(&elem(&1, 0))
      IO.puts("\n   mas dias ocupando el 1er lugar: #{Enum.join(top, ", ")} (#{max} día(s))")
    end
  end

  @doc """
  R6: Destaca al confeccionista con mejor calidad (menor % ponderado de defectos) entre
  aquellos con al menos 3 lotes válidos.

  ## Parámetros
   - `validos`: Lista de lotes válidos.

  """
  def r6(validos) do
    IO.puts("\n")
    IO.puts("R6: CONFECCIONISTA CON MEJOR CALIDAD (por lo menos 3 lotes, menor porcentaje ponderado de defectos)")

    cand = validos
    |> Enum.group_by(& &1.confeccionista)
    |> Enum.filter(fn {_c, l} -> length(l) >= 3 end)
    |> Enum.map(fn {c, l} ->
      prod = Enum.reduce(l, 0.0, &(&1.defectos * &1.prendas + &2))
      prendas = Enum.reduce(l, 0, &(&1.prendas + &2))
      %{c: c, p: prod / prendas}
    end)

    if cand == [] do
      IO.puts("  Ningún confeccionista cumple con el mínimo de 3 lotes válidos.")
    else
      m = Enum.min_by(cand, & &1.p)
      IO.puts("  confeccionista destacado: Código #{m.c}")
      IO.puts("  porcentaje ponderado de defectos: #{Util.formatter(m.p)}%")
    end
  end

  @doc """
  R7: Imprime los costos totales de nómina semanal y el costo promedio pagado por prenda válida.

  ## Parámetros
   - `validos`: Lista de lotes válidos.
   - `liquidaciones`: Lista de liquidaciones.

  """
  def r7(validos, liquidaciones) do
    IO.puts("\n")
    IO.puts(" **R7: TOTAL COSTO DE NÓMINA SEMANAL Y COSTO PROMEDIO POR PRENDA VÁLIDA** ")

    pagado = Enum.reduce(liquidaciones, 0.0, &(&1.neto + &2))
    prendas = Enum.reduce(validos, 0, &(&1.prendas + &2))
    promedio = if prendas > 0, do: "$" <> Util.formatter(pagado / prendas), else: "no calculable (0 prendas válidas)"

    IO.puts("  total desembolsado por el taller:  $#{Util.formatter(pagado)}")
    IO.puts("  total de prendas válidas producidas: #{prendas}")
    IO.puts("  costo promedio por prenda válida:   #{promedio}")
  end

  @doc """
  R8: Identifica y lista a los confeccionistas que laboraron en todas las líneas de producción del taller.

  ## Parámetros
   - `validos`: Lista de lotes válidos.
   - `lineas`: Lista de líneas registradas.

  """
  def r8(validos, lineas) do
    IO.puts("\n")
    IO.puts("R8: CONFECCIONISTAS QUE TRABAJARON EN TODAS LAS LÍNEAS DE PRODUCCIÓN")

    todas = lineas
    |> Enum.map(& &1.id)
    |> Enum.uniq()
    |> Enum.sort()

    cumplen = validos
    |> Enum.group_by(& &1.confeccionista)
    |> Enum.filter(fn {_c, l} -> (l |> Enum.map(& &1.linea) |> Enum.uniq() |> Enum.sort()) == todas end)
    |> Enum.map(&elem(&1, 0))

    if cumplen == [] do
      IO.puts("  ningun confeccionista registró lotes en todas las líneas.")
    else
      IO.puts("  confeccionista(s) con presencia total: #{Enum.join(cumplen, ", ")}")
    end
    IO.puts(".......\n")
  end

  @doc """
  Función requerida en la Parte C1 para generar un ranking personalizable empleando Keyword Lists.

  ## Parámetros
   - `liquidaciones`: Lista de mapas con las liquidaciones de los confeccionistas.
   - `opciones`: Keyword List opcional con las claves:
     - `:campo` -> `:neto` (por defecto), `:prendas` o `:bruto`
     - `:orden` -> `:desc` (por defecto) o `:asc`
     - `:limite` -> número entero límite de registros a retornar

  ## Ejemplos

      iex> liqs = [%{neto: 100}, %{neto: 200}]
      iex> res = Reportes.ranking(liqs, campo: :neto, orden: :desc, limite: 1)
      iex> length(res)
      1

  """
  def ranking(liquidaciones, opciones \\ []) do
    campo = Keyword.get(opciones, :campo, :neto)
    orden = Keyword.get(opciones, :orden, :desc)
    limite = Keyword.get(opciones, :limite, length(liquidaciones))

    liquidaciones
    |> Enum.sort_by(fn liq -> Map.get(liq, campo) end, orden)
    |> Enum.take(limite)
  end
end
