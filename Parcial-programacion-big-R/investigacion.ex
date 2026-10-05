defmodule Investigacion do
  @moduledoc """
  Módulo que reúne los ejercicios de la Parte C del parcial.
  Incluye la demostración del uso de Keyword Lists para opciones de funciones (C1),
  la combinación de datos de producción mediante Map.merge/3 (C2) y las mediciones
  de rendimiento de estructuras y algoritmos usando :timer.tc/1 (C3).

  - Autores: Simón Valencia Ochoa, Samuel Marín Varón, Isabel Cristina Guerra Guzmán.
  - Fecha: Octubre del 2026
  - Licencia: GNU GPL v3
  """

  @doc """
  Ejecuta secuencialmente los tres componentes investigativos de la Parte C.

  ## Parámetros
   - `liquidaciones`: Lista de mapas con las liquidaciones semanales.
   - `lotes_validos`: Lista de lotes válidos aprobados por el sistema.

  ## Ejemplos

      ```elixir
      Investigacion.ejecutar_todo(liquidaciones, lotes_validos)
      ```

  """
  def ejecutar_todo(liquidaciones, lotes_validos) do
    IO.puts("**parte C: investigacion**")

    c1_keyword_lists(liquidaciones)
    c2_map_merge(lotes_validos)
    c3_mediciones_tc()
  end

  @doc """
  C1: Demuestra el comportamiento de `Reportes.ranking/2` al invocarla con
  diferentes opciones mediante Keyword Lists.

  ## Parámetros
   - `liquidaciones`: Lista de liquidaciones a ordenar y filtrar.

  """
  def c1_keyword_lists(liquidaciones) do
    IO.puts("\n ---C1 Ranking con Keyword list ")

    IO.puts("\n1. llamada (Reportes.ranking(liquidaciones, [])):")
    IO.inspect(Reportes.ranking(liquidaciones, []))

    IO.puts("\n2. fitro por prenda max 3 (campo: :prendas, limite: 3):")
    IO.inspect(Reportes.ranking(liquidaciones, campo: :prendas, limite: 3))

    IO.puts("\n3. orden ascendente por el bruto (orden: :asc, campo: :bruto):")
    IO.inspect(Reportes.ranking(liquidaciones, orden: :asc, campo: :bruto))
  end

  @doc """
  C2: Agrupa la producción propia por día y la combina con el mapa de un taller aliado
  usando `Map.merge/3` para resolver colisiones de claves sumando la producción.

  ## Parámetros
   - `lotes_validos`: Lista de lotes válidos registrados en el taller.

  """
  def c2_map_merge(lotes_validos) do
    IO.puts("\n ---C2 combinacion de la produccion (Map.merge/3) ")

    produccion_taller =
      lotes_validos
      |> Enum.group_by(& &1.dia)
      |> Enum.map(fn {dia, lotes} -> {dia, Enum.reduce(lotes, 0, &(&1.prendas + &2))} end)
      |> Enum.into(%{})

    taller_aliado = %{1 => 550, 2 => 620, 3 => 480, 5 => 710, 7 => 200}

    produccion_combinada =
      Map.merge(produccion_taller, taller_aliado, fn _dia, p_taller, p_aliado ->
        p_taller + p_aliado
      end)

    IO.puts("productos de nuestro taller: #{inspect(produccion_taller)}")
    IO.puts("produccion de otro taller: #{inspect(taller_aliado)}")
    IO.puts("combinacion de la produccion:    #{inspect(produccion_combinada)}")
  end

  @doc """
  C3: Mide con `:timer.tc/1` los tiempos de ejecución comparativos entre:
  1. Búsqueda en Listas (`Enum.find/2`) vs Búsqueda en Mapas (`Map.get/2`) sobre 100.000 elementos.
  2. Construcción de Listas concatenando al final (`++`) vs insertando al inicio (`[cabeza | cola]`).

  """
  def c3_mediciones_tc do
    IO.puts("\n ---C3 rendimiento con :timer.tc ")

    # prueba 1
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

    # prueba 2
    {t_masmas, _} =
      :timer.tc(fn ->
        Enum.reduce(1..20_000, [], fn x, acc -> acc ++ [x] end)
      end)

    {t_cons, _} =
      :timer.tc(fn ->
        Enum.reduce(1..20_000, [], fn x, acc -> [x | acc] end)
      end)

    IO.puts("\nResultados de la prueba (en microsegundos µs):")
    IO.puts("1. busqueda en Lista (Enum.find): #{t_lista} µs")
    IO.puts("   busqueda en Mapa (Map.get):    #{t_mapa} µs")
    IO.puts("2. insercion al final (++):       #{t_masmas} µs")
    IO.puts("   insercion al inicio ([h | t]): #{t_cons} µs")
  end
end
