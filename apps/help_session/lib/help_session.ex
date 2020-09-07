defmodule HelpSession do
  import Emulation, only: [spawn: 2, send: 2, timer: 1]

  import Kernel,
    except: [spawn: 3, spawn: 1, spawn_link: 1, spawn_link: 3, send: 2]

  @moduledoc """
  Documentation for `HelpSession`.
  """

  @doc """
  Simple function showing how Elixir
  anonymous functions are created.
  """
  @spec lambda_demo(number()) :: number()
  def lambda_demo(e) do
    a = fn r -> r + e end

    b = fn c ->
      d = c * e
      d + 5
    end

    a.(22) + b.(111)
  end

  @doc """
  A function with arity 0 to demonstrate
  function references rather than functions
  """
  @spec arity0() :: number()
  def arity0 do
    IO.puts("You have called this arity 0 function")
    22
  end

  @doc """
  A simple demo application for lists.
  """
  @spec list_demo() :: boolean()
  def list_demo do
    # List from 0 to 20
    a = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19]

    # Cons cells, this is useful when reasoning about complexity,
    # recursing, and pattern matching
    [ah | rest] = a
    # This will cause the process to crash if ah != 0
    0 = ah
    a_prime = [0 | rest]

    if a != a_prime do
      raise "a and a_prime differ."
    end

    # More cannonical way of getting the first element.
    _ah = List.first(a)

    # Going from ranges to list
    a = Enum.to_list(0..19)
    # Higher order functions
    # Map: run the supplied function on each element of the list
    # Note module name `:rand` is an atom. Why?
    b = Enum.map(a, fn _ -> :rand.uniform(100) end)
    # Filter: produce list of elements for which supplied function returns true.
    c = Enum.filter(b, fn n -> n > 50 end)

    # Reduce: combine elements of the list. Often called `fold` in other languages.
    d = Enum.reduce(b, 0, fn x, y -> x + y end)
    # for: A way to combine map and filter.
    e =
      for n <- b, n > 50 do
        n + 1
      end

    IO.puts(
      "c: #{inspect(c, charlists: false)}; sum(c) = #{d}; e: #{
        inspect(e, charlists: false)
      }"
    )

    true
  end

  @doc """
  Maps in elixir
  """
  @spec map_demo() :: boolean()
  def map_demo do
    # Create a new map
    _a = %{}
    a = Map.new()
    # Insert key `:key` into map with value `2`.
    # Note this returns a new map.
    b = Map.put(a, :key, 2)
    # Get :key from Map
    2 = b[:key]
    # If no key exists this returns nil
    nil = b[:mu]
    # If you want to raise an exception in case
    # a key doesn't exist, you can use `fetch!`
    try do
      Map.fetch!(b, :mu)
    rescue
      e -> IO.puts("Exception #{inspect(e)}")
    end

    # Only insert if :key doesn't exist.
    c = Map.put(b, :key, 44)
    IO.puts("c[:key] is #{c[:key]}")

    # Merging is going to be useful later.
    # Consider two maps
    a = %{a: 1, b: 2}
    b = %{b: 33, c: 5}
    # Want to produce c with keys from both.
    c =
      Map.merge(a, b, fn k, x, y ->
        IO.puts("Conflict at key #{k}")
        x + y
      end)

    IO.puts("a = #{inspect(a)}; b = #{inspect(b)}; c = #{inspect(c)}")
    true
  end

  @doc """
  Show pattern matching.
  """
  @spec pattern_matching1(any()) :: atom()
  def pattern_matching1(input) do
    case input do
      {:a, 2} ->
        IO.puts("Got :a with 2")
        :branch1

      {:a, n} ->
        IO.puts("Got :a with #{inspect(n)}")
        :branch2

      {:b, n} ->
        IO.puts("Got :b with #{inspect(n)}")
        :branch3

      {:b, 1} ->
        IO.puts("Got :b with 1")
        :branch4

      _ ->
        IO.puts("Unknown")
        :branch5
    end
  end

  @doc """
  Show pattern matching 2.
  """
  @spec pattern_matching2(any(), atom()) :: atom()
  def pattern_matching2(input, atm) do
    case input do
      {^atm, 1} ->
        IO.puts("Got supplied atom #{inspect(atm)} and 1")
        :branch1

      {atm, 2} ->
        IO.puts("Got supplied atom #{inspect(atm)} and 1")
        :branch2

      _ ->
        IO.puts("Unknown")
        :branch5
    end
  end

  @doc """
  Flips a bit when a message with atom :flip
  is received
  """
  @spec flip(boolean()) :: no_return()
  def flip(state) do
    receive do
      {_, :flip} ->
        raise "Not implemented"

      {w, :current} ->
        send(w, state)
        flip(state)
    end
  end

  @doc """
  Test the flip function.
  """
  @spec test_flip() :: boolean()
  def test_flip do
    Emulation.init()
    spawn(:flip, fn -> HelpSession.flip(false) end)
    send(:flip, :flip)
    send(:flip, :current)

    receive do
      false -> raise "Not flipped"
      true -> true
    end
  after
    Emulation.terminate()
  end
end
