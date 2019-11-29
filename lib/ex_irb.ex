defmodule ExIRB do
  use GenServer

  @name __MODULE__

  def start_link(opts) do
    name = Keyword.get(opts, :name, @name)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  def eval_ruby(server \\ @name, expression) do
    GenServer.call(server, {:eval_ruby, expression})
  end

  def apply(server \\ @name, module, function, args) do
    [module_name] = Module.split(module)
    args_str =
      args
      |> Enum.map(fn arg ->
        arg
        |> inspect(limit: :infinity, charlists: false, inspect_fun: &ExIRB.MapToHash.inspect_fun/2)
      end)
      |> Enum.join(",")

    GenServer.call(server, {:eval_ruby, "#{module_name}.#{function}(#{args_str})"})
  end

  def cast_ruby(server \\ @name, expression) do
    GenServer.cast(server, {:cast_ruby, expression})
  end

  def init(opts) do
    path = System.find_executable("irb")
    requires =
      opts
      |> Keyword.get(:require, [])
      |> Enum.map(&"-r#{&1}")
    port = Port.open({:spawn_executable, path}, [:binary, args: ["--noverbose", "--noecho" | requires]])

    {:ok, %{port: port, froms: []}}
  end

  def handle_call({:eval_ruby, expression}, from, %{port: port, froms: froms} = state) do
    send(port, {self(), {:command, "print(Marshal.dump(#{expression}))\n"}})

    {:noreply, %{state | froms: [from | froms]}}
  end

  def handle_cast({:cast_ruby, expression}, %{port: port} = state) do
    send(port, {self(), {:command, expression}})

    {:noreply, state}
  end

  def handle_info({port, {:data, data}}, %{port: port, froms: [from | froms]} = state) do
    GenServer.reply(from, ExMarshal.load(data))

    {:noreply, %{state | froms: froms}}
  end
end
