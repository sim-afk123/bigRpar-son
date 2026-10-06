defmodule Util do
  def mostrar_mensaje(mensaje) do
    IO.puts(mensaje)
    mensaje
  end

  def mostrar_error(mensaje) do
    IO.puts(:standard_error, mensaje)
    mensaje
  end

  def mostrar_mensaje_java(mensaje) do
    System.cmd("java", ["-cp", ".", "Mensaje", mensaje])
  end

  # Ingresar texto
  def ingresar(mensaje, :texto) do
    mensaje
    |> IO.gets()
    |> String.trim()
  end

  # Ingresar entero
  def ingresar(mensaje, :entero) do
    ingresar(mensaje, &String.to_integer/1, :entero)
  end

  # Ingresar real
  def ingresar(mensaje, :real) do
    ingresar(mensaje, &String.to_float/1, :real)
  end

  # Ingresar booleano / lógico (Agregado para la lectura de datos)
  def ingresar(mensaje, :booleano) do
    respuesta = mensaje |> ingresar(:texto) |> String.downcase()

    if respuesta == "true" or respuesta == "s" or respuesta == "si" or respuesta == "1" do
      true
    else
      if respuesta == "false" or respuesta == "n" or respuesta == "no" or respuesta == "0" do
        false
      else
        mostrar_error("Error, se esperaba un valor lógico (true/false o si/no)")
        ingresar(mensaje, :booleano)
      end
    end
  end

  def ingresar(mensaje, parser, tipo_dato) do
    try do
      mensaje
      |> ingresar(:texto)
      |> parser.()
    rescue
      ArgumentError ->
        "Error, se esperaba un número #{tipo_dato}"
        |> mostrar_error()

        ingresar(mensaje, parser, tipo_dato)
    end
  end

  def formatter(valor) do
    :erlang.float_to_binary(valor, decimals: 2)
  end
end
