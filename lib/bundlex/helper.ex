defmodule Bundlex.Helper do
  defmacro __using__(_args) do
    quote do
      import unquote(__MODULE__), only: [~>: 2, ~>>: 2, provided: 2, int_part: 2]
      alias unquote(__MODULE__)
    end
  end

  @compile {:inline, listify: 1, wrap_nil: 2, int_part: 2}

  def listify(list) when is_list(list) do
    list
  end

  def listify(non_list) do
    [non_list]
  end

  def wrap_nil(nil, reason), do: {:error, reason}
  def wrap_nil(v, _), do: {:ok, v}

  def result_with_status({:ok, _state} = res), do: {:ok, res}
  def result_with_status({{:ok, _res}, _state} = res), do: {:ok, res}
  def result_with_status({{:error, reason}, _state} = res), do: {{:error, reason}, res}
  def result_with_status({:error, reason} = res), do: {{:error, reason}, res}

  def int_part(x, d) when is_integer(x) and is_integer(d) do
    r = x |> rem(d)
    x - r
  end

  defmacro x ~> match_clauses when is_list(match_clauses) do
    quote do
      case unquote(x) do
        unquote(match_clauses)
      end
    end
  end

  defmacro x ~> lambda do
    quote do
      unquote({:&, [], [lambda]}).(unquote(x))
    end
  end

  defmacro x ~>> match_clauses do
    default =
      quote do
        _ -> unquote(x)
      end

    quote do
      case unquote(x) do
        unquote(match_clauses ++ default)
      end
    end
  end

  defmacro provided(value, that: condition, else: default) do
    quote do
      if unquote(condition) do
        unquote(value)
      else
        unquote(default)
      end
    end
  end

  defmacro provided(value, that: condition) do
    quote do
      if unquote(condition) do
        unquote(value)
      else
        []
      end
    end
  end

  defmacro provided(value, do: condition, else: default) do
    quote do
      if unquote(condition) do
        unquote(value)
      else
        unquote(default)
      end
    end
  end

  defmacro provided(value, do: condition) do
    quote do
      if unquote(condition) do
        unquote(value)
      else
        []
      end
    end
  end

  defmacro provided(value, not: condition, else: default) do
    quote do
      if !unquote(condition) do
        unquote(value)
      else
        unquote(default)
      end
    end
  end

  defmacro provided(value, not: condition) do
    quote do
      if !unquote(condition) do
        unquote(value)
      else
        []
      end
    end
  end

  defmacro stacktrace do
    quote do
      # drop excludes `Process.info/2` call
      Process.info(self(), :current_stacktrace)
      ~> ({:current_stacktrace, trace} -> trace)
      |> Enum.drop(1)
      |> Exception.format_stacktrace()
    end
  end
end
