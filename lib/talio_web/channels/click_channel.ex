defmodule TalioWeb.ClickChannel do
  use Phoenix.Channel

  require Logger

  alias Talio.{
    Repo,
    Element,
    Click
  }

  def join("click:public", _message, socket) do
    {:ok, socket}
  end

  def join("click:" <> _private_id, _params, _socket) do
    {:error, %{reason: "Unauthorized"}}
  end

  def handle_in(
        "store_click",
        payload,
        socket
      ) do
    # # Check Rate Limit
    # with :ok <- Talio.RateLimiterClick.tick(socket.assigns.talio_user_id) do
    #   Logger.debug("Store Click !")
    # end

    case ConCache.get(:talio_branches_cache, payload["branch"]["fingerprint"]) do
      {:ok, branch} ->
        click_create_attrs = %{
          x: payload["click"]["x"],
          y: payload["click"]["y"],
          talio_user_id: socket.assigns.talio_user_id,
          path: payload["element"]["path"],
          device: payload["metadata"]["device"]
        }

        unless is_nil(branch) do
          # IO.inspect(click_create_attrs)

          %Click{}
          |> Click.changeset(click_create_attrs)
          |> Ecto.Changeset.put_assoc(:branch, branch)
          |> Repo.insert()
        end

        {:noreply, socket}

      _ ->
        {:noreply, socket}
    end
  end
end
