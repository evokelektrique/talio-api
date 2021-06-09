defmodule TalioWeb.BranchChannel do
  use Phoenix.Channel

  require Logger

  alias Talio.{
    Repo,
    Branch
  }

  def join("branch:public", _message, socket) do
    {:error, %{reason: "Unauthorized"}}
  end

  def join("branch:" <> fingerprint, _params, socket) do
    send(self(), :validate_website)

    unless TalioWeb.UserSocket.validate_snapshot_limits(
             socket.assigns.website,
             socket.assigns.snapshot
           ) do
      send(self(), :end_session)
    end

    send(self(), :initialize_user)

    {:ok, socket}
  end

  # 
  # Client API
  # 

  def handle_in("refresh_nonce", _payload, socket) do
    nonce = Talio.generate_nonce(@nonce_length)
    ConCache.get_or_store(:talio_nonce_cache, socket.assigns.talio_user_id, fn -> nonce end)

    {:reply, {:ok, %{nonce: nonce}}, socket}
  end

  def handle_in("store_branch", payload, socket) do
    send(self(), {:validate_nonce, payload})

    case Branch.find_or_create(
           socket.assigns.website,
           socket.assigns.snapshot,
           [:fingerprint],
           %{fingerprint: to_string(payload["fingerprint"])}
         ) do
      {:found, branch} ->
        # Store Branch Into Cache
        ConCache.put(:talio_branches_cache, payload["fingerprint"], fn -> branch end)
        {:reply, :ok, socket}

      {:created, branch} ->
        # Store Branch Into Cache
        ConCache.put(:talio_branches_cache, payload["fingerprint"], fn -> branch end)

        # Take Screenshot From Different Devices
        socket |> take_screenshots(branch)
        {:reply, :ok, socket}
    end
  end

  # 
  # Server API
  # 

  # Send Users Unique Talio ID
  def handle_info(:initialize_user, socket) do
    # Store Generated Nonce For Talio User ID Into Cache
    cached_nonce = Talio.get_or_store_nonce(socket.assigns.talio_user_id)

    # And Assign The Nonce To User's Socket Connection
    socket = socket |> assign(:nonce, cached_nonce)

    push(socket, "initialize_user", %{
      talio_user_id: socket.assigns.talio_user_id,
      nonce: cached_nonce
    })

    {:noreply, socket}
  end

  # Validate Users Nonce
  def handle_info({:validate_nonce, %{"nonce" => user_nonce} = _payload}, socket) do
    nonce = Talio.get_or_store_nonce(socket.assigns.talio_user_id)

    if nonce !== user_nonce || nonce !== socket.assigns.nonce do
      send(self(), :end_session)
    end

    # Delete Nonce
    ConCache.delete(:talio_nonce_cache, socket.assigns.talio_user_id)

    {:noreply, socket}
  end

  # Validate Necessary Conditions
  def handle_info(:validate_website, socket) do
    # If Website/Snapshot Not Found, Terminate User Connection
    unless socket.assigns.website || socket.assigns.snapshot do
      Logger.warning("What?")
      send(self(), :end_session)
    end

    # Check Origin URL
    unless socket.assigns.origin_host === socket.assigns.website.host do
      send(self(), :end_session)
    end

    {:noreply, socket}
  end

  # Terminate User Connection
  def handle_info(:end_session, socket) do
    Logger.error("Ending Session")
    push(socket, "end_session", %{})
    {:stop, :normal, socket}
  end

  #
  # Private Functions
  #

  # Take Screenshot From Different Devices
  defp take_screenshots(socket, branch) do
    Enum.each(0..2, fn device_type ->
      Branch.take_screenshot(socket.assigns.snapshot, branch, %{
        quality: 70,
        url: socket.assigns.website.url <> socket.assigns.snapshot.path,
        device_type: device_type,
        timeout: 120_000,
        recv_timeout: 120_000
      })
    end)
  end
end
