defmodule ExIRB.Requirer do
  defmacro require_ruby(module, functions) do
    ruby_module =
      case module do
        {:__aliases__, _, [ruby_module]} -> ruby_module
        module -> module
      end

    quoted_functions =
      functions
      |> Enum.map(fn {function, arity} ->
        args =
          (?a..?z)
          |> Stream.map(&{String.to_atom(<<&1>>), [], __MODULE__})
          |> Enum.take(arity)

        {
          :def, [import: Kernel],
          [
            {function, [], args},
            [do: {
              {:., [], [ExIRB, :apply]},
              [],
              [module, function, args]
            }]
          ]
        }
      end)

    {
      :defmodule,
      [import: Kernel],
      [
        Module.concat(__CALLER__.module, ruby_module),
        [do: {:__block__, [], quoted_functions}]
      ]
    }
  end
end
