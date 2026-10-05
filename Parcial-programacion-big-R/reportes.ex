defmodule Reportes do
  def generar_todos(validos, invalidos, liquidaciones, lineas) do
    r1(invalidos)
    r2(validos, lineas)
    r3(validos)
    r4(liquidaciones)
    r5(validos)
    r6(validos)
    r7(validos, liquidaciones)
    r8(validos, lineas)
  end

  def r1(invalidos) do
    IO.puts("\nR1")
    Enum.each(invalidos, fn {l, m} -> IO.puts("#{l.confeccionista} #{l.linea} #{l.dia} #{l.prendas} #{l.defectos} #{m}") end)

    invalidos
    |> Enum.frequencies_by(fn {_l, m} -> m end)
    |> Enum.each(fn {m, c} -> IO.puts("#{m}: #{c}") end)
  end

  def r2(validos, lineas) do
    IO.puts("\nR2")
    map = Enum.group_by(validos, & &1.linea)

    lineas
    |> Enum.map(fn lin ->
      prendas = Enum.reduce(Map.get(map, lin.id, []), 0, &(&1.prendas + &2))
      %{id: lin.id, prendas: prendas, prod: prendas / lin.puestos}
    end)
    |> Enum.sort_by(& &1.prod, :desc)
    |> Enum.each(fn l -> IO.puts("#{l.id} prendas: #{l.prendas} prod: #{Util.formatter(l.prod)}") end)
  end

  def r3(validos) do
    IO.puts("\nR3")
    map = Enum.group_by(validos, & &1.dia)

    res = Enum.map(1..6, fn d ->
      p = Enum.reduce(Map.get(map, d, []), 0, &(&1.prendas + &2))
      meta = p >= 600
      IO.puts("Dia #{d}: #{p} #{meta}")
      meta
    end)

    IO.puts("Todos: #{Enum.all?(res)}")
    IO.puts("Al menos uno: #{Enum.any?(res)}")
  end

  def r4(liquidaciones) do
    IO.puts("\nR4")
    liquidaciones
    |> Enum.sort_by(& &1.neto, :desc)
    |> Enum.with_index(1)
    |> Enum.each(fn {l, i} ->
      IO.puts("#{i}. #{l.codigo} #{l.nombre} #{l.prendas} #{Util.formatter(l.bruto)} #{Util.formatter(l.bonificaciones)} #{Util.formatter(l.alquiler)} #{Util.formatter(l.neto)}")
    end)
  end

  def r5(validos) do
    IO.puts("\nR5")
    ganadores = Enum.map(1..6, fn d ->
      lotes = Enum.filter(validos, &(&1.dia == d))
      if lotes == [] do
        IO.puts("Dia #{d}: Sin lotes")
        []
      else
        totales = lotes |> Enum.group_by(& &1.confeccionista) |> Enum.map(fn {c, l} -> {c, Enum.reduce(l, 0, &(&1.prendas + &2))} end)
        max = totales |> Enum.map(&elem(&1, 1)) |> Enum.max()
        top = Enum.filter(totales, &(elem(&1, 1) == max)) |> Enum.map(&elem(&1, 0))
        IO.puts("Dia #{d}: #{Enum.join(top, ", ")} (#{max})")
        top
      end
    end)

    frec = ganadores |> List.flatten() |> Enum.frequencies()
    if frec != %{} do
      max = frec |> Map.values() |> Enum.max()
      top = frec |> Enum.filter(&(elem(&1, 1) == max)) |> Enum.map(&elem(&1, 0))
      IO.puts("Mas dias: #{Enum.join(top, ", ")} (#{max})")
    end
  end

  def r6(validos) do
    IO.puts("\nR6")
    cand = validos
    |> Enum.group_by(& &1.confeccionista)
    |> Enum.filter(fn {_c, l} -> length(l) >= 3 end)
    |> Enum.map(fn {c, l} ->
      prod = Enum.reduce(l, 0.0, &(&1.defectos * &1.prendas + &2))
      prendas = Enum.reduce(l, 0, &(&1.prendas + &2))
      %{c: c, p: prod / prendas}
    end)

    if cand == [] do
      IO.puts("Sin candidatos")
    else
      m = Enum.min_by(cand, & &1.p)
      IO.puts("#{m.c} #{Util.formatter(m.p)}%")
    end
  end

  def r7(validos, liquidaciones) do
    IO.puts("\nR7")
    pagado = Enum.reduce(liquidaciones, 0.0, &(&1.neto + &2))
    prendas = Enum.reduce(validos, 0, &(&1.prendas + &2))
    IO.puts("Total: #{Util.formatter(pagado)}")
    IO.puts("Promedio: #{if prendas > 0, do: Util.formatter(pagado / prendas), else: "N/A"}")
  end

  def r8(validos, lineas) do
    IO.puts("\nR8")
    todas = lineas |> Enum.map(& &1.id) |> Enum.uniq() |> Enum.sort()
    cumplen = validos
    |> Enum.group_by(& &1.confeccionista)
    |> Enum.filter(fn {_c, l} -> (l |> Enum.map(& &1.linea) |> Enum.uniq() |> Enum.sort()) == todas end)
    |> Enum.map(&elem(&1, 0))

    IO.puts(if cumplen == [], do: "Ninguno", else: Enum.join(cumplen, ", "))
  end



  #investigacion
  def ranking(liquidaciones, opciones \\ []) do
  campo = Keyword.get(opciones, :campo, :neto)
  orden = Keyword.get(opciones, :orden, :desc)
  limite = Keyword.get(opciones, :limite, length(liquidaciones))

  liquidaciones
  |> Enum.sort_by(fn liq -> Map.get(liq, campo) end, orden)
  |> Enum.take(limite)
end
end
