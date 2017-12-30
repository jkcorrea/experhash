defmodule ExPerHash do
  use GenServer

  @default_port_path "priv/experhash_port"
  @type error :: {:error, {atom, atom}}

  @doc """
  Start an ExPerHash server process linked to the current process.

  Registers the process under `name` if given. You can also supply
  the `[port_path: "/path/to/binary"]` argument to specify a custom
  path to the ExPerHash compiled executable (defaults to `priv/experhash_port`).
  """
  @spec start_link() :: GenServer.on_start
  def start_link(), do: start_link([])

  @spec start_link([port_path: String.t]) :: GenServer.on_start
  def start_link(args) when is_list(args), do: GenServer.start_link __MODULE__, args

  @spec start_link(GenServer.name) :: GenServer.on_start
  def start_link(name), do: start_link(name, [])

  @spec start_link(GenServer.name, [port_path: String.t]) :: GenServer.on_start
  def start_link(name, args), do: GenServer.start_link __MODULE__, args, name: name

  @doc """
  Calculate the aHash for the image named `filename`.
  """
  @spec a_hash(GenServer.server, String.t) :: {:ok, <<_ :: 64>>} | error
  def a_hash(server, filename) do
    GenServer.call server, {:command, {:hash, :a, filename}}, 10000
  end

  @doc """
  Calculate the dHash for the image named `filename`.
  """
  @spec d_hash(GenServer.server, String.t) :: {:ok, <<_ :: 64>>} | error
  def d_hash(server, filename) do
    GenServer.call server, {:command, {:hash, :d, filename}}, 10000
  end

  @doc """
  Calculate the ddHash for the image named `filename`.
  """
  @spec dd_hash(GenServer.server, String.t) :: {:ok, <<_ :: 128>>} | error
  def dd_hash(server, filename) do
    GenServer.call server, {:command, {:hash, :dd, filename}}, 10000
  end

  @doc """
  Calculate the Hamming distance between two hashes.
  """
  @spec hamming_distance(GenServer.server, binary, binary) :: {:ok, non_neg_integer} | error
  def hamming_distance(server, hash1, hash2) do
    GenServer.call server, {:command, {:hamming_distance, hash1, hash2}}
  end


  defmodule State do
    defstruct port: nil
  end

  def init([port_path: port_path]) do
    port = Port.open {:spawn, port_path}, [{:packet, 4}, :binary]

    {:ok, %State{port: port}}
  end

  def init(_args), do: init([port_path: @default_port_path])

  def handle_call({:command, command}, _from, state) do
    send_command state.port, command

    {:reply, receive_response(state.port), state}
  end

  defp send_command(port, command) do
    true = Port.command port, :erlang.term_to_binary(command)
  end

  defp receive_response(port) do
    receive do
      {^port, {:data, data}} ->
        :erlang.binary_to_term data
    after
      10000 ->
        {:error, :port_timeout}
    end
  end
end

