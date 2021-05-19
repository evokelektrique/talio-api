defmodule TalioWeb.UserSocket do
  use Phoenix.Socket

  ## Channels
  channel "click:*", TalioWeb.ClickChannel

  @impl true
  def connect(_params, socket, connect_info) do
    user_id = generate_user_id(connect_info)
    {:ok, assign(socket, :talio_user_id, user_id)}
  end

  @impl true
  def id(socket), do: "users_socket:#{socket.assigns.talio_user_id}"

  defp generate_user_id(connect_info) do
    connect_info.peer_data.address
    |> Tuple.to_list()
    |> Enum.join(".")
    |> :erlang.phash2()
  end
end
