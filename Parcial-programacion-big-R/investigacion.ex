defmodule Investigacion do
  def ejecutar_todo(liquidaciones, lotes_validos) do
    IO.puts("\n" <> String.duplicate("=", 50))
    IO.puts("PARTE C: INVESTIGACIÓN EN ELIXIR")
    IO.puts(String.duplicate("=", 50))

    c1_keyword_lists(liquidaciones)
    c2_map_merge(lotes_validos)
    c3_mediciones_tc()
  end

  def c1_keyword_lists(liquidaciones) do
    IO.puts("\n--- C.1 RANKING CON KEYWORD LISTS ---")

    IO.puts("\n1. Llamada por defecto (Reportes.ranking(liquidaciones, [])):")
    IO.inspect(Reportes.ranking(liquidaciones, []))

    IO.puts("\n2. Filtrado por prendas y límite 3 (campo: :prendas, limite: 3):")
    IO.inspect(Reportes.ranking(liquidaciones, campo: :prendas, limite: 3))

    IO.puts("\n3. Orden ascendente por bruto (orden: :asc, campo: :bruto):")
    IO.inspect(Reportes.ranking(liquidaciones, orden: :asc, campo: :bruto))
  end

  def c2_map_merge(lotes_validos) do
    IO.puts("\n--- C.2 COMBINACIÓN DE PRODUCCIÓN (Map.merge/3) ---")

    # 1. Agrupar la producción diaria del taller actual obtenida de los lotes válidos
    produccion_taller =
      lotes_validos
      |> Enum.group_by(& &1.dia)
      |> Enum.map(fn {dia, lotes} -> {dia, Enum.reduce(lotes, 0, &(&1.prendas + &2))} end)
      |> Enum.into(%{})

    # 2. Mapa del taller aliado proporcionado por el enunciado
    taller_aliado = %{1 => 550, 2 => 620, 3 => 480, 5 => 710, 7 => 200}

    # 3. Combinación sumando la producción de los días presentes en ambos mapas
    produccion_combinada =
      Map.merge(produccion_taller, taller_aliado, fn _dia, p_taller, p_aliado ->
        p_taller + p_aliado
      end)

    IO.puts("Producción Taller Propio: #{inspect(produccion_taller)}")
    IO.puts("Producción Taller Aliado: #{inspect(taller_aliado)}")
    IO.puts("Producción Combinada:    #{inspect(produccion_combinada)}")
  end

  def c3_mediciones_tc do
    IO.puts("\n--- C.3 MEDICIONES DE RENDIMIENTO CON :timer.tc ---")

    # Experimento 1: Búsqueda en Lista vs Mapa (100.000 elementos, 1.000 búsquedas)
    confeccionistas_grandes =
      Enum.map(1..100_000, fn i ->
        %{codigo: "C#{i}", nombre: "Nombre #{i}"}
      end)

    mapa_indexado =
      Enum.reduce(confeccionistas_grandes, %{}, fn c, acc ->
        Map.put(acc, c.codigo, c)
      end)

    codigos_a_buscar = Enum.map(1..1_000, fn _ -> "C#{Enum.random(1..100_000)}" end)

    {t_lista, _} =
      :timer.tc(fn ->
        Enum.each(codigos_a_buscar, fn cod ->
          Enum.find(confeccionistas_grandes, fn c -> c.codigo == cod end)
        end)
      end)

    {t_mapa, _} =
      :timer.tc(fn ->
        Enum.each(codigos_a_buscar, fn cod ->
          Map.get(mapa_indexado, cod)
        end)
      end)

    # Experimento 2: Construcción de Lista (++ vs [elem | acc]) (20.000 elementos)
    {t_masmas, _} =
      :timer.tc(fn ->
        Enum.reduce(1..20_000, [], fn x, acc -> acc ++ [x] end)
      end)

    {t_cons, _} =
      :timer.tc(fn ->
        Enum.reduce(1..20_000, [], fn x, acc -> [x | acc] end)
      end)

    IO.puts("\nResultados de la prueba (en microsegundos µs):")
    IO.puts("1. Búsqueda en Lista (Enum.find): #{t_lista} µs")
    IO.puts("   Búsqueda en Mapa (Map.get):    #{t_mapa} µs")
    IO.puts("2. Inserción al final (++):       #{t_masmas} µs")
    IO.puts("   Inserción al inicio ([h | t]): #{t_cons} µs")
  end
end
