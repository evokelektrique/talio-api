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

    # element_find_attrs = [:path, :device, :tag_name]

    # element_create_attrs = %{
    #   width: payload["element"]["width"],
    #   height: payload["element"]["height"],
    #   top: payload["element"]["top"],
    #   right: payload["element"]["right"],
    #   bottom: payload["element"]["bottom"],
    #   left: payload["element"]["left"],
    #   device: payload["metadata"]["device"],
    #   x: payload["element"]["x"],
    #   y: payload["element"]["y"],
    #   path: payload["element"]["path"],
    #   tag_name: payload["element"]["tag_name"]
    # }

    case ConCache.get(:talio_branches_cache, payload["branch"]["fingerprint"]) do
      {:ok, branch} ->
        # element = Element.find_or_create(branch, element_find_attrs, element_create_attrs)

        click_create_attrs = %{
          x: payload["click"]["x"],
          y: payload["click"]["y"],
          talio_user_id: socket.assigns.talio_user_id,
          path: payload["element"]["path"],
          device: payload["metadata"]["device"]
        }

        # TODO: use unless
        if !is_nil(branch) do
          IO.inspect(click_create_attrs)

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
