defmodule ExIRB.MapToHash do
  @moduledoc false

  import Inspect.Algebra

  def inspect_fun(term, opts) when is_map(term) do
    arrow = string("=>")
    comma = string(",")

    docs =
      term
      |> Enum.reduce([string("}")], fn {k, v}, acc ->
        key = inspect_fun(k, opts)
        value = inspect_fun(v, opts)
        [comma, key, arrow, value | acc]
      end)

    docs =
      case docs do
        [^comma | docs] -> docs
        docs -> docs
      end

    concat([string("{") | docs])
  end

  def inspect_fun(term, opts) do
    Inspect.inspect(term, opts)
  end
end
