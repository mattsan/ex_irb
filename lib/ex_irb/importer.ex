defmodule ExIRB.Importer do
  defmacro import_ruby(module, functions) do
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
  end
end
