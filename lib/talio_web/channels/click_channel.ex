defmodule TalioWeb.ClickChannel do
  use Phoenix.Channel

  def join("click:public", _message, socket) do
    send(self(), :initialize_user)
    {:ok, socket}
  end

  def join("click:" <> _private_id, _params, _socket) do
    {:error, %{reason: "Unauthorized"}}
  end

  def handle_info(:initialize_user, socket) do
    push(socket, "initialize_user", %{talio_user_id: socket.assigns.talio_user_id})
    {:noreply, socket}
  end
end
