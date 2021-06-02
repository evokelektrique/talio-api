defmodule TalioWeb.ClickChannel do
  use Phoenix.Channel

  require Logger

  alias Talio.{
    Repo,
    Branch,
    Element,
    Click
  }

  @nonce_length 32

  def join("click:public", _message, socket) do
    send(self(), :validate_website)
    send(self(), :initialize_user)

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
    element_find_attrs = [:path, :device, :tag_name]

    element_create_attrs = %{
      width: payload["element"]["width"],
      height: payload["element"]["height"],
      top: payload["element"]["top"],
      right: payload["element"]["right"],
      bottom: payload["element"]["bottom"],
      left: payload["element"]["left"],
      device: payload["metadata"]["device"],
      x: payload["element"]["x"],
      y: payload["element"]["y"],
      path: payload["element"]["path"],
      tag_name: payload["element"]["tag_name"]
    }

    element =
      Element.find_or_create(socket.assigns.branch, element_find_attrs, element_create_attrs)

    click_create_attrs = %{
      x: payload["click"]["x"],
      y: payload["click"]["y"],
      talio_user_id: socket.assigns.talio_user_id
    }

    %Click{}
    |> Click.changeset(click_create_attrs)
    |> Ecto.Changeset.put_assoc(:element, element)
    |> Repo.insert()

    {:noreply, socket}
  end

  def handle_in("store_branch", payload, socket) do
    send(self(), {:validate_nonce, payload})

    branch =
      Branch.find_or_create(
        socket.assigns.website,
        socket.assigns.snapshot,
        [:fingerprint],
        %{fingerprint: to_string(payload["fingerprint"])}
      )

    socket = socket |> assign(:branch, branch)

    {:reply, :ok, socket}
  end

  def handle_in("refresh_nonce", _payload, socket) do
    nonce = Talio.generate_nonce(@nonce_length)
    ConCache.get_or_store(:talio_nonce_cache, socket.assigns.talio_user_id, fn -> nonce end)

    {:reply, {:ok, %{nonce: nonce}}, socket}
  end

  # Send Users Unique Talio ID
  def handle_info(:initialize_user, socket) do
    # Store Generated Nonce For Talio User ID Into Cache
    cached_nonce = get_or_store_nonce(@nonce_length, socket.assigns.talio_user_id)
    # And Assign The Nonce To User's Socket Connection
    socket = socket |> assign(:nonce, cached_nonce)

    push(socket, "initialize_user", %{
      talio_user_id: socket.assigns.talio_user_id,
      nonce: cached_nonce
    })

    {:noreply, socket}
  end

  # Validate Necessary Conditions
  def handle_info(:validate_website, socket) do
    # If Website/Snapshot Not Found, Terminate User Connection
    unless socket.assigns.website || socket.assigns.snapshot do
      send(self(), :end_session)
    end

    {:noreply, socket}
  end

  # Validate Users Nonce
  def handle_info({:validate_nonce, %{"nonce" => user_nonce} = _payload}, socket) do
    nonce = get_or_store_nonce(@nonce_length, socket.assigns.talio_user_id)

    if nonce !== user_nonce || nonce !== socket.assigns.nonce do
      send(self(), :end_session)
    end

    # Delete Nonce
    ConCache.delete(:talio_nonce_cache, socket.assigns.talio_user_id)

    {:noreply, socket}
  end

  # Terminate User Connection
  def handle_info(:end_session, socket) do
    push(socket, "end_session", %{})
    {:stop, :normal, socket}
  end

  # Find Cached Nonce Or Store A New Nonce For Given User
  defp get_or_store_nonce(length, talio_user_id) do
    nonce = Talio.generate_nonce(length)
    ConCache.get_or_store(:talio_nonce_cache, talio_user_id, fn -> nonce end)
  end
end
